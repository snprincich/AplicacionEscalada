#include <SoftwareSerial.h>
#include <HX711_ADC.h>


const int HX711_dout = 4; 
const int HX711_sck = 5; 

SoftwareSerial bt(10, 11); // RX, TX
HX711_ADC LoadCell(HX711_dout, HX711_sck);


// CALCULO MEDIA
const unsigned long intervalo = 1000;
unsigned long tiempoAnterior = 0;          // Almacena el tiempo anterior
float pesoTotal = 0;                       // Suma de todas las lecturas de peso
int numLecturas = 0;                       // Contador de lecturas

void setup() {
  Serial.begin(57600);
  bt.begin(9600);

  LoadCell.begin();
  LoadCell.setReverseOutput();
  unsigned long stabilizingtime = 2000; 
  boolean _tare = true;
  LoadCell.start(stabilizingtime, _tare);

  if (LoadCell.getTareTimeoutFlag() || LoadCell.getSignalTimeoutFlag()) {
    Serial.println("Timeout");
    while (1);
  }
  else {
    LoadCell.setCalFactor(22.19);
    Serial.println("Startup is complete");
  }

  while (!LoadCell.update());
}

void loop() {
  // Verifica si ha pasado 0.1 segundos
  unsigned long msActual = millis();
  
  if (msActual - tiempoAnterior >= intervalo) {
    // Si han pasado, calcula la media
    float averageWeight = pesoTotal / numLecturas;  // Media de las lecturas
    
    // Enviar la media por Bluetooth
    bt.println(averageWeight);

    // Imprimir la media en el monitor serial
    Serial.print("Avg Weight: ");
    Serial.println(averageWeight);

    // Reiniciar variables
    pesoTotal = 0;
    numLecturas = 0;

    // Actualizar el tiempo para el siguiente ciclo
    tiempoAnterior = msActual;
  }

  // LEER DATOS SENSORES
  if (LoadCell.update()) {
    float weight = LoadCell.getData();  // Obtener el peso de la LOAD CELL
    pesoTotal += weight;                // Acumular el peso
    numLecturas++;                      // Incrementar el contador de lecturas
  }
}