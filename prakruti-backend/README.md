# PRAKRUTI Backend Repo

This repo contains code to train transfer-learning models (ResNet50, MobileNetV2, EfficientNetB0), convert them to TFLite, run a FastAPI server that serves predictions and tflite downloads, and examples for Flutter integration.

## What is included
- train_transfer.py
- convert_to_tflite.py
- app.py (with /model_versions and model download endpoints)
- labels_to_txt.py
- disease_remedies.json
- Dockerfile
- flutter_snippets.md
- requirements.txt

## How to use
Follow the step-by-step guide in the canvas document you already received. For training, you can use Google Colab if you don't have a GPU locally.

IMPORTANT: I cannot train models here without your dataset or external compute. See `TRAINING_OPTIONS.md` for a ready-to-run Google Colab notebook and instructions.

