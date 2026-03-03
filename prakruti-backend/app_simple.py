from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import numpy as np
from PIL import Image
import io

app = FastAPI(title="🌱 PRAKRUTI Backend", description="Plant Disease Detection API")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple class names for testing
CLASS_NAMES = [
    "Healthy",
    "Late_blight",
    "Powdery_mildew"
]

# Simple remedies for testing
REMEDIES = {
    "Healthy": ["Keep monitoring your plant", "Maintain regular watering schedule"],
    "Late_blight": ["Remove infected leaves", "Apply fungicide", "Improve air circulation"],
    "Powdery_mildew": ["Use sulfur-based fungicide", "Reduce humidity", "Space plants properly"]
}

@app.get("/")
def root():
    return {"message": "🌱 PRAKRUTI backend is running!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # Read and validate image
        contents = await file.read()
        if not contents:
            raise ValueError("Empty file")
            
        # Process image
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        image = image.resize((224, 224))
        
        # For testing, return a random prediction
        import random
        class_idx = random.randint(0, len(CLASS_NAMES) - 1)
        predicted_class = CLASS_NAMES[class_idx]
        confidence = random.uniform(0.7, 0.95)
        
        remedies = REMEDIES.get(predicted_class, ["No specific remedies available."])
        
        return {
            "predicted_class": predicted_class,
            "confidence": confidence,
            "remedies": remedies
        }
    except Exception as e:
        print(f"Error processing image: {e}")
        return JSONResponse(
            status_code=500,
            content={"error": f"Failed to process image: {str(e)}"}
        )

@app.get("/recommend/{disease}")
def recommend(disease: str):
    remedies = REMEDIES.get(disease, ["No specific remedies available."])
    return {"disease": disease, "remedies": remedies}
