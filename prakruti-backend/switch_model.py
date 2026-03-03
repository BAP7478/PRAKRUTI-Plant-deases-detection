#!/usr/bin/env python3
"""
Switch between your trained models for PRAKRUTI disease detection
"""

import sys
import subprocess
import time

def switch_model(model_name):
    """Switch to a different trained model"""
    
    valid_models = {
        "mobilenet_tflite": "MobileNet TFLite (Fastest)",
        "mobilenet_h5": "MobileNet H5 (Fast)",  
        "efficientnetb0": "EfficientNetB0 H5 (Better accuracy)",
        "resnet50": "ResNet50 H5 (Best accuracy)"
    }
    
    if model_name not in valid_models:
        print(f"❌ Invalid model. Choose from: {list(valid_models.keys())}")
        return False
    
    print(f"🔄 Switching to: {valid_models[model_name]}")
    
    # Update model_selector.py
    with open('model_selector.py', 'r') as f:
        content = f.read()
    
    # Replace the SELECTED_MODEL line
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.strip().startswith('SELECTED_MODEL = '):
            lines[i] = f'SELECTED_MODEL = "{model_name}"  # Current choice'
            break
    
    with open('model_selector.py', 'w') as f:
        f.write('\n'.join(lines))
    
    print("✅ Model configuration updated")
    
    # Restart backend
    print("🔄 Restarting backend...")
    subprocess.run(["pkill", "-f", "uvicorn.*app_enhanced"], capture_output=True)
    time.sleep(2)
    
    # Start backend again
    cmd = [
        "nohup", "python3", "-m", "uvicorn", "app_enhanced:app", 
        "--reload", "--host", "0.0.0.0", "--port", "8002"
    ]
    
    with open("server.log", "w") as log_file:
        subprocess.Popen(cmd, stdout=log_file, stderr=log_file)
    
    print("⏳ Waiting for backend to start...")
    time.sleep(5)
    
    # Test the new model
    print(f"🧠 Testing {valid_models[model_name]}...")
    return True

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 switch_model.py <model_name>")
        print("\nAvailable models:")
        print("  mobilenet_tflite  - MobileNet TFLite (Fastest)")
        print("  mobilenet_h5      - MobileNet H5 (Fast)")
        print("  efficientnetb0    - EfficientNetB0 H5 (Better)")
        print("  resnet50          - ResNet50 H5 (Best accuracy)")
        return
    
    model_name = sys.argv[1]
    if switch_model(model_name):
        print(f"\n🎉 Successfully switched to {model_name}!")
        print("You can now test the new model with your Flutter app.")

if __name__ == "__main__":
    main()
