import math
import numpy as np
import cv2
import json
import tensorflow as tf
from cvzone.HandTrackingModule import HandDetector

cap = cv2.VideoCapture(0)
detector = HandDetector()
model = tf.keras.models.load_model("tsl_model.keras")
offset = 20
image_size = 300

with open('class_labels.json', 'r') as f:
    class_labels = json.load(f)

while True:
    success, img = cap.read()
    img_output = img.copy()
    if not success:
        break

    hands, img = detector.findHands(img)

    if hands:
        img_height, img_width, _ = img.shape

        hand1 = hands[0]
        x, y, w, h = hand1['bbox']

        if len(hands) == 2:
            hand2 = hands[1]
            x2, y2, w2, h2 = hand2['bbox']
            x = min(x, x2)
            y = min(y, y2)
            w = w + w2
            h = h + h2

        x1 = max(0, x - offset)
        y1 = max(0, y - offset)
        x2 = min(img_width, x + w + offset)
        y2 = min(img_height, y + h + offset)

        img_white = np.ones((image_size, image_size, 3), np.uint8) * 255

        if x2 > x1 and y2 > y1:
            img_crop = img[y1:y2, x1:x2]
            img_crop_shape = img_crop.shape

            aspect_ratio = h / w

            if aspect_ratio > 1:
                k = image_size / h
                w_cal = math.ceil(k * w)
                img_resized = cv2.resize(img_crop, (w_cal, image_size))
                w_gap = math.ceil((image_size - w_cal) / 2)
                img_white[:, w_gap:w_gap + w_cal] = img_resized

            else:
                k = image_size / w
                h_cal = math.ceil(k * h)
                img_resized = cv2.resize(img_crop, (image_size, h_cal))
                h_gap = math.ceil((image_size - h_cal) / 2)
                img_white[h_gap:h_gap + h_cal, :] = img_resized

            img_input = img_white / 255.0
            prediction = model.predict(img_input.reshape(-1, 300, 300, 3))
            index = prediction.argmax()

            cv2.putText(img_output, class_labels[str(index)], (x1, y1 - 20), cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 2)
            cv2.rectangle(img_output, (x1, y1), (x2, y2), (0, 0, 255), 3)
            cv2.imshow("Image Crop", img_crop)
            cv2.imshow("Image White", img_white)
    cv2.imshow('Image', img_output)
    cv2.waitKey(1)
