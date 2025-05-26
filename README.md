# 🤚 Hand Detection App

A real-time Hand Detection and Alphabet Recognition app built with **Flutter** and powered by a **Flask backend** and **machine learning** model. The app captures hand images, detects the hand sign, and returns the predicted alphabet using a deep learning model trained on custom hand gesture data.

---

## 📱 Features

- 📷 Captures hand sign images using the phone camera
- 🧠 Sends images to a Python Flask server for prediction
- 🔍 Uses a convolutional neural network (CNN) to recognize sign language alphabets
- 📡 Supports both local and internet-based communication (via Ngrok)
- 🧼 Handles errors like "No hand detected" gracefully
- 🔄 Realtime feedback and prediction display in the app

---

## 🛠 Tech Stack

### Frontend
- **Flutter** (Dart)
- `http` package for API calls
- Camera plugin for capturing images

### Backend
- **Flask** (Python)
- `flask-cors` for cross-origin requests
- Pre-trained CNN model for hand sign classification
- Base64 image handling and preprocessing

---

## 🔌 How It Works

1. The user opens the app and points the camera at a hand showing a sign.
2. The app captures the image and encodes it in base64.
3. The image is sent via a POST request to the Flask server.
4. The server decodes and preprocesses the image.
5. The CNN model predicts the corresponding alphabet.
6. The predicted result is returned and displayed on the app.

---

## 🧪 Example Request

**POST** `/predict`
```json
{
  "image": "base64_encoded_image_here"
}


{
  "prediction": "A"
}

