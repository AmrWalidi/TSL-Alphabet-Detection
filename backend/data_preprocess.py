from cvzone.HandTrackingModule import HandDetector
import numpy as np
import cv2

detector = HandDetector()
offset = 10

def preprocess_image(image_bytes):
    numpy_array = np.frombuffer(image_bytes, dtype=np.uint8)
    original_image = cv2.imdecode(numpy_array, cv2.IMREAD_COLOR)
    rotated_90 = cv2.rotate(original_image, cv2.ROTATE_90_CLOCKWISE)
    hands, img = detector.findHands(rotated_90, draw=False)

    if hands:
        img_height, img_width, _ = img.shape

        x, y, w, h = hands[0]['bbox']
        x2 = x + w
        y2 = y + h

        if len(hands) == 2:
            x_b, y_b, w_b, h_b = hands[1]['bbox']
            x2_b = x_b + w_b
            y2_b = y_b + h_b

            x = min(x, x_b)
            y = min(y, y_b)
            x2 = max(x2, x2_b)
            y2 = max(y2, y2_b)

        x1 = max(0, x - offset)
        y1 = max(0, y - offset)
        x2 = min(img_width, x2 + offset)
        y2 = min(img_height, y2 + offset)

        if x2 > x1 and y2 > y1:
            img_crop = img[y1:y2, x1:x2]
            if img_crop.shape[0] > 20 and img_crop.shape[1] > 20:
                gray = cv2.cvtColor(img_crop, cv2.COLOR_BGR2GRAY)
                gray_3ch = cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)
                return gray_3ch
        return None
    return None
