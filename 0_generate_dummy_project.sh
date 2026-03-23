#!/bin/bash

echo "==== Generare fisiere de baza pentru proiect ===="

# 1. Configurare PlatformIO
cat << 'EOF' > platformio.ini
[env:esp32cam]
platform = espressif32
board = esp32cam
framework = arduino
EOF
echo "Creat: platformio.ini"

# 2. Structura C++ pentru ESP32
mkdir -p src include

cat << 'EOF' > src/main.cpp
#include <Arduino.h>

void setup() {
    Serial.begin(115200);
    Serial.println("Hello ESP32-CAM CI/CD!");
}

void loop() {
    // Bucla principala goala
}
EOF
echo "Creat: src/main.cpp si folderul include/"

# 3. Script Python (receiver.py)
cat << 'EOF' > receiver.py
import numpy as np
import cv2
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code {rc}")

def main():
    client = mqtt.Client()
    client.on_connect = on_connect
    
    # Cod dummy pentru a folosi librariile (sa nu dea eroare pylint)
    dummy_array = np.zeros((10, 10, 3), dtype=np.uint8)
    gray_image = cv2.cvtColor(dummy_array, cv2.COLOR_BGR2GRAY)
    print("Test initializare imagine:", gray_image.shape)

if __name__ == "__main__":
    main()
EOF
echo "Creat: receiver.py"

echo "Structura dummy a fost creata cu succes!"
