#!/usr/bin/env python3
"""
Quick Start Guide for Retraining PRAKRUTI Models
Step-by-step process to convert your ImageNet models to Plant Disease models
"""

import os
import sys
from pathlib import Path

def check_requirements():
    """Check if required packages are installed"""
    
    print("🔍 Checking requirements...")
    
    required_packages = [
        'tensorflow', 'pillow', 'numpy', 'matplotlib'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✅ {package}")
        except ImportError:
            print(f"❌ {package}")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\n📦 Install missing packages:")
        print(f"pip3 install {' '.join(missing_packages)}")
        return False
    
    return True

def get_sample_dataset():
    """Suggest where to get plant disease datasets"""
    
    print("\n📥 Plant Disease Datasets:")
    print("=" * 40)
    
    datasets = [
        {
            "name": "PlantVillage Dataset", 
            "url": "https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset",
            "classes": "38 classes, ~87,000 images",
            "description": "Most popular plant disease dataset"
        },
        {
            "name": "Plant Disease Recognition Dataset",
            "url": "https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset", 
            "classes": "Various crop diseases",
            "description": "Good for Indian crops"
        },
        {
            "name": "Custom Collection",
            "url": "Collect your own images",
            "classes": "Your specific requirements", 
            "description": "Take photos of local diseased plants"
        }
    ]
    
    for i, dataset in enumerate(datasets, 1):
        print(f"{i}. {dataset['name']}")
        print(f"   🔗 {dataset['url']}")
        print(f"   📊 {dataset['classes']}")
        print(f"   📝 {dataset['description']}")
        print()

def show_training_process():
    """Show the complete training process"""
    
    print("\n🚀 Complete Retraining Process:")
    print("=" * 40)
    
    steps = [
        {
            "step": "1. Prepare Dataset",
            "command": "python3 prepare_dataset.py", 
            "description": "Organize your images into train/validation folders"
        },
        {
            "step": "2. Train Models", 
            "command": "python3 retrain_models.py",
            "description": "Retrain ResNet50, MobileNet, EfficientNet with your data"
        },
        {
            "step": "3. Update Model Paths",
            "command": "Edit model_selector.py",
            "description": "Point to your newly trained models"
        },
        {
            "step": "4. Remove ImageNet Mapping",
            "command": "Edit app_enhanced.py", 
            "description": "Remove the ImageNet->Plant Disease mapping code"
        },
        {
            "step": "5. Test New Models",
            "command": "Start backend and test predictions",
            "description": "Verify your models predict plant diseases directly"
        }
    ]
    
    for step_info in steps:
        print(f"📋 {step_info['step']}")
        print(f"   💻 {step_info['command']}")
        print(f"   📝 {step_info['description']}")
        print()

def create_quick_demo():
    """Create a minimal demo for testing"""
    
    print("\n🎯 Quick Demo Setup:")
    print("=" * 30)
    
    demo_code = '''
# Quick test script - save as test_retrained_model.py
import tensorflow as tf
import numpy as np
from PIL import Image

def test_model(model_path, image_path):
    """Test your retrained model"""
    
    # Load model
    model = tf.keras.models.load_model(model_path)
    
    # Load and preprocess image
    img = Image.open(image_path).resize((224, 224))
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    # Predict
    predictions = model.predict(img_array)
    class_idx = np.argmax(predictions[0])
    confidence = predictions[0][class_idx]
    
    # Your 47 disease classes
    classes = ["Healthy", "Rice_Blast", "Rice_Brown_Spot", ...]  # Add all 47
    
    print(f"Prediction: {classes[class_idx]}")
    print(f"Confidence: {confidence:.2%}")
    
    return classes[class_idx], confidence

# Usage
if __name__ == "__main__":
    model_path = "models/resnet50_plant_disease_final.h5"
    image_path = "test_plant.jpg"
    
    prediction, confidence = test_model(model_path, image_path)
    print(f"Result: {prediction} ({confidence:.2%})")
    '''
    
    with open("test_retrained_model.py", "w") as f:
        f.write(demo_code)
    
    print("✅ Created test_retrained_model.py")

def main():
    """Main function"""
    
    print("🌱 PRAKRUTI Model Retraining Guide")
    print("=" * 50)
    
    # Check if we can proceed
    if not check_requirements():
        return
    
    # Show dataset options
    get_sample_dataset()
    
    # Show complete process
    show_training_process() 
    
    # Create demo
    create_quick_demo()
    
    print("\n💡 Key Benefits of Retraining:")
    print("✅ Direct 47-class plant disease output (no mapping needed)")
    print("✅ Better accuracy for your specific crops")
    print("✅ Smaller model size (47 classes vs 1000)")
    print("✅ Faster inference time")
    print("✅ More reliable predictions")
    
    print("\n🎯 For Tomorrow's Submission:")
    print("Current: Working system with ImageNet mapping ✅")
    print("Future: Properly trained plant disease models 🚀")
    
    print("\n📞 Need Help?")
    print("1. Start with prepare_dataset.py to organize your data")
    print("2. Use a small subset for quick testing")
    print("3. The current system works - retraining is an enhancement!")

if __name__ == "__main__":
    main()
