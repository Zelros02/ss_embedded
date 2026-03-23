#include <Arduino.h>

void setup() {
    Serial.begin(115200);
    Serial.println("Hello ESP32-CAM CI/CD!");
}

void loop() {
    // Bucla principala goala
}

void testEroare() { int x = 5 } // Lipseste un punct si virgula intentionat
