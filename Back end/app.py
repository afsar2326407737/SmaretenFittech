# app.py
from flask import Flask, request, jsonify
import cv2
import mediapipe as mp
import tempfile
import os

app = Flask(__name__)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True)

@app.route("/analyze-pose", methods=["POST"])
def analyze_pose():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]

    #temp saving 
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        file.save(tmp.name)
        image_path = tmp.name

    #read image
    image = cv2.imread(image_path)
    if image is None:
        return jsonify({"error": "Invalid image"}), 400

    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    #media pipe processing
    results = pose.process(image_rgb)

    keypoints = []
    if results.pose_landmarks:
        for lm in results.pose_landmarks.landmark:
            keypoints.append({
                "x": lm.x,
                "y": lm.y,
                "z": lm.z,
                "visibility": lm.visibility
            })

    os.remove(image_path)# cleare the temp image

    return jsonify({"keypoints": keypoints})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
