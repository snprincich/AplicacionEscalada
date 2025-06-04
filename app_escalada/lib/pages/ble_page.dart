import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_it/get_it.dart';
import 'package:app_escalada/services/ble/bluetooth.dart';

class BlePage extends StatefulWidget {
  final ble = GetIt.I<Ble>();
  BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  bool bluetoothReady = false;

  @override
  void initState() {
    super.initState();
    initBle();
  }

  Future<void> initBle() async {
    await widget.ble.checkAndRequestBluetoothPermissions();
    setState(() {
      bluetoothReady = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startScan() {
    if (!bluetoothReady) {
      print('Bluetooth no esta listo');
      return;
    }

    widget.ble.devices.clear();
    setState(() {});

    widget.ble.startScan(
      onDevicesUpdated: () {
        setState(() {});
      },
    );

    //Parar el escaneo tras 5 segundos automáticamente
    Future.delayed(Duration(seconds: 5), () async {
      await widget.ble.stopScan();
    });
  }

  void connectToDevice(DiscoveredDevice device) async {
    widget.ble.dispose();
    await Future.delayed(Duration(milliseconds: 500));

    if (await widget.ble.connectToDevice(device)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('BLUETOOTH', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BlePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // Info
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Ajustes
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: bluetoothReady ? startScan : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_audio_rounded, size: 32),
              SizedBox(height: 4),
              Text('Scan', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.ble.connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dispositivo conectado:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Info del dispositivo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ble.connectedDevice!.name.isNotEmpty
                                  ? widget.ble.connectedDevice!.name
                                  : 'Unknown',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.ble.connectedDevice!.id,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de desconectar
                      IconButton(
                        icon: Icon(Icons.link_off, color: Colors.red),
                        onPressed: () async {
                          await widget.ble.dispose();
                          setState(
                            () {},
                          ); // actualizar para que se borre el conectado
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.ble.devices.length,
              itemBuilder: (context, index) {
                final device = widget.ble.devices[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : "Unknown"),
                  subtitle: Text(device.id),
                  onTap: () => connectToDevice(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
