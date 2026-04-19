from fastapi import FastAPI, UploadFile, File
from fastapi.responses import RedirectResponse
import uvicorn
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import os
import threading
import urllib.request

# 1. Initialize the App
app = FastAPI(title="Crop Disease Classification API")

# 2. Load the Model
print("Loading model...")
model = tf.keras.models.load_model('/content/drive/MyDrive/Crop_Disease_Project/crop_disease_model.keras')
# 3. AUTO-LOCATE the exact class names
def find_plant_data():
    for root, dirs, files in os.walk('/content'):
        if any("Tomato" in d or "Potato" in d for d in dirs):
            return root
    return None

DATASET_DIR = find_plant_data()

if DATASET_DIR is None:
    print("⚠️ Dataset folders not found. Using permanent hardcoded classes.")
    
    # 🔴 YOU UPDATE IT RIGHT HERE!
    class_names = [
        'Potato___Early_blight', 
        'Potato___Late_blight', 
        'Potato___healthy', 
        'Tomato_Bacterial_spot', 
        'Tomato_healthy'
    ] 
else:
    class_names = sorted([d for d in os.listdir(DATASET_DIR) if os.path.isdir(os.path.join(DATASET_DIR, d))])
    print(f"✅ Successfully loaded {len(class_names)} actual disease classes.")
    
# 4. Bulletproof Image Processor
def prepare_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes))
    
    # Force RGB format to prevent 500 errors on weird image types
    if img.mode != 'RGB':
        img = img.convert('RGB')
        
    img = img.resize((128, 128))
    img_array = tf.keras.utils.img_to_array(img)
    img_array = tf.expand_dims(img_array, 0)
    return img_array

# 5. Friendly Homepage Redirect
@app.get("/")
async def root():
    return RedirectResponse(url="/docs")

# 6. The Prediction Endpoint
@app.post("/predict")
async def predict_disease(file: UploadFile = File(...)):
    image_bytes = await file.read()
    processed_image = prepare_image(image_bytes)
    
    predictions = model.predict(processed_image, verbose=0)
    score = tf.nn.softmax(predictions[0])
    
    predicted_class = class_names[np.argmax(score)]
    confidence = float(np.max(score)) * 100
    
    return {
        "filename": file.filename,
        "prediction": predicted_class,
        "confidence": f"{confidence:.2f}%"
    }

# ==========================================
# 7. Start the Server & Expose via Localtunnel
# ==========================================
def run_server():
    uvicorn.run(app, host="0.0.0.0", port=8050)

if __name__ == "__main__":
    print("🌍 Starting local server in the background...")
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()
    
    os.system("npm install -g localtunnel")
    
    ip = urllib.request.urlopen('https://ipv4.icanhazip.com').read().decode('utf8').strip("\n")
    print(f"\n🔑 YOUR TUNNEL PASSWORD IS: {ip}")
    print("--------------------------------------------------")
    print("1. Click the 'loca.lt' link that appears below.")
    print("2. Paste your Tunnel Password into the webpage.")
    print("3. Add '/docs' if it doesn't redirect automatically.")
    print("--------------------------------------------------\n")
    
    !lt --port 8050