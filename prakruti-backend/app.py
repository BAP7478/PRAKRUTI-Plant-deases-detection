from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from PIL import Image
import tensorflow as tf
import json
import io
import os
import time
from typing import Dict
import re

app = FastAPI(title="🌱 PRAKRUTI Backend", description="Plant Disease Detection API")

# Load disease remedies
try:
    with open('disease_remedies.json', 'r') as f:
        REMEDIES = json.load(f)
except Exception as e:
    print(f"Error loading remedies: {e}")
    REMEDIES = {}

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Hardcoded credentials (for demo purposes - in production use secure storage)
VALID_CREDENTIALS = {
    "admin7478": {"password": "7478", "role": "admin"},
    "demo@prakruti.com": {"password": "Demo@2024", "role": "user"}
}

# Load model and class names
MODEL_PATH = 'models/resnet50_model.h5'
MOBILE_MODEL_PATH = 'models/mobilenet_model.tflite'

# Class names (update according to your dataset)
CLASS_NAMES = [
    "Healthy",
    "Late_blight",
    "Powdery_mildew"
]

try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print(f"✅ Model loaded successfully from {MODEL_PATH}")
    
    # Load TFLite model for mobile
    with open(MOBILE_MODEL_PATH, 'rb') as f:
        mobile_model = f.read()
    interpreter = tf.lite.Interpreter(model_content=mobile_model)
    interpreter.allocate_tensors()
    print("✅ Mobile model loaded successfully")
    
except Exception as e:
    print(f"❌ Error loading models: {e}")
    model = None
    interpreter = None

# Load the model and remedies data
import tensorflow as tf
import json

# Load disease remedies
with open('disease_remedies.json', 'r') as f:
    REMEDIES = json.load(f)

# Load the model (using ResNet50 for production)
try:
    model = tf.keras.models.load_model('models/resnet50_model.h5')
    print("✅ Model loaded successfully")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    # Fallback to dummy predictions if model fails to load
    def dummy_predict(image_array):
        import random
        class_idx = random.randint(0, len(CLASS_NAMES) - 1)
        confidence = random.uniform(0.7, 0.99)
        return class_idx, confidence
    model = None

def predict_disease(image_array):
    """Predict plant disease from image array"""
    if model is None:
        return dummy_predict(image_array)
        
    # Make prediction
    pred = model.predict(image_array, verbose=0)
    class_idx = np.argmax(pred[0])
    confidence = float(pred[0][class_idx])
    return class_idx, confidence

# Root endpoint
@app.get("/")
def root():
    return {"message": "🌱 PRAKRUTI backend is running!"}

# Health check
@app.get("/health")
def health_check():
    return {"status": "ok"}

# Authentication endpoint
@app.post("/auth/login")
async def login(credentials: dict):
    email = credentials.get("email")
    password = credentials.get("password")
    
    if not email or not password:
        raise HTTPException(status_code=400, detail="Email and password required")
    
    user = VALID_CREDENTIALS.get(email)
    if not user or user["password"] != password:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    return {
        "status": "success",
        "role": user["role"],
        "message": "Login successful"
    }

# Prediction endpoint
@app.post("/predict")
async def predict(file: UploadFile = File(...), mobile: bool = False):
    try:
        # Read and preprocess image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        image = image.resize((224, 224))  # resize to match model input
        img_array = np.array(image) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        if mobile and interpreter is not None:
            # Use TFLite model for mobile
            input_details = interpreter.get_input_details()
            output_details = interpreter.get_output_details()
            
            interpreter.set_tensor(input_details[0]['index'], img_array)
            interpreter.invoke()
            predictions = interpreter.get_tensor(output_details[0]['index'])
            class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][class_idx])
        elif model is not None:
            # Use full model for backend
            predictions = model.predict(img_array, verbose=0)
            class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][class_idx])
        else:
            return JSONResponse(
                status_code=500,
                content={"error": "Models not loaded. Please check server logs."}
            )

        predicted_class = CLASS_NAMES[class_idx]
        remedies = REMEDIES.get(predicted_class, ["No specific remedies available."])
        
        return {
            "predicted_class": predicted_class,
            "confidence": confidence,
            "remedies": remedies
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# Remedies (dummy for now, extend with real data)
@app.get("/recommend/{disease}")
def recommend(disease: str):
    remedies = {
        "Powdery Mildew": "Use sulfur fungicides. Ensure proper air circulation.",
        "Leaf Rust": "Apply neem oil. Avoid overhead watering.",
        "Bacterial Spot": "Use copper-based bactericides. Remove infected leaves.",
        "Early Blight": "Use fungicides with chlorothalonil. Crop rotation helps.",
        "Late Blight": "Apply mancozeb fungicide. Destroy infected plants.",
        "Healthy": "No treatment needed. Keep monitoring your plant."
    }
    return {"disease": disease, "remedy": remedies.get(disease, "No remedy found.")}

# Initialize chat handler
from chat_handler import ChatHandler
chat_handler = ChatHandler(REMEDIES)

# Chat endpoint
@app.post("/chat")
async def chat(request: Dict):
    try:
        message = request.get("message")
        if not message:
            raise HTTPException(status_code=400, detail="Message is required")
            
        response = chat_handler.get_response(message)
        return {"response": response}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# Model version endpoint
@app.get("/model_versions")
def model_versions():
    return {
        "current_model": "ResNet50",
        "available_models": ["ResNet50", "MobileNetV2", "EfficientNetB0"]
    }
