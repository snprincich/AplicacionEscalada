import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ble {
  FlutterReactiveBle ble = FlutterReactiveBle();

  List<DiscoveredDevice> devices = [];
  StreamSubscription<DiscoveredDevice>? scanSubscription;
  bool isScanning = false;
  StreamSubscription<ConnectionStateUpdate>? connection;
  StreamSubscription<List<int>>? dataSubscription;

  void Function(double)? onDataReceived;

  DiscoveredDevice? connectedDevice;
  bool connected = false;
  final ValueNotifier<bool> conectadoNotifier = ValueNotifier(false);

  DiscoveredDevice? lastDevice;

  Ble({this.onDataReceived});

  bool isConnected() {
    return connected;
  }

  Future<bool> checkAndRequestBluetoothPermissions() async {
    if (Platform.isAndroid) {
      final bluetoothScanStatus = await Permission.bluetoothScan.request();
      final bluetoothConnectStatus =
          await Permission.bluetoothConnect.request();
      final locationStatus = await Permission.location.request();

      if (bluetoothScanStatus != PermissionStatus.granted ||
          bluetoothConnectStatus != PermissionStatus.granted ||
          locationStatus != PermissionStatus.granted) {
        return false;
      }
    } else if (Platform.isIOS) {
      final bluetoothStatus = await Permission.bluetooth.request();

      if (bluetoothStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> scanBleDevices({void Function()? onDevicesUpdated}) async {
    await scanSubscription?.cancel();
    scanSubscription = null;

    scanSubscription = ble
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen(
          (device) {
            if (devices.every((d) => d.id != device.id)) {
              devices.add(device);
              onDevicesUpdated?.call();
            }
          },
          onDone: () {},
          onError: (error) {
            stopScan();
          },
        );
  }

  Future<void> stopScan() async {
    await scanSubscription?.cancel();
    scanSubscription = null;
    isScanning = false;
  }

  Future<void> startScan({void Function()? onDevicesUpdated}) async {
    if (isScanning) {
      if (kDebugMode) {
        print("Restarting scan...");
      }
      await stopScan();
      await Future.delayed(Duration(seconds: 1));
    }
    scanBleDevices(onDevicesUpdated: onDevicesUpdated);
  }

  Future<void> saveDevice(DiscoveredDevice device) async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, String> serviceDataBase64 = {};
    device.serviceData.forEach((uuid, data) {
      serviceDataBase64[uuid.toString()] = base64Encode(data);
    });

    final deviceMap = {
      'id': device.id,
      'name': device.name,
      'rssi': device.rssi,
      'serviceUuids':
          device.serviceUuids.map((uuid) => uuid.toString()).toList(),
      'serviceData': serviceDataBase64,
      'manufacturerData': base64Encode(device.manufacturerData),
      'connectable': device.connectable.index,
    };

    prefs.setString('savedDevice', jsonEncode(deviceMap));
  }

  Future<bool?> loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('savedDevice');
    if (jsonString == null) return null;

    final Map<String, dynamic> deviceMap = jsonDecode(jsonString);

    final Map<Uuid, Uint8List> serviceDataDecoded = {};
    final Map<String, dynamic> serviceDataBase64 = Map<String, dynamic>.from(
      deviceMap['serviceData'],
    );
    serviceDataBase64.forEach((uuidStr, base64Str) {
      serviceDataDecoded[Uuid.parse(uuidStr)] = base64Decode(base64Str);
    });

    final Uint8List manufacturerDataDecoded = base64Decode(
      deviceMap['manufacturerData'],
    );

    final Connectable connectable =
        Connectable.values[deviceMap['connectable'] ?? 0];

    DiscoveredDevice device = DiscoveredDevice(
      id: deviceMap['id'],
      name: deviceMap['name'],
      rssi: deviceMap['rssi'],
      serviceUuids:
          (deviceMap['serviceUuids'] as List)
              .map((s) => Uuid.parse(s))
              .toList(),
      serviceData: serviceDataDecoded,
      manufacturerData: manufacturerDataDecoded,
      connectable: connectable,
    );

    lastDevice = device;
    await connectToDevice(device);
    return Future.value(true);
  }

  Future<bool> connectToDevice(DiscoveredDevice device) async {
    final completer = Completer<bool>();
    lastDevice = device;

    connection?.cancel();
    if (kDebugMode) {
      print('🔗 Intentando conectar a ${device.id}...');
    }
    connection = ble
        .connectToDevice(id: device.id)
        .listen(
          (connectionState) {
            if (kDebugMode) {
              print('Estado BLE: ${connectionState.connectionState}');
            }

            if (connectionState.connectionState ==
                DeviceConnectionState.connected) {
              connectedDevice = device;
              connected = true;
              conectadoNotifier.value = true;

              saveDevice(device);
              if (!completer.isCompleted) completer.complete(true);
            }

            if (connectionState.connectionState ==
                DeviceConnectionState.disconnected) {
              if (kDebugMode) {
                print("🔌 Desconectado. Reintentando en 5s...");
              }
              connectedDevice = null;
              connected = false;
              conectadoNotifier.value = false;

              Future.delayed(Duration(seconds: 5), () {
                if (lastDevice != null) {
                  connectToDevice(lastDevice!);
                }
              });
            }
          },
          onError: (e) {
            if (kDebugMode) {
              print("Error en conexión: $e");
            }
            connected = false;
            connectedDevice = null;

            if (!completer.isCompleted) completer.complete(false);

            Future.delayed(Duration(seconds: 5), () {
              if (lastDevice != null) {
                connectToDevice(lastDevice!);
              }
            });
          },
        );

    return completer.future;
  }

  Future<void> dispose() async {
    await scanSubscription?.cancel();
    await connection?.cancel();
    await dataSubscription?.cancel();
    connectedDevice = null;
    connection = null;
  }

  void dejarRecibirDatos() {
    dataSubscription?.cancel();
    dataSubscription = null;
  }

  Future<void> recibirDatos() async {
    if (connectedDevice == null) {
      if (kDebugMode) {
        print('No hay dispositivo conectado.');
      }
      return;
    }
    if (dataSubscription != null) {
      dejarRecibirDatos();
      return;
    }

    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB"),
      characteristicId: Uuid.parse("0000FFE1-0000-1000-8000-00805F9B34FB"),
      deviceId: connectedDevice!.id,
    );

    final completer = Completer<void>();

    dataSubscription = ble
        .subscribeToCharacteristic(characteristic)
        .listen(
          (data) {
            try {
              final text = utf8.decode(data).trim();
              if (kDebugMode) {
                print('Texto recibido: $text');
              }

              final floatValue = double.tryParse(text);
              if (floatValue != null) {
                if (kDebugMode) {
                  print('Time: ${DateTime.now()} - numérico: $floatValue');
                }
                onDataReceived?.call(floatValue);

                if (!completer.isCompleted) {
                  completer.complete();
                }
              } else {
                if (kDebugMode) {
                  print('Error al convertir el dato a double');
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error al decodificar datos: $e');
              }
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          cancelOnError: true,
        );

    await completer.future;
  }
}
