#!/bin/bash

echo "==== 1. Asigurarea folderului include/ ===="
# Prevenim eroarea in care cppcheck nu gaseste folderul include pentru ca Git l-a ignorat
mkdir -p include
touch include/.gitkeep
git add include/.gitkeep

echo "==== 2. Actualizare ci.yml cu Smoke Test, Release și fix pentru cppcheck ===="
cat << 'EOF' > .github/workflows/ci.yml
name: ESP32-CAM CI Pipeline

on:
  push:
    branches: [ "main" ]
    tags: [ "v*.*" ] # Declanșează la tag-uri precum v1.0
  pull_request:
    branches: [ "main" ]

jobs:
  build-firmware:
    name: Build ESP32 Firmware
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install PlatformIO
        run: pip install platformio
      - name: Build Firmware (ESP32-CAM AI-Thinker)
        run: pio run -e esp32cam
      - name: Upload Firmware Artifact
        uses: actions/upload-artifact@v4
        with:
          name: firmware-esp32cam
          path: .pio/build/esp32cam/firmware.bin
          
  release:
    name: Create GitHub Release
    needs: build-firmware
    if: startsWith(github.ref, 'refs/tags/')
    runs-on: ubuntu-latest
    steps:
      - name: Download Artifact
        uses: actions/download-artifact@v4
        with:
          name: firmware-esp32cam
      - name: Release
        uses: softprops/action-gh-release@v2
        with:
          files: firmware.bin

  analyze-firmware:
    name: Static Analysis (C++)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Install Cppcheck
        run: sudo apt-get install -y cppcheck
      - name: Run Cppcheck
        # S-a adaugat --suppress=unmatchedSuppression
        run: cppcheck --enable=all --inconclusive --std=c++11 -I include/ --suppress=missingIncludeSystem --suppress=missingInclude --suppress=unusedFunction --suppress=cstyleCast --suppress=unmatchedSuppression --error-exitcode=1 src/

  check-python:
    name: Python Lint & Security
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: |
          pip install pylint bandit
          pip install paho-mqtt opencv-python-headless numpy
      - name: Smoke test
        run: python -m py_compile receiver.py
      - name: Lint with Pylint
        run: pylint --disable=C0114,C0115,C0116,C0103 receiver.py || true
      - name: Security scan with Bandit
        run: bandit receiver.py
EOF

echo "==== 3. Salvarea noilor reguli de CI pe main ===="
git add .github/workflows/ci.yml
git commit -m "feat: adaugare Smoke Test, Github Release si fix cppcheck"
git push origin main

echo "==== 4. Crearea unui eșec intenționat pentru Exercițiul 1 ===="
git checkout -b test-pr-esec

# Introducem o eroare intenționată la finalul fișierului main.cpp
mkdir -p src
if [ ! -f src/main.cpp ]; then
    echo "void setup() {} void loop() {}" > src/main.cpp
fi

echo -e "\nvoid testEroare() { int x = 5 } // Lipseste un punct si virgula intentionat" >> src/main.cpp

git add src/main.cpp
git commit -m "fix: introduce o eroare intentionata pentru a testa CI"
git push -u origin test-pr-esec

echo "======================================================"
echo "Gata! Acum mergi pe GitHub la repository-ul tău și creează Pull Request-ul."
echo "======================================================"
