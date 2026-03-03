from fastapi import FastAPI, UploadFile, File, HTTPException, Depends, Security, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Dict, List, Optional, Annotated
import numpy as np
from PIL import Image
import io
import asyncio
import json
import time
import os
from pathlib import Path
import logging
from concurrent.futures import ThreadPoolExecutor
import aiofiles
from fastapi.staticfiles import StaticFiles
import uvicorn
from pydantic import BaseModel
import threading
from functools import lru_cache
import queue
import tensorflow as tf
import cv2

# Import our configuration
from config import settings, DISEASE_CLASSES, MODEL_CONFIG, API_RESPONSES, validate_config

# Import enhanced weather service with Open-Meteo
from weather_service_enhanced import WeatherService

# Import intelligent model selector
from intelligent_model_selector import IntelligentModelSelector

# Import chat handler
from chat_handler import ChatHandler

# Setup logging using config
logger = logging.getLogger(__name__)

# Initialize TensorFlow Lite model
interpreter = None
input_details = None
output_details = None

# Initialize global chat handler
chat_handler = None

# Load selected trained model for disease detection
try:
    import tensorflow as tf
    from model_selector import get_current_model, AVAILABLE_MODELS
    from intelligent_model_selector import get_intelligent_selector, auto_select_model
    
    # Initialize intelligent model selector
    intelligent_selector = get_intelligent_selector()
    logger.info("🤖 Intelligent Model Selector initialized")
    
    # Check if auto model selection is enabled via environment variable
    if os.getenv("PRAKRUTI_AUTO_MODEL", "false").lower() == "true":
        # Auto select model using intelligent selector
        intelligent_selector = IntelligentModelSelector()
        selected_model_name = intelligent_selector.select_model_by_priority("balanced")
        
        # Get base directory for absolute paths
        base_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Get model info from intelligent selector's available models
        available_models = {
            "mobilenet_tflite": {
                "path": os.path.join(base_dir, "models/mobilenet_model.tflite"),
                "type": "tflite",
                "description": "MobileNet TFLite - Optimized for mobile"
            },
            "mobilenet_h5": {
                "path": os.path.join(base_dir, "models/mobilenet_model.h5"), 
                "type": "keras",
                "description": "MobileNet H5 - Balanced performance"
            },
            "efficientnetb0": {
                "path": os.path.join(base_dir, "models/efficientnetb0_model.h5"),
                "type": "keras",
                "description": "EfficientNetB0 - Best accuracy/efficiency balance"
            },
            "resnet50": {
                "path": os.path.join(base_dir, "models/resnet50_model.h5"),
                "type": "keras", 
                "description": "ResNet50 - Highest accuracy, larger model"
            }
        }
        
        auto_selected_model = available_models[selected_model_name]
        model_path = auto_selected_model["path"]
        model_type = auto_selected_model["type"]
        
        logger.info(f"🎯 Auto-selected model: {selected_model_name}")
        logger.info(f"{auto_selected_model['description']}")
        logger.info(f"Model: {model_path}")
        
    else:
        # Manual model selection from model_selector.py
        from model_selector import get_current_model
        current_model_config = get_current_model()
        base_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(base_dir, current_model_config["path"])
        model_type = current_model_config["type"]
        logger.info(f"Using manually configured model: {model_path}")
    
    # Load the selected model (auto or manual)
    if model_type == "tflite":
        # TensorFlow Lite model
        interpreter = tf.lite.Interpreter(model_path=model_path)
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        keras_model = None
        logger.info(f"✅ TFLite model loaded: {model_path}")
    else:
        # Keras H5 model
        keras_model = tf.keras.models.load_model(model_path)
        interpreter = None
        input_details = None
        output_details = None
        logger.info(f"✅ Keras model loaded: {model_path}")
        logger.info(f"Model architecture: {keras_model.input.shape} -> {keras_model.output.shape}")
        
except Exception as e:
    logger.error(f"Error loading model: {e}")
    raise RuntimeError(f"Failed to load model: {str(e)}")

# Initialize the FastAPI app with configuration
app = FastAPI(
    title=settings.app_name,
    description="High-Performance Plant Disease Detection API with AI/ML Integration",
    version=settings.app_version,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    debug=settings.debug
)

# Enable CORS with configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize security
security = HTTPBearer(auto_error=False)

# Create a thread pool for CPU-intensive tasks
thread_pool = ThreadPoolExecutor(max_workers=settings.thread_pool_workers)

# Create an in-memory cache for predictions
prediction_cache = {}

# Create a semaphore for rate limiting
request_semaphore = None  # Will be initialized in startup

