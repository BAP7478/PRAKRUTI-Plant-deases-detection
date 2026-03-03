from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
from PIL import Image
import tensorflow as tf
import json
import io
import os
from typing import Optional
import asyncio
from concurrent.futures import ThreadPoolExecutor

app = FastAPI(title="🌱 PRAKRUTI Backend", description="Plant Disease Detection API")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Constants
IMG_SIZE = 224
MODEL_CACHE = {}
THREAD_POOL = ThreadPoolExecutor(max_workers=3)

# Load disease remedies once at startup
try:
    with open('disease_remedies.json', 'r') as f:
        REMEDIES = json.load(f)
except Exception as e:
    print(f"Error loading remedies: {e}")
    REMEDIES = {}

# Class names
CLASS_NAMES = [
    "Healthy",
    "Late_blight",
    "Powdery_mildew"
]

def load_tflite_model():
    """Load and cache TFLite model"""
    if 'tflite' not in MODEL_CACHE:
        try:
            interpreter = tf.lite.Interpreter(model_path='models/mobilenet_model.tflite')
            interpreter.allocate_tensors()
            MODEL_CACHE['tflite'] = {
                'interpreter': interpreter,
                'input_details': interpreter.get_input_details(),
                'output_details': interpreter.get_output_details()
            }
            print("✅ TFLite model loaded successfully")
        except Exception as e:
            print(f"❌ Error loading TFLite model: {e}")
            return None
    return MODEL_CACHE['tflite']

def load_full_model():
    """Load and cache full model"""
    if 'full' not in MODEL_CACHE:
        try:
            model = tf.keras.models.load_model('models/resnet50_model.h5')
            # Add preprocessing layer to the model
            model = tf.keras.Sequential([
                tf.keras.layers.Lambda(lambda x: tf.cast(x, tf.float32) / 255.0),
                model
            ])
            MODEL_CACHE['full'] = model
            print("✅ Full model loaded successfully")
        except Exception as e:
            print(f"❌ Error loading full model: {e}")
            return None
    return MODEL_CACHE['full']

async def preprocess_image(image_bytes):
    """Preprocess image asynchronously"""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(THREAD_POOL, _preprocess_image, image_bytes)

def _preprocess_image(image_bytes):
    """Synchronous image preprocessing"""
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = image.resize((IMG_SIZE, IMG_SIZE))
    img_array = np.array(image, dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

async def predict_tflite(image_array):
    """Run TFLite prediction asynchronously"""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(THREAD_POOL, _predict_tflite, image_array)

def _predict_tflite(image_array):
    """Synchronous TFLite prediction"""
    model_info = load_tflite_model()
    if not model_info:
        raise Exception("TFLite model not loaded")
    
    interpreter = model_info['interpreter']
    interpreter.set_tensor(model_info['input_details'][0]['index'], image_array)
    interpreter.invoke()
    predictions = interpreter.get_tensor(model_info['output_details'][0]['index'])
    return predictions[0]

# Cache for prediction results
prediction_cache = {}

@app.on_event("startup")
async def startup_event():
    """Load models on startup"""
    load_tflite_model()
    load_full_model()

@app.get("/")
def root():
    return {"message": "🌱 PRAKRUTI backend is running!"}

@app.get("/health")
def health_check():
    tflite_loaded = 'tflite' in MODEL_CACHE
    full_model_loaded = 'full' in MODEL_CACHE
    return {
        "status": "ok",
        "tflite_model": "loaded" if tflite_loaded else "not loaded",
        "full_model": "loaded" if full_model_loaded else "not loaded"
    }

@app.post("/predict")
async def predict(file: UploadFile = File(...), mobile: bool = True):
    try:
        contents = await file.read()
        
        # Check cache using file contents hash
        file_hash = hash(contents)
        if file_hash in prediction_cache:
            return prediction_cache[file_hash]

        # Preprocess image
        img_array = await preprocess_image(contents)
        
        # Use TFLite model for faster inference
        predictions = await predict_tflite(img_array)
        
        # Get results
        class_idx = int(np.argmax(predictions))
        confidence = float(predictions[class_idx])
        predicted_class = CLASS_NAMES[class_idx]
        
        # Get remedies
        remedies = REMEDIES.get(predicted_class, {
            "remedies": ["No specific remedies available."],
            "prevention": ["General plant care recommended."]
        })
        
        result = {
            "predicted_class": predicted_class,
            "confidence": confidence,
            "remedies": remedies.get("remedies", []),
            "prevention": remedies.get("prevention", [])
        }
        
        # Cache the result
        prediction_cache[file_hash] = result
        
        # Clean old cache entries if cache is too large
        if len(prediction_cache) > 100:
            prediction_cache.clear()
        
        return result
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"error": f"Prediction failed: {str(e)}"}
        )

@app.get("/recommend/{disease}")
def recommend(disease: str):
    try:
        remedies = REMEDIES.get(disease, {
            "remedies": [],
            "prevention": []
        })
        return remedies
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Disease {disease} not found")

@app.get("/model_versions")
def model_versions():
    return {
        "mobile_model": "TFLite-Optimized",
        "backend_model": "ResNet50-Optimized",
        "image_size": IMG_SIZE,
        "supported_classes": CLASS_NAMES
    }
