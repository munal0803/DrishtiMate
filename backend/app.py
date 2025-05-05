from flask import Flask, request, jsonify
import threading
import cv2
import pyttsx3
import requests
import time
import numpy as np

app = Flask(__name__)

# Global variables
target_text = None
callback_url = None
detecting = False
object_to_find = None

text_speech = pyttsx3.init()

# Load class names
with open("coco.names", "r") as f:
    classNames = f.read().rstrip("\n").split("\n")

# Load model
configPath = 'ssd_mobilenet_v3_large_coco_2020_01_14.pbtxt'
weightsPath = 'frozen_inference_graph.pb'

net = cv2.dnn_DetectionModel(weightsPath, configPath)
net.setInputSize(320, 320)
net.setInputScale(1.0 / 127.5)
net.setInputMean((127.5, 127.5, 127.5))
net.setInputSwapRB(True)

def run_detection():
    global detecting
    cap = cv2.VideoCapture(0)
    cap.set(3, 1280)
    cap.set(4, 720)
    cap.set(10, 70)

    while detecting:
        success, img = cap.read()
        if not success:
            continue

        classIds, confs, bbox = net.detect(img, confThreshold=0.50)

        if len(classIds) != 0:
            for classId, confidence, box in zip(classIds.flatten(), confs.flatten(), bbox):
                label = classNames[classId - 1].lower()
                print("Detected:", label)
                if label == target_text:
                    try:
                        print(f"✅ Matched: {label}")
                        # text_speech.say(f"{label} found")
                        text_speech.runAndWait()
                        # requests.post(callback_url, json={"message": f"{label} found"})
                        
                    except Exception as e:
                        print("❌ Callback failed:", e)
                if detecting == False:
                    cap.release()
                    return
        time.sleep(0.1)

    cap.release()


@app.route('/detect_frame', methods=['POST'])
def detect_frame():
    global target_text, callback_url

    try:
        target_text = request.args.get("target_text", "").lower()
        callback_url = request.args.get("callback_url", "")
        image_data = request.files['image'].read()
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        classIds, confs, bbox = net.detect(img, confThreshold=0.6)

        if len(classIds) != 0:
            for classId in classIds.flatten():
                label = classNames[classId - 1].lower()
                print("Detected:", label)
                if label == target_text:
                    try:
                        print(f"✅ Matched: {label}")
                        requests.post(callback_url, json={"message": f"{target_text}"})
                        return jsonify({"message": f"{target_text}"}), 200  # ← SEND this back to Flutter
                    except Exception as e:
                        print("❌ Callback failed:", e)
                        return jsonify({"error": "callback failed"}), 500

        return jsonify({"status": "frame processed"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500




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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