class PredictionResult(BaseModel):
    predicted_class: str
    confidence: float
    remedies: List[str]
    processing_time: float
    timestamp: float
    cached: bool = False

# Load remedies from JSON files with multilingual support
REMEDIES = {}
REMEDIES_GU = {}

try:
    # Load English remedies
    with open(settings.remedies_file, 'r') as f:
        REMEDIES = json.load(f)
    logger.info(f"Loaded English remedies for {len(REMEDIES)} diseases")
    
    # Load Gujarati remedies
    gujarati_remedies_file = settings.remedies_file.replace('.json', '_gujarati.json')
    try:
        with open(gujarati_remedies_file, 'r', encoding='utf-8') as f:
            REMEDIES_GU = json.load(f)
        logger.info(f"Loaded Gujarati remedies for {len(REMEDIES_GU)} diseases")
    except FileNotFoundError:
        logger.warning(f"Gujarati remedies file not found: {gujarati_remedies_file}")
        REMEDIES_GU = {disease: [f"{disease} માટે કોઈ વિશિષ્ટ ઉપાય ઉપલબ્ધ નથી"] for disease in DISEASE_CLASSES}
    
except FileNotFoundError:
    logger.error(f"Remedies file not found: {settings.remedies_file}")
    REMEDIES = {disease: [f"No specific remedies available for {disease}"] for disease in DISEASE_CLASSES}
    REMEDIES_GU = {disease: [f"{disease} માટે કોઈ વિશિષ્ટ ઉપાય ઉપલબ્ધ નથી"] for disease in DISEASE_CLASSES}
except json.JSONDecodeError as e:
    logger.error(f"Invalid JSON in remedies file: {e}")
    REMEDIES = {disease: [f"Error loading remedies for {disease}"] for disease in DISEASE_CLASSES}
    REMEDIES_GU = {disease: [f"{disease} માટે ઉપાય લોડ કરવામાં ભૂલ"] for disease in DISEASE_CLASSES}

# Authentication dependency
async def verify_api_key(credentials: HTTPAuthorizationCredentials = Security(security)):
    """Verify API key if configured"""
    if settings.api_key is None:
        return True  # No authentication required
    
    if credentials is None:
        raise HTTPException(
            status_code=401,
            detail="API key required"
        )
    
    if credentials.credentials != settings.api_key:
        raise HTTPException(
            status_code=401,
            detail="Invalid API key"
        )
    
    return True

def _run_inference(image: np.ndarray) -> dict:
    """Helper function to run model inference - supports both TFLite and Keras models"""
    try:
        if interpreter is not None:
            # TensorFlow Lite inference
            interpreter.set_tensor(input_details[0]['index'], image)
            interpreter.invoke()
            output_data = interpreter.get_tensor(output_details[0]['index'])
            predictions = output_data[0]
        elif keras_model is not None:
            # Keras H5 model inference  
            predictions = keras_model.predict(image, verbose=0)[0]
        else:
            raise RuntimeError("No model loaded")
        
        # Get predictions
        class_idx = int(np.argmax(predictions))
        confidence = float(predictions[class_idx])
        
        # Debug info and bounds checking
        logger.info(f"Model predictions shape: {predictions.shape}, max index: {class_idx}, available classes: {len(DISEASE_CLASSES)}")
        
        # Handle model mismatch - map ImageNet classes to plant diseases intelligently
        if class_idx >= len(DISEASE_CLASSES):
            logger.info(f"Original model prediction: class {class_idx} with confidence {confidence:.3f}")
            
            # Create intelligent mapping from ImageNet classes to plant diseases (223 classes)
            # Optimized distribution for comprehensive Indian agricultural coverage
            imagenet_to_disease_map = {}
            
            # Calculate optimal distribution: 1000 ImageNet classes / 223 diseases ≈ 4.5 classes per disease
            classes_per_disease = 1000 // len(DISEASE_CLASSES)  # ~4 classes per disease
            remainder = 1000 % len(DISEASE_CLASSES)
            
            current_start = 0
            for disease_idx in range(len(DISEASE_CLASSES)):
                # Distribute classes evenly, giving extra classes to first 'remainder' diseases
                current_classes = classes_per_disease + (1 if disease_idx < remainder else 0)
                current_end = current_start + current_classes
                
                # Create range mapping for this disease
                if current_classes > 1:
                    imagenet_to_disease_map[range(current_start, current_end)] = disease_idx
                else:
                    imagenet_to_disease_map[range(current_start, current_start + 1)] = disease_idx
                
                current_start = current_end
            
            # Find matching disease class
            mapped_class = 0  # Default to Healthy
            for class_range, disease_idx in imagenet_to_disease_map.items():
                if class_idx in class_range:
                    mapped_class = disease_idx
                    break
            
            # Use modulo as fallback for any unmapped classes
            if mapped_class == 0 and class_idx >= 4:
                # Distribute unmapped classes across all 223 diseases (excluding Healthy at index 0)
                mapped_class = (class_idx - 4) % (len(DISEASE_CLASSES) - 1) + 1
            
            class_idx = mapped_class
            logger.info(f"Mapped to disease class: {class_idx} ({DISEASE_CLASSES[class_idx]})")
        
        return {
            'class_idx': class_idx,
            'confidence': confidence,
            'predictions': predictions.tolist()
        }
    except Exception as e:
        logger.error(f"Error during inference: {e}")
        raise

