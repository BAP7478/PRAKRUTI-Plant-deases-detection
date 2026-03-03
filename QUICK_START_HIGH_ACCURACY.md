# 🚀 Quick Start Guide: Achieving High Accuracy

This guide will help you improve your PRAKRUTI model accuracy from current state to 90%+ accuracy.

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] Python 3.8+ installed
- [ ] TensorFlow 2.x installed (`pip install tensorflow`)
- [ ] GPU with CUDA (optional but recommended for faster training)
- [ ] At least 10GB free disk space
- [ ] 8GB+ RAM (16GB recommended)

---

## 🎯 Step-by-Step Guide

### Step 1: Prepare Your Dataset (MOST IMPORTANT!)

#### Option A: Download Existing Dataset (Recommended for beginners)

```bash
# Download PlantVillage Dataset (54,000+ images)
# Visit: https://www.kaggle.com/datasets/emmarex/plantdisease
# Or use Kaggle API:
pip install kaggle
kaggle datasets download -d emmarex/plantdisease
unzip plantdisease.zip -d dataset/
```

#### Option B: Use Your Own Data

Organize your dataset like this:

```
dataset/
├── train/              # 70% of data
│   ├── Healthy/
│   │   ├── img1.jpg
│   │   ├── img2.jpg
│   │   └── ... (2000+ images recommended)
│   ├── Rice_Blast/
│   │   ├── img1.jpg
│   │   └── ... (2000+ images)
│   ├── Wheat_Rust/
│   └── ... (all 47 disease classes)
│
├── validation/         # 15% of data
│   ├── Healthy/
│   ├── Rice_Blast/
│   └── ...
│
└── test/              # 15% of data (optional)
    ├── Healthy/
    ├── Rice_Blast/
    └── ...
```

**Important Rules:**
- Each folder name = disease class name
- Put 2000+ images per class for best results
- Images should be clear, focused on the diseased area
- Use JPG or PNG format
- Minimum size: 224x224 pixels (larger is better)

---

### Step 2: Install Dependencies

```bash
cd /Users/bhargav/Desktop/MAJOR\ PROJECT\ /PRAKRUTI/prakruti/prakruti-backend

# Install required packages
pip install tensorflow==2.14.0
pip install numpy pandas matplotlib
pip install Pillow scikit-learn
pip install albumentations  # Advanced augmentation

# Optional: For GPU acceleration
pip install tensorflow[and-cuda]  # For Windows/Linux with NVIDIA GPU
```

---

### Step 3: Update Configuration

Edit `train_improved_model.py` and update the data path:

```python
# Line 30-32
DATA_DIR = "/path/to/your/dataset"  # Update this!
```

Or use environment variable:

```bash
export DATASET_PATH="/Users/bhargav/Desktop/dataset"
```

---

### Step 4: Run Training (Simple Method)

```bash
cd prakruti-backend

# Train with default settings (EfficientNetV2B0)
python train_improved_model.py
```

This will:
- ✅ Check your dataset
- ✅ Create data generators with augmentation
- ✅ Build EfficientNetV2B0 model
- ✅ Train for 100 epochs (with early stopping)
- ✅ Save best model automatically
- ✅ Convert to TFLite for mobile
- ✅ Log everything to TensorBoard

**Expected Training Time:**
- With GPU: 2-4 hours
- With CPU: 8-12 hours

---

### Step 5: Monitor Training Progress

Open another terminal and run:

```bash
cd prakruti-backend
tensorboard --logdir training_logs
```

Then open browser: http://localhost:6006

You'll see:
- Real-time accuracy graphs
- Loss curves
- Learning rate changes
- Model architecture visualization

---

### Step 6: Evaluate Results

After training completes, check the results:

```bash
# Your trained models will be in:
ls models/

# You should see:
# - efficientnetv2b0_best_TIMESTAMP.h5      (Keras model)
# - efficientnetv2b0_final_TIMESTAMP.h5     (Final model)
# - efficientnetv2b0_model_TIMESTAMP.tflite (Mobile model)
```

---

## 🎓 Understanding the Training Process

### Phase 1: Transfer Learning (Epochs 1-20)
- Only trains the new classification head
- Base model (ImageNet weights) frozen
- Fast training, learns basic patterns
- **Expected accuracy after Phase 1: 70-80%**

### Phase 2: Fine-tuning (Epochs 21-100)
- Unfreezes half of the base model
- Fine-tunes weights for plant diseases
- Slower but more accurate
- **Expected accuracy after Phase 2: 85-95%**

---

## 📊 Expected Accuracy Timeline

| Epoch | Expected Accuracy | What's Happening |
|-------|-------------------|------------------|
| 1-5   | 40-60% | Learning basic features |
| 6-10  | 60-75% | Distinguishing major differences |
| 11-20 | 75-85% | Phase 1 complete - good baseline |
| 21-30 | 85-90% | Fine-tuning starts |
| 31-50 | 90-93% | Reaching optimal performance |
| 51+   | 93-96% | Minor improvements, may plateau |

---

## ⚡ Quick Fixes for Common Issues

### Issue 1: "Dataset directory not found"

**Solution:**
```bash
# Check your dataset path
ls /path/to/your/dataset

# Update path in train_improved_model.py
DATA_DIR = "/correct/path/to/dataset"
```

### Issue 2: "Out of Memory (OOM) Error"

