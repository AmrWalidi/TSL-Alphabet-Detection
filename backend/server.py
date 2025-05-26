import base64
from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import json
from data_preprocess import preprocess_image

app = Flask(__name__)
CORS(app)

model = tf.keras.models.load_model('tsl_model.keras')

with open('labels.json', 'r') as f:
    class_labels = json.load(f)


@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if not data or 'image' not in data:
        return jsonify({'error': 'No image provided'}), 400

    try:
        image_data = base64.b64decode(data['image'])
        img = preprocess_image(image_data)
        if img is None:
            return jsonify({'error': 'No hand detected'}), 400

        prediction = model.predict(img)
        index = prediction.argmax()
        return jsonify({'prediction': str(class_labels[str(index)])})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
