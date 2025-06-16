import cv2
from ultralytics import YOLO
from cvzone.HandTrackingModule import HandDetector

cap = cv2.VideoCapture(0)
detector = HandDetector()
model = YOLO('runs/detect/train/weights/best.pt')
offset = 20

while True:
    success, frame = cap.read()
    if not success:
        break

    hands, img = detector.findHands(frame, draw=False)

    if hands:
        img_height, img_width, _ = img.shape

        x, y, w, h = hands[0]['bbox']
        x2 = x + w
        y2 = y + h

        # Check for second hand
        if len(hands) == 2:
            x_b, y_b, w_b, h_b = hands[1]['bbox']
            x2_b = x_b + w_b
            y2_b = y_b + h_b

            x = min(x, x_b)
            y = min(y, y_b)
            x2 = max(x2, x2_b)
            y2 = max(y2, y2_b)

        # Apply offset
        x1 = max(0, x - offset)
        y1 = max(0, y - offset)
        x2 = min(img_width, x2 + offset)
        y2 = min(img_height, y2 + offset)

        if x2 > x1 and y2 > y1:
            img_crop = img[y1:y2, x1:x2].copy()
            if img_crop.shape[0] > 20 and img_crop.shape[1] > 20:
                gray = cv2.cvtColor(img_crop, cv2.COLOR_BGR2GRAY)
                gray_3ch = cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)
                results = model(gray_3ch, verbose=False)
                boxes = results[0].boxes
                if boxes and len(boxes) > 0:
                    confidences = boxes.conf

                    top_idx = confidences.argmax().item()
                    top_box = boxes[top_idx]

                    top_img = results[0].plot(boxes=[top_box])
                    cv2.imshow('Detection', top_img)

    cv2.imshow('Webcam', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
