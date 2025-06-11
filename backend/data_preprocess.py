from cvzone.HandTrackingModule import HandDetector
import numpy as np
import math
import cv2

detector = HandDetector()
offset = 10
image_size = 400

def preprocess_image(image_bytes):
    numpy_array = np.frombuffer(image_bytes, dtype=np.uint8)
    original_image = cv2.imdecode(numpy_array, cv2.IMREAD_COLOR)
    rotated_90 = cv2.rotate(original_image, cv2.ROTATE_90_CLOCKWISE)
    hands, img = detector.findHands(rotated_90, draw=False)

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

            img_rgb = cv2.cvtColor(img_white, cv2.COLOR_BGR2RGB)
            return img_rgb
        return None
    return None