**Solution:** Reduce batch size
```python
# In train_improved_model.py, line 36
BATCH_SIZE = 8  # Reduce from 16 to 8 or even 4
```

### Issue 3: "Training is too slow"

**Solution:**
```python
# Option 1: Reduce image size
IMG_SIZE = 224  # Instead of 384

# Option 2: Use smaller model
# In main(), change:
model_types = ['efficientnetv2b0']  # Smaller model
```

### Issue 4: "Accuracy stuck at 60-70%"

**Possible causes:**
1. ❌ Not enough training data → Add more images
2. ❌ Poor quality images → Use better photos
3. ❌ Imbalanced dataset → Balance classes
4. ❌ Training stopped too early → Train more epochs

---

## 🎯 Accuracy Improvement Checklist

If your accuracy is below target, try these in order:

### Priority 1: Data Quality (Biggest impact!)
- [ ] Add more images (aim for 2000+ per class)
- [ ] Remove blurry/poor quality images
- [ ] Balance classes (equal images per disease)
- [ ] Use higher resolution images

### Priority 2: Training Settings
- [ ] Train for more epochs (50-100)
- [ ] Use larger image size (384 or 512)
- [ ] Enable GPU acceleration
- [ ] Use ensemble of multiple models

### Priority 3: Model Architecture
- [ ] Try EfficientNetV2B1 or B2 (larger models)
- [ ] Increase dense layer sizes
- [ ] Adjust dropout rates

### Priority 4: Advanced Techniques
- [ ] Implement Test-Time Augmentation
- [ ] Use focal loss for imbalanced data
- [ ] Try different optimizers (SGD with momentum)
- [ ] Use learning rate scheduling

---

## 📈 Realistic Accuracy Targets

Based on your data quality:

| Data Quality | Expected Accuracy | Time to Achieve |
|--------------|-------------------|-----------------|
| **Basic** (500 images/class) | 75-82% | 2-3 hours |
| **Good** (1000 images/class) | 82-88% | 4-6 hours |
| **Very Good** (2000+ images/class) | 88-93% | 6-10 hours |
| **Excellent** (5000+ images/class) | 93-96% | 10-20 hours |
| **Research-level** (10000+ images/class) | 96-99% | 20-40 hours |

---

## 🎓 Next Steps After Training

### 1. Replace Your Current Model

```bash
# Copy the best model to your backend
cp models/efficientnetv2b0_best_*.h5 ../models/efficientnetb0_model.h5

# Or use TFLite for mobile
cp models/efficientnetv2b0_model_*.tflite ../models/mobilenet_model.tflite
```

### 2. Update Your Backend Config

Edit `prakruti-backend/config.py`:

```python
# Update model path to use your new trained model
MODEL_PATH = os.path.join(MODELS_DIR, "efficientnetb0_model.h5")
```

### 3. Test Your New Model

```bash
# Restart your backend server
cd prakruti-backend
python app_enhanced.py

# Test with your Flutter app
```

---

## 💡 Pro Tips

### Tip 1: Use Pretrained Weights
- Always start with ImageNet weights
- Don't train from scratch (takes 10x longer)

### Tip 2: Monitor Validation Accuracy
- If validation accuracy >> training accuracy → Underfitting (train more)
- If training accuracy >> validation accuracy → Overfitting (more data/augmentation)

### Tip 3: Save Checkpoints
- The script auto-saves best model
- Don't worry if training stops early (best weights restored)

### Tip 4: Use Early Stopping
- Already enabled with patience=15
- Training stops automatically if no improvement

### Tip 5: Experiment Tracking
- Use TensorBoard to compare runs
- Keep notes on what settings work best

---

## 🆘 Getting Help

If you're stuck:

1. **Check the logs:**
   ```bash
   cat training_logs/efficientnetv2b0_*_training.csv
   ```

2. **Verify dataset:**
   ```bash
   python -c "from train_improved_model import Config, check_dataset; check_dataset(Config())"
   ```

3. **Test with small subset first:**
   - Use only 100 images per class
   - Train for 5 epochs
   - Verify everything works
   - Then scale up

---

## 📚 Additional Resources

### Datasets:
- PlantVillage: https://www.kaggle.com/datasets/emmarex/plantdisease
- Plant Pathology: https://www.kaggle.com/c/plant-pathology-2020-fgvc7
- New Plant Diseases: https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset

### Tutorials:
- Transfer Learning: https://www.tensorflow.org/tutorials/images/transfer_learning
- Data Augmentation: https://www.tensorflow.org/tutorials/images/data_augmentation
- TensorBoard: https://www.tensorflow.org/tensorboard

---

## ✅ Success Criteria

You've achieved success when:

- ✅ Training completes without errors
- ✅ Validation accuracy > 90%
- ✅ Model file (.h5) is created
- ✅ TFLite model (.tflite) is created
- ✅ Model works in your Flask backend
- ✅ Flutter app can make predictions
- ✅ Predictions are accurate on test images

---

## 🎉 What You'll Achieve

Following this guide, you should reach:

- **90-95% accuracy** on validation set
- **Fast inference** (< 1 second per image)
- **Mobile-ready** TFLite model
- **Production-ready** model for your app
- **Confidence** to improve further

---

**Ready to start? Run the training script and watch your accuracy improve! 🚀**

```bash
python train_improved_model.py
```

Good luck! 🌱
