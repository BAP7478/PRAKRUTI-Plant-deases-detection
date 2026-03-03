#!/usr/bin/env python3
"""
Model Configuration Selector for PRAKRUTI
Choose which trained model to use for disease detection
"""

# Available trained models
AVAILABLE_MODELS = {
    "mobilenet_h5": {
        "path": "models/mobilenet_model.h5",
        "type": "keras",
        "size": "14MB",
        "speed": "Fast",
        "accuracy": "Good",
        "description": "MobileNet H5 - Balanced performance"
    },
    "mobilenet_tflite": {
        "path": "models/mobilenet_model.tflite", 
        "type": "tflite",
        "size": "13MB",
        "speed": "Fastest",
        "accuracy": "Good", 
        "description": "MobileNet TFLite - Optimized for mobile"
    },
    "efficientnetb0": {
        "path": "models/efficientnetb0_model.h5",
        "type": "keras", 
        "size": "21MB",
        "speed": "Medium",
        "accuracy": "Better",
        "description": "EfficientNetB0 - Best accuracy/efficiency balance"
    },
    "resnet50": {
        "path": "models/resnet50_model.h5",
        "type": "keras",
        "size": "98MB", 
        "speed": "Slower",
        "accuracy": "Best",
        "description": "ResNet50 - Highest accuracy, larger model"
    }
}

# Current model selection (change this to switch models)
SELECTED_MODEL = "mobilenet_tflite"  # Auto-switched

def get_current_model():
    """Get the currently selected model configuration"""
    return AVAILABLE_MODELS[SELECTED_MODEL]

def print_model_info():
    """Print information about all available models"""
    print("🧠 PRAKRUTI - Available Trained Models:")
    print("=" * 50)
    
    for key, model in AVAILABLE_MODELS.items():
        current = "✅ CURRENT" if key == SELECTED_MODEL else "  "
        print(f"{current} {key}:")
        print(f"   📁 {model['path']}")
        print(f"   📊 Size: {model['size']} | Speed: {model['speed']} | Accuracy: {model['accuracy']}")
        print(f"   📝 {model['description']}")
        print()

if __name__ == "__main__":
    print_model_info()
