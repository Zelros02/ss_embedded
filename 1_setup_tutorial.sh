
#!/bin/bash

# Solicităm numele repository-ului
read -p "Introdu numele repository-ului creat pe GitHub (ex: proiect-embedded): " REPO_NAME
GITHUB_USER="Zelros02"

echo "==== 1. Inițializare Git ===="
git init

echo "==== 2. Creare .gitignore ===="
cat << 'EOF' > .gitignore
# PlatformIO
.pio/

# Python
.venv/
__pycache__/
*.pyc

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF

echo "==== 3. Creare workflow CI de bază ===="
mkdir -p .github/workflows

cat << 'EOF' > .github/workflows/ci.yml
name: ESP32-CAM CI Pipeline

on:
  push:
    branches: [ "main" ]
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

  analyze-firmware:
    name: Static Analysis (C++)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Install Cppcheck
        run: sudo apt-get install -y cppcheck
      - name: Run Cppcheck
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
      - name: Lint with Pylint
        run: pylint --disable=C0114,C0115,C0116,C0103 receiver.py || true
      - name: Security scan with Bandit
        run: bandit receiver.py
EOF

echo "==== 4. Commit și Push pe GitHub (via SSH) ===="
git add .
git commit -m "Initial commit - Configurare baza si CI pipeline"
git branch -M main

# Eliminăm remote-ul vechi dacă există și îl adăugăm pe cel nou cu SSH
git remote remove origin 2>/dev/null
git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"

# Facem push folosind cheia SSH
git push -u origin main

echo "Tutorialul de bază a fost integrat cu succes prin SSH!"
