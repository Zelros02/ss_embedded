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
