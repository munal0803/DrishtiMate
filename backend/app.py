from flask import Flask, request, jsonify
import threading
import cv2
import time
import numpy as np
from ultralytics import YOLO
import requests
import pyttsx3

app = Flask(__name__)

# Global variables
target_text = None
callback_url = None
detecting = False

text_speech = pyttsx3.init()

# Load YOLOv8 model
model = YOLO("yolov8n.pt")  # You can also use yolov8s.pt, yolov8m.pt, etc.

def run_detection():
    global detecting
    cap = cv2.VideoCapture(0)

    while detecting:
        ret, frame = cap.read()
        if not ret:
            continue

        results = model(frame, verbose=False)

        for result in results:
            for box in result.boxes:
                cls = int(box.cls[0])
                label = model.names[cls].lower()
                print("Detected:", label)

                if label == target_text:
                    try:
                        print(f"✅ Matched: {label}")
                        text_speech.say(f"{label} found")
                        text_speech.runAndWait()
                        if callback_url:
                            requests.post(callback_url, json={"message": f"{label} found"})
                    except Exception as e:
                        print("❌ Callback failed:", e)
        time.sleep(0.1)

    cap.release()

@app.route('/start_detection', methods=['POST'])
def start_detection():
    global target_text, callback_url, detecting

    data = request.get_json()
    target_text = data.get('text', '').lower()
    callback_url = data.get('callback_url')

    if not target_text or not callback_url:
        return jsonify({"error": "Missing 'text' or 'callback_url'"}), 400

    if not detecting:
        detecting = True
        thread = threading.Thread(target=run_detection, daemon=True)
        thread.start()

    return jsonify({"message": f"Started detecting '{target_text}'"})

@app.route('/stop_detection', methods=['POST'])
def stop_detection():
    global detecting
    detecting = False
    return jsonify({"message": "Detection stopped"})

@app.route('/detect_frame', methods=['POST'])
def detect_frame():
    global target_text, callback_url
    try:
        target_text = request.args.get("target_text", "").lower()
        callback_url = request.args.get("callback_url", "")
        image_data = request.files['image'].read()
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        results = model(img, verbose=False)

        for result in results:
            for box in result.boxes:
                cls = int(box.cls[0])
                label = model.names[cls].lower()
                print("Detected:", label)
                if label == target_text:
                    try:
                        print(f"✅ Matched: {label}")
                        requests.post(callback_url, json={"message": f"{target_text}"})
                        return jsonify({"message": f"{target_text}"}), 200
                    except Exception as e:
                        print("❌ Callback failed:", e)
                        return jsonify({"error": "callback failed"}), 500

        return jsonify({"status": "frame processed"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
