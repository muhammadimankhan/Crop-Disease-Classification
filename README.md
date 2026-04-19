# 🍃 Crop Disease Scanner

An end-to-end, AI-powered mobile application and backend system designed to detect and classify plant diseases from leaf images in real-time. 

This repository contains the complete full-stack architecture, including a custom Deep Learning model, a high-performance web API, and a cross-platform mobile interface.

## ✨ Features
* **Advanced AI Vision:** Utilizes a custom Convolutional Neural Network (CNN) trained to classify 15 distinct classes of Tomato and Potato conditions (including early blight, late blight, bacterial spot, and healthy leaves).
* **High-Speed Backend:** Powered by an asynchronous FastAPI server for rapid image processing and real-time inference.
* **Cross-Platform Mobile App:** A sleek, user-friendly Flutter application allowing users to snap photos or upload from their gallery for an instant diagnosis.
* **Robust Error Handling:** Bulletproof image preprocessing to handle varying color channels, dimensions, and formats automatically.

## 🛠️ Tech Stack
* **Frontend:** Flutter, Dart, `http`, `image_picker`
* **Backend:** Python 3, FastAPI, Uvicorn, Localtunnel
* **Machine Learning:** TensorFlow, Keras, NumPy, Pillow (PIL)

## 🏗️ System Architecture
1. **Mobile Client:** The Flutter app captures an image and sends it via an HTTP `POST` request (Multipart Form Data).
2. **API Layer:** FastAPI receives the payload and standardizes the image into a 3-channel RGB, 128x128 tensor.
3. **AI Engine:** The `.keras` TensorFlow model runs inference on the tensor to calculate class probabilities using softmax.
4. **Response:** The backend formats the highest-confidence prediction into a JSON object and routes it back to the mobile client for immediate display.

## 🚀 Getting Started

### 1. Backend Setup
1. Navigate to the `backend/` directory.
2. Ensure your trained `crop_disease_model.keras` file is placed in this directory.
3. Install the required Python packages:
   ```bash
   pip install fastapi uvicorn python-multipart pillow tensorflow numpy nest_asyncio
4. Start the server (if running locally):
   ```bash
    uvicorn main:app --host 0.0.0.0 --port 8050
### 2. Frontend Setup
1. Navigate to the flutter_app/ directory.
2. Open lib/main.dart and update the apiUrl variable to match your live backend URL (ensure it ends with /predict).
3. Install dependencies:
   ```bash
   flutter pub get
4. Run the app on an emulator or a physical device:
   ```bash
   flutter run
👨‍💻 Author
**Muhammad Iman Khan** BS Computer Science | Bahria University, Lahore Developed as a comprehensive project demonstrating full-stack engineering, scalable AI deployment, and modern mobile application architecture.