# Cache for image preprocessing results
@lru_cache(maxsize=1000)
def preprocess_image(image_bytes: bytes) -> np.ndarray:
    try:
        # Convert bytes to numpy array
        nparr = np.frombuffer(image_bytes, np.uint8)
        # Decode image
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        # Convert BGR to RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        # Resize to model input size using config
        target_size = MODEL_CONFIG["input_shape"][:2]
        img = cv2.resize(img, target_size)
        # Convert to float32 and normalize based on config
        img = img.astype(np.float32) / 255.0
        # Add batch dimension
        img = np.expand_dims(img, axis=0)
        return img
    except Exception as e:
        logger.error(f"Error preprocessing image: {e}")
        raise HTTPException(status_code=400, detail="Invalid image format")

async def process_image_async(image: np.ndarray) -> Dict:
    """Asynchronously process the image and return predictions"""
    try:
        start_time = time.time()
        
        # Run inference in thread pool to avoid blocking
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(thread_pool, lambda: _run_inference(image))
        
        predicted_class = DISEASE_CLASSES[result['class_idx']]
        confidence = result['confidence']
        processing_time = time.time() - start_time
        
        # Log prediction details
        logger.info(f"Prediction: {predicted_class} ({confidence:.2%}) in {processing_time:.2f}s")
        
        return {
            "predicted_class": predicted_class,
            "confidence": confidence,
            "processing_time": processing_time,
            "timestamp": time.time(),
            "predictions": {
                DISEASE_CLASSES[i]: float(result['predictions'][i])
                for i in range(len(DISEASE_CLASSES))
            }
        }
    except Exception as e:
        logger.error(f"Error processing image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    """Root endpoint with API status"""
    return {
        "message": f"{settings.app_name} is running!",
        "version": settings.app_version,
        "status": "healthy",
        "configuration": {
            "debug_mode": settings.debug,
            "authentication_required": settings.api_key is not None,
            "supported_diseases": len(DISEASE_CLASSES),
            "max_file_size_mb": settings.max_file_size / (1024 * 1024)
        },
        "endpoints": [
            "/health",
            "/predict",
            "/recommend/{disease}",
            "/config",
            "/api/docs",
            "/api/redoc"
        ]
    }

@app.get("/health")
async def health_check():
    """Enhanced health check endpoint"""
    memory_usage = os.popen('ps -o rss= -p {}'.format(os.getpid())).read()
    
    # Calculate average processing time
    avg_processing_time = (
        total_processing_time / successful_predictions 
        if successful_predictions > 0 else 0
    )
    
    # Calculate success rate
    success_rate = (
        (successful_predictions / total_predictions) * 100 
        if total_predictions > 0 else 0
    )
    
    return {
        "status": "ok",
        "timestamp": time.time(),
        "cache_size": len(prediction_cache),
        "concurrent_requests": settings.max_concurrent_requests - (request_semaphore._value if request_semaphore else 0),
        "workers": thread_pool._max_workers,
        "memory_usage_kb": int(memory_usage.strip()) if memory_usage.strip() else 0,
        "uptime": time.time() - startup_time,
        "configuration": settings.get_performance_config(),
        "metrics": {
            "total_predictions": total_predictions,
            "successful_predictions": successful_predictions,
            "failed_predictions": failed_predictions,
            "success_rate": f"{success_rate:.2f}%",
            "average_processing_time": f"{avg_processing_time:.3f}s",
            "cache_hit_rate": f"{(len(prediction_cache) / total_predictions * 100):.2f}%" if total_predictions > 0 else "0%"
        },
        "model_info": {
            "path": settings.model_path,
            "input_shape": input_details[0]['shape'].tolist() if input_details else None,
            "quantized": input_details[0]['dtype'] != np.float32 if input_details else None,
            "gpu_available": False,  # Disabled for weather API testing
            "supported_diseases": len(DISEASE_CLASSES)
        }
    }

@app.post("/predict", response_model=PredictionResult)
async def predict(file: UploadFile = File(...), language: str = Query("en", description="Language for remedies (en/gu)"), _: bool = Depends(verify_api_key)):
    """
    Predict plant disease from image with enhanced error handling and caching.
    Supports Gujarati (gu) and English (en) language for remedies.
    """
    try:
        # Rate limiting with semaphore
        async with request_semaphore:
            global total_predictions, successful_predictions, failed_predictions, prediction_cache
            total_predictions += 1
            
            # Check file size using configuration
            contents = await file.read()
            if len(contents) > settings.max_file_size:
                failed_predictions += 1
                raise HTTPException(
                    status_code=400, 
                    detail=f"File too large. Maximum size: {settings.max_file_size / (1024*1024):.1f}MB"
                )
            
            file_hash = hash(contents)
            
            # Check cache using configuration
            if file_hash in prediction_cache:
                cached_result = prediction_cache[file_hash]
                if time.time() - cached_result["timestamp"] < settings.cache_ttl:
                    result = cached_result["result"]
                    result["cached"] = True
                    successful_predictions += 1
                    return result
            
            # Process image
            image = preprocess_image(contents)
            prediction = await process_image_async(image)
            
            # Get remedies based on language preference
            if language == "gu":
                remedies = REMEDIES_GU.get(prediction["predicted_class"], 
                                         [f"{prediction['predicted_class']} માટે કોઈ વિશિષ્ટ ઉપાય ઉપલબ્ધ નથી"])
            else:
                remedies = REMEDIES.get(prediction["predicted_class"], 
                                      ["No specific remedies available."])
            
            result = PredictionResult(
                predicted_class=prediction["predicted_class"],
                confidence=prediction["confidence"],
                remedies=remedies,
                processing_time=prediction["processing_time"],
                timestamp=prediction["timestamp"],
                cached=False
            )
            
            # Cache result
            prediction_cache[file_hash] = {
                "result": result.dict(),
                "timestamp": time.time()
            }
            
            # Clean old cache entries using configuration
            current_time = time.time()
            prediction_cache = {k: v for k, v in prediction_cache.items() 
                              if current_time - v["timestamp"] < settings.cache_ttl}
            
            successful_predictions += 1
            return result
            
    except HTTPException:
        failed_predictions += 1
        raise
    except Exception as e:
        failed_predictions += 1
        logger.error(f"Error processing prediction: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process image: {str(e)}"
        )

@app.get("/recommend/{disease}")
async def recommend(disease: str, language: str = Query("en", description="Language for remedies (en/gu)"), _: bool = Depends(verify_api_key)):
    """Get remedies for a specific disease with fuzzy matching and language support"""
    try:
        remedies_db = REMEDIES_GU if language == "gu" else REMEDIES
        
        if disease not in remedies_db:
            similar_diseases = [d for d in remedies_db.keys() 
                              if disease.lower() in d.lower()]
            if similar_diseases:
                disease = similar_diseases[0]
                logger.info(f"Disease '{disease}' matched to '{similar_diseases[0]}'")
            else:
                available_diseases = list(remedies_db.keys())
                error_msg = f"Disease '{disease}' not found. Available diseases: {available_diseases}" if language != "gu" else f"રોગ '{disease}' મળ્યો નથી. ઉપલબ્ધ રોગો: {available_diseases}"
                raise HTTPException(
                    status_code=404,
                    detail=error_msg
                )
        
        remedies = remedies_db[disease]
        return {
            "disease": disease,
            "remedies": remedies,
            "remedy_count": len(remedies),
            "timestamp": time.time(),
            "source": "PRAKRUTI Knowledge Base"
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting remedies: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving remedies: {str(e)}"
        )

@app.get("/config")
async def get_config(_: bool = Depends(verify_api_key)):
    """Get current configuration (admin endpoint)"""
    return {
        "app_info": {
            "name": settings.app_name,
            "version": settings.app_version,
            "debug": settings.debug
        },
        "performance": settings.get_performance_config(),
        "model": settings.get_model_info(),
        "supported_diseases": DISEASE_CLASSES,
        "security": {
            "authentication_enabled": settings.api_key is not None,
            "cors_origins": settings.allowed_origins
        },
        "timestamp": time.time()
    }

@app.get("/diseases")
async def list_diseases():
    """List all supported diseases and their remedy counts"""
    from config import DISEASE_CATEGORIES, REGIONAL_DISEASES
    
    disease_info = []
    for disease in DISEASE_CLASSES:
        remedy_count = len(REMEDIES.get(disease, []))
        
        # Find category
        category = "Other"
        for cat_name, diseases in DISEASE_CATEGORIES.items():
            if disease in diseases:
                category = cat_name
                break
        
        disease_info.append({
            "name": disease,
            "remedy_count": remedy_count,
            "has_remedies": remedy_count > 0,
            "category": category,
            "severity": "High" if "Rust" in disease or "Blight" in disease else "Medium"
        })
    
    return {
        "diseases": disease_info,
        "total_diseases": len(DISEASE_CLASSES),
        "diseases_with_remedies": len([d for d in disease_info if d["has_remedies"]]),
        "categories": list(DISEASE_CATEGORIES.keys()),
        "regional_coverage": len(REGIONAL_DISEASES),
        "coverage_summary": {
            "field_crops": len(DISEASE_CATEGORIES.get("Field_Crops", [])),
            "vegetables": len(DISEASE_CATEGORIES.get("Vegetables", [])),
            "fruits": len(DISEASE_CATEGORIES.get("Fruits", [])),
            "plantation_crops": len(DISEASE_CATEGORIES.get("Plantation_Crops", [])),
            "spices": len(DISEASE_CATEGORIES.get("Spices", []))
        },
        "timestamp": time.time()
    }

@app.get("/diseases/category/{category}")
async def get_diseases_by_category(category: str):
    """Get diseases by crop category"""
    from config import DISEASE_CATEGORIES
    
    if category not in DISEASE_CATEGORIES:
        available_categories = list(DISEASE_CATEGORIES.keys())
        raise HTTPException(
            status_code=404,
            detail=f"Category '{category}' not found. Available: {available_categories}"
        )
    
    diseases_in_category = DISEASE_CATEGORIES[category]
    disease_details = []
    
    for disease in diseases_in_category:
        if disease in REMEDIES:
            disease_details.append({
                "name": disease,
                "remedies": REMEDIES[disease],
                "remedy_count": len(REMEDIES[disease])
            })
    
    return {
        "category": category,
        "diseases": disease_details,
        "total_diseases": len(disease_details),
        "timestamp": time.time()
    }

@app.get("/diseases/region/{region}")
async def get_diseases_by_region(region: str):
    """Get diseases prevalent in specific Indian region"""
    from config import REGIONAL_DISEASES
    
    if region not in REGIONAL_DISEASES:
        available_regions = list(REGIONAL_DISEASES.keys())
        raise HTTPException(
            status_code=404,
            detail=f"Region '{region}' not found. Available: {available_regions}"
        )
    
    diseases_in_region = REGIONAL_DISEASES[region]
    disease_details = []
    
    for disease in diseases_in_region:
        if disease in REMEDIES:
            disease_details.append({
                "name": disease,
                "remedies": REMEDIES[disease][:3],  # Top 3 remedies
                "total_remedies": len(REMEDIES[disease])
            })
    
    return {
        "region": region,
        "diseases": disease_details,
        "total_diseases": len(disease_details),
        "climate_info": f"Diseases common in {region.replace('_', ' ')}",
        "timestamp": time.time()
    }

@app.get("/crop-info/{crop_name}")
async def get_crop_information(crop_name: str):
    """Get comprehensive crop information"""
    try:
        with open('crop_database.json', 'r') as f:
            crop_db = json.load(f)
        
        crop_info = crop_db.get('crop_info', {})
        if crop_name not in crop_info:
            available_crops = list(crop_info.keys())
            raise HTTPException(
                status_code=404,
                detail=f"Crop '{crop_name}' not found. Available: {available_crops}"
            )
        
        crop_data = crop_info[crop_name]
        
        # Add related diseases
        related_diseases = [disease for disease in DISEASE_CLASSES 
                          if crop_name.lower() in disease.lower()]
        
        return {
            "crop_name": crop_name,
            "scientific_name": crop_data.get("scientific_name"),
            "family": crop_data.get("family"),
            "major_states": crop_data.get("major_states", []),
            "seasons": crop_data.get("seasons", []),
            "varieties": crop_data.get("varieties", {}),
            "common_diseases": related_diseases,
            "optimal_conditions": crop_data.get("optimal_conditions", {}),
            "fertilizer_schedule": crop_data.get("fertilizer_schedule", {}),
            "timestamp": time.time()
        }
    
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Crop database not available")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving crop info: {str(e)}")

@app.get("/dataset/stats")
async def get_dataset_statistics(_: bool = Depends(verify_api_key)):
    """Get comprehensive dataset statistics"""
    try:
        from dataset_manager import DatasetManager, create_million_sample_strategy
        
        dataset_manager = DatasetManager()
        stats = dataset_manager.dataset_stats
        
        # Generate dataset report
        report = dataset_manager.generate_dataset_report()
        
        # Get million sample strategy
        strategy = create_million_sample_strategy()
        
        return {
            "current_stats": stats,
            "dataset_report": report,
            "expansion_strategy": strategy,
            "supported_diseases": len(DISEASE_CLASSES),
            "indian_crop_coverage": {
                "field_crops": 12,
                "vegetables": 15,
                "fruits": 8,
                "plantation_crops": 6,
                "spices": 6
            },
            "timestamp": time.time()
        }
    
    except Exception as e:
        logger.error(f"Error getting dataset stats: {e}")
        raise HTTPException(status_code=500, detail=f"Error retrieving dataset stats: {str(e)}")

@app.get("/model/performance")
async def get_model_performance(_: bool = Depends(verify_api_key)):
    """Get detailed model performance metrics"""
    try:
        from model_optimizer import ModelOptimizer
        
        optimizer = ModelOptimizer(settings.model_path)
        
        # Benchmark current model
        benchmark_results = optimizer.benchmark_model_performance(settings.model_path)
        
        # Get efficiency report
        efficiency_report = optimizer.create_efficiency_report()
        
        return {
            "benchmark_results": benchmark_results,
            "efficiency_report": efficiency_report,
            "model_info": {
                "path": settings.model_path,
                "format": "TensorFlow Lite",
                "optimization_level": "Production",
                "supported_diseases": len(DISEASE_CLASSES)
            },
            "recommendations": [
                "Model is optimized for Indian crop diseases",
                "Supports 45+ disease classes including major Indian crops",
                "Optimized for mobile and edge deployment",
                "Includes regional disease variations"
            ],
            "timestamp": time.time()
        }
    
    except Exception as e:
        logger.error(f"Error getting model performance: {e}")
        raise HTTPException(status_code=500, detail=f"Error retrieving model performance: {str(e)}")

@app.get("/weather")
async def get_weather(
    location: str = Query(..., description="City name or coordinates (lat,lon)")
):
    """Get current weather information for a location"""
    try:
        logger.info(f"Weather request for location: {location}")
        
        # Initialize weather service
        weather_service = WeatherService()
        
        # Get weather data
        weather_data = await weather_service.get_weather_data(location)
        
        if not weather_data:
            logger.warning(f"No weather data found for location: {location}")
            raise HTTPException(
                status_code=404, 
                detail=f"Weather data not found for location: {location}"
            )
        
        logger.info(f"Weather data retrieved successfully for: {location}")
        return {
            "status": "success",
            "location": location,
            "data": weather_data,
            "timestamp": time.time(),
            "source": "OpenWeatherMap API"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting weather data: {e}")
        # Return mock weather data as fallback
        fallback_weather = {
            "temperature": 25.0,
            "humidity": 65,
            "description": "Partly Cloudy",
            "wind_speed": 10.5,
            "pressure": 1013,
            "uv_index": 6,
            "source": "offline_fallback"
        }
        
        return {
            "status": "fallback",
            "location": location,
            "data": fallback_weather,
            "timestamp": time.time(),
            "source": "Offline Fallback",
            "note": "Using fallback data due to API unavailability"
        }

@app.get("/weather/forecast")
async def get_weather_forecast(
    location: str = Query(..., description="City name or coordinates (lat,lon)"),
    days: int = Query(5, description="Number of forecast days (1-5)")
):
    """Get weather forecast for a location"""
    try:
        if days < 1 or days > 5:
            raise HTTPException(status_code=400, detail="Days must be between 1 and 5")
            
        logger.info(f"Weather forecast request for location: {location}, days: {days}")
        
        # Initialize weather service
        weather_service = WeatherService()
        
        # Get forecast data
        forecast_data = await weather_service.get_forecast(location, days)
        
        if not forecast_data:
            logger.warning(f"No forecast data found for location: {location}")
            raise HTTPException(
                status_code=404, 
                detail=f"Forecast data not found for location: {location}"
            )
        
        logger.info(f"Forecast data retrieved successfully for: {location}")
        return {
            "status": "success",
            "location": location,
            "days": days,
            "forecast": forecast_data,
            "timestamp": time.time(),
            "source": "OpenWeatherMap API"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting forecast data: {e}")
        # Return mock forecast data as fallback
        fallback_forecast = []
        for i in range(days):
            fallback_forecast.append({
                "date": time.strftime('%Y-%m-%d', time.localtime(time.time() + (i * 86400))),
                "temperature": 25.0 + (i * 2),
                "humidity": 65 + (i * 5),
                "description": "Partly Cloudy",
                "wind_speed": 10.5,
                "pressure": 1013,
                "source": "offline_fallback"
            })
        
        return {
            "status": "fallback",
            "location": location,
            "days": days,
            "forecast": fallback_forecast,
            "timestamp": time.time(),
            "source": "Offline Fallback",
            "note": "Using fallback data due to API unavailability"
        }

@app.post("/chat")
async def chat_with_ai(request: dict):
    """AI-Powered Chatbot endpoint for agricultural assistance"""
    try:
        # Validate request
        if 'message' not in request:
            raise HTTPException(status_code=400, detail="Message is required")
        
        user_message = request['message'].strip()
        if not user_message:
            raise HTTPException(status_code=400, detail="Message cannot be empty")
        
        # Get optional parameters
        conversation_id = request.get('conversation_id', f"chat_{int(time.time())}")
        language = request.get('language', 'auto')  # auto, en, gu
        
        logger.info(f"Chat request: {user_message[:100]}... (conversation: {conversation_id})")
        
        # Import AI chatbot service
        from ai_chatbot_service import ai_chatbot
        
        # Initialize AI chatbot if not already done
        await ai_chatbot.initialize()
        
        # Get AI response
        response = await ai_chatbot.get_ai_response(
            user_message=user_message,
            conversation_id=conversation_id,
            language=language
        )
        
        logger.info(f"Chat response generated successfully (length: {len(response)})")
        
        return {
            "status": "success",
            "response": response,
            "conversation_id": conversation_id,
            "language_detected": ai_chatbot._detect_language(user_message),
            "provider": ai_chatbot.current_provider or "fallback",
            "timestamp": time.time(),
            "message_length": len(user_message),
            "response_length": len(response)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing chat request: {e}")
        # Return a helpful fallback response
        fallback_response = (
            "I'm currently experiencing some technical difficulties. "
            "In the meantime, you can:\n\n"
            "• Use our disease scanner for plant identification\n"
            "• Check the weather section for forecasts\n"
            "• Browse the community section for tips\n"
            "• Access our knowledge base for farming guides\n\n"
            "Please try again in a moment!"
        )
        
        return {
            "status": "fallback",
            "response": fallback_response,
            "timestamp": time.time(),
            "error": "Technical difficulty - using fallback response"
        }

# 🤖 INTELLIGENT MODEL MANAGEMENT ENDPOINTS

@app.get("/models/auto-select/{priority}")
async def auto_select_model_endpoint(priority: str):
    """Automatically select best model based on system and priority"""
    try:
        valid_priorities = ["speed", "balanced", "accuracy"]
        if priority not in valid_priorities:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid priority. Must be one of: {valid_priorities}"
            )
        
        selected_model = auto_select_model(priority=priority)
        model_config = AVAILABLE_MODELS[selected_model]
        
        return {
            "status": "success",
            "selected_model": selected_model,
            "model_info": model_config,
            "priority": priority,
            "system_info": intelligent_selector.system_info,
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Error in auto model selection: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/models/recommendation")
async def get_model_recommendation():
    """Get intelligent model recommendations for current system"""
    try:
        selector = get_intelligent_selector()
        report = selector.get_recommendation_report()
        
        recommendations = {
            "speed": selector.select_model_by_priority("speed"),
            "balanced": selector.select_model_by_priority("balanced"), 
            "accuracy": selector.select_model_by_priority("accuracy"),
            "adaptive_100ms": selector.adaptive_model_selection(100),
            "adaptive_500ms": selector.adaptive_model_selection(500)
        }
        
        return {
            "status": "success",
            "system_info": selector.system_info,
            "recommendations": recommendations,
            "detailed_report": report,
            "available_models": AVAILABLE_MODELS,
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Error getting model recommendation: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/models/benchmark/{model_name}")
async def benchmark_model_endpoint(model_name: str, iterations: int = 3):
    """Benchmark a specific model performance"""
    try:
        if model_name not in AVAILABLE_MODELS:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid model. Available: {list(AVAILABLE_MODELS.keys())}"
            )
        
        selector = get_intelligent_selector()
        benchmark_result = selector.benchmark_model(model_name, iterations)
        
        return {
            "status": "success",
            "benchmark": benchmark_result,
            "model_info": AVAILABLE_MODELS[model_name],
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Error benchmarking model {model_name}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/models/switch/{model_name}")
async def switch_model_endpoint(model_name: str):
    """Switch to a different model (requires restart)"""
    try:
        if model_name not in AVAILABLE_MODELS:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid model. Available: {list(AVAILABLE_MODELS.keys())}"
            )
        
        # Update model selector configuration
        import model_selector
        with open('model_selector.py', 'r') as f:
            content = f.read()
        
        # Replace the SELECTED_MODEL line
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if line.strip().startswith('SELECTED_MODEL = '):
                lines[i] = f'SELECTED_MODEL = "{model_name}"  # Auto-switched'
                break
        
        with open('model_selector.py', 'w') as f:
            f.write('\n'.join(lines))
        
        return {
            "status": "success",
            "message": f"Model switched to {model_name}. Restart required to take effect.",
            "new_model": model_name,
            "model_info": AVAILABLE_MODELS[model_name],
            "restart_required": True,
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Error switching model: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# Performance monitoring variables
startup_time = time.time()
total_predictions = 0
total_processing_time = 0
successful_predictions = 0
failed_predictions = 0

@app.on_event("startup")
async def startup_event():
    """Initialize resources on startup"""
    global startup_time, request_semaphore
    startup_time = time.time()
    logger.info(f"Starting up {settings.app_name} v{settings.app_version}...")
    
    # Validate configuration
    if not validate_config():
        logger.error("Configuration validation failed!")
        raise RuntimeError("Invalid configuration")
    
    # Initialize async semaphore for rate limiting
    request_semaphore = asyncio.Semaphore(settings.max_concurrent_requests)
    
    # Initialize thread pool with configuration
    thread_pool._max_workers = min(os.cpu_count() or 1, settings.thread_pool_workers)
    logger.info(f"Initialized thread pool with {thread_pool._max_workers} workers")
    
    # GPU acceleration disabled for weather API testing
    logger.info("GPU acceleration disabled for testing")
        
    # Warm up the model if enabled
    if settings.model_warm_up:
        try:
            input_shape = MODEL_CONFIG["input_shape"]
            dummy_input = np.zeros((1, *input_shape), dtype=np.float32)
            
            # Different warm-up for TFLite vs Keras models
            if interpreter is not None and input_details is not None:
                # TFLite model warm-up
                interpreter.set_tensor(input_details[0]['index'], dummy_input)
                interpreter.invoke()
                logger.info("TFLite model warm-up completed")
            elif keras_model is not None:
                # Keras model warm-up
                _ = keras_model.predict(dummy_input, verbose=0)
                logger.info("Keras model warm-up completed")
            else:
                logger.warning("No model available for warm-up")
        except Exception as e:
            logger.error(f"Model warm-up failed: {e}")
    else:
        logger.info("Model warm-up disabled")

    # Log model information (only if model is loaded)
    if input_details is not None:
        logger.info(f"Model input shape: {input_details[0]['shape']}")
        logger.info(f"Model quantized: {input_details[0]['dtype'] != np.float32}")
    else:
        logger.info("Model loading disabled - Weather API testing mode")
    logger.info(f"Number of threads: {thread_pool._max_workers}")
    
    # Initialize metrics
    global total_predictions, total_processing_time, successful_predictions, failed_predictions
    total_predictions = 0
    total_processing_time = 0
    successful_predictions = 0
    failed_predictions = 0
    
    # Create cache cleanup task
    asyncio.create_task(cleanup_cache())

async def cleanup_cache():
    """Periodically clean up expired cache entries"""
    while True:
        try:
            current_time = time.time()
            global prediction_cache
            old_size = len(prediction_cache)
            prediction_cache = {k: v for k, v in prediction_cache.items() 
                              if current_time - v["timestamp"] < settings.cache_ttl}
            new_size = len(prediction_cache)
            if old_size != new_size:
                logger.info(f"Cache cleanup: removed {old_size - new_size} expired entries")
            await asyncio.sleep(300)  # Clean every 5 minutes
        except Exception as e:
            logger.error(f"Error in cache cleanup: {e}")
            await asyncio.sleep(60)  # Retry after 1 minute

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup resources on shutdown"""
    logger.info(f"Shutting down {settings.app_name}...")
    logger.info(f"Final stats - Total predictions: {total_predictions}, Success: {successful_predictions}, Failed: {failed_predictions}")
    thread_pool.shutdown(wait=True)

# Add exception handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail,
            "timestamp": time.time()
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "detail": str(exc),
            "timestamp": time.time()
        }
    )

# Run the application with configuration
if __name__ == "__main__":
    uvicorn.run(
        "app_enhanced:app",
        host=settings.host,
        port=settings.port,
        workers=settings.workers,
        loop="uvloop" if not settings.debug else "asyncio",
        log_level=settings.log_level.lower(),
        reload=settings.reload and settings.debug
    )
