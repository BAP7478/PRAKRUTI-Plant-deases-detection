#!/usr/bin/env python3
"""
Improved Training Script for Plant Disease Detection
Implements best practices for achieving 90%+ accuracy
"""

import tensorflow as tf
from tensorflow.keras.applications import EfficientNetV2B0, EfficientNetV2B1
from tensorflow.keras.layers import (
    Dense, GlobalAveragePooling2D, GlobalMaxPooling2D,
    Dropout, BatchNormalization, Concatenate
)
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import (
    EarlyStopping, ReduceLROnPlateau, ModelCheckpoint,
    TensorBoard, CSVLogger
)
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import numpy as np
import os
from datetime import datetime
import json

# Configuration
class Config:
    """Training configuration"""
    
    # Paths
    DATA_DIR = "dataset"  # Change this to your dataset path
    TRAIN_DIR = os.path.join(DATA_DIR, "train")
    VAL_DIR = os.path.join(DATA_DIR, "validation")
    TEST_DIR = os.path.join(DATA_DIR, "test")
    MODEL_DIR = "models"
    LOGS_DIR = "training_logs"
    
    # Model settings
    IMG_SIZE = 384  # Higher resolution for better accuracy
    BATCH_SIZE = 16  # Reduced for higher resolution
    EPOCHS = 100
    
    # Training settings
    INITIAL_LR = 0.001
    MIN_LR = 1e-7
    
    # Number of classes (update based on your dataset)
    NUM_CLASSES = 47
    
    # Class names from config.py
    DISEASE_CLASSES = [
        "Healthy",
        "Rice_Blast", "Rice_Brown_Spot", "Rice_Bacterial_Blight",
        "Wheat_Rust_Yellow", "Wheat_Rust_Brown", "Wheat_Rust_Black",
        "Maize_Common_Rust", "Maize_Northern_Leaf_Blight",
        "Cotton_Bacterial_Blight", "Cotton_Fusarium_Wilt",
        "Sugarcane_Red_Rot", "Sugarcane_Smut",
        "Potato_Late_Blight", "Potato_Early_Blight",
        "Chili_Leaf_Curl", "Chili_Anthracnose",
        "Onion_Purple_Blotch", "Groundnut_Tikka",
        "Banana_Panama_Wilt", "Banana_Black_Sigatoka",
        "Mango_Anthracnose", "Mango_Powdery_Mildew",
        "Tomato_Early_Blight", "Tomato_Late_Blight", "Tomato_Leaf_Mold",
        "Tomato_Septoria_Leaf_Spot", "Tomato_Bacterial_Spot",
        "Tomato_Target_Spot", "Tomato_Yellow_Leaf_Curl_Virus",
        "Tomato_Mosaic_Virus", "Tomato_Spider_Mites",
        "Apple_Scab", "Apple_Black_Rot", "Apple_Cedar_Apple_Rust",
        "Grape_Black_Rot", "Grape_Esca", "Grape_Leaf_Blight",
        "Corn_Common_Rust", "Corn_Gray_Leaf_Spot",
        "Soybean_Bacterial_Blight", "Soybean_Frog_Eye_Leaf_Spot",
        "Strawberry_Leaf_Scorch", "Peach_Bacterial_Spot",
        "Bell_Pepper_Bacterial_Spot", "Cherry_Powdery_Mildew",
        "Squash_Powdery_Mildew"
    ]

def create_advanced_augmentation():
    """
    Create advanced data augmentation pipeline
    Returns enhanced augmentation for training
    """
    
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        
        # Geometric transformations
        rotation_range=40,           # More rotation
        width_shift_range=0.3,
        height_shift_range=0.3,
        shear_range=0.3,
        zoom_range=0.3,
        horizontal_flip=True,
        vertical_flip=True,          # Important for plants!
        
        # Color augmentation
        brightness_range=[0.7, 1.3],
        channel_shift_range=30,
        
        fill_mode='nearest'
    )
    
    # Validation data (only rescaling)
    val_datagen = ImageDataGenerator(rescale=1./255)
    
    return train_datagen, val_datagen

def create_data_generators(config):
    """Create training and validation data generators"""
    
    print("📊 Creating data generators...")
    
    train_datagen, val_datagen = create_advanced_augmentation()
    
    # Training generator
    train_generator = train_datagen.flow_from_directory(
        config.TRAIN_DIR,
        target_size=(config.IMG_SIZE, config.IMG_SIZE),
        batch_size=config.BATCH_SIZE,
        class_mode='categorical',
        classes=config.DISEASE_CLASSES,
        shuffle=True
    )
    
    # Validation generator
    val_generator = val_datagen.flow_from_directory(
        config.VAL_DIR,
        target_size=(config.IMG_SIZE, config.IMG_SIZE),
        batch_size=config.BATCH_SIZE,
        class_mode='categorical',
        classes=config.DISEASE_CLASSES,
        shuffle=False
    )
    
    # Print class distribution
    print(f"\n✅ Data Generators Created:")
    print(f"   Training samples: {train_generator.samples}")
    print(f"   Validation samples: {val_generator.samples}")
    print(f"   Number of classes: {len(train_generator.class_indices)}")
    print(f"   Batch size: {config.BATCH_SIZE}")
    print(f"   Image size: {config.IMG_SIZE}x{config.IMG_SIZE}")
    
    return train_generator, val_generator

def create_improved_model(config, model_type='efficientnetv2b0'):
    """
    Create improved model with better architecture
    
    Args:
        config: Configuration object
        model_type: 'efficientnetv2b0', 'efficientnetv2b1', etc.
    """
    
    print(f"\n🏗️ Building {model_type.upper()} model...")
    
    # Load pre-trained base model
    if model_type == 'efficientnetv2b0':
        base_model = EfficientNetV2B0(
            weights='imagenet',
            include_top=False,
            input_shape=(config.IMG_SIZE, config.IMG_SIZE, 3)
        )
    elif model_type == 'efficientnetv2b1':
        base_model = EfficientNetV2B1(
            weights='imagenet',
            include_top=False,
            input_shape=(config.IMG_SIZE, config.IMG_SIZE, 3)
        )
    else:
        raise ValueError(f"Unknown model type: {model_type}")
    
    # Freeze base model initially
    base_model.trainable = False
    
    # Enhanced classification head
    x = base_model.output
    
    # Dual pooling strategy (GAP + GMP)
    gap = GlobalAveragePooling2D(name='gap')(x)
    gmp = GlobalMaxPooling2D(name='gmp')(x)
    x = Concatenate(name='concat_pooling')([gap, gmp])
    
    # Dense layers with regularization
    x = Dense(1024, activation='relu', 
              kernel_regularizer=tf.keras.regularizers.l2(0.01),
              name='dense1')(x)
    x = BatchNormalization(name='bn1')(x)
    x = Dropout(0.5, name='dropout1')(x)
    
    x = Dense(512, activation='relu',
              kernel_regularizer=tf.keras.regularizers.l2(0.01),
              name='dense2')(x)
    x = BatchNormalization(name='bn2')(x)
    x = Dropout(0.4, name='dropout2')(x)
    
    # Output layer
    outputs = Dense(config.NUM_CLASSES, activation='softmax', name='predictions')(x)
    
    # Create model
    model = Model(inputs=base_model.input, outputs=outputs, name=f'{model_type}_plant_disease')
    
    print(f"✅ Model created successfully")
    print(f"   Total parameters: {model.count_params():,}")
    print(f"   Trainable parameters: {sum([tf.size(w).numpy() for w in model.trainable_weights]):,}")
    
    return model, base_model

def get_callbacks(config, model_name):
    """Create training callbacks"""
    
    # Create directories
    os.makedirs(config.MODEL_DIR, exist_ok=True)
    os.makedirs(config.LOGS_DIR, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    callbacks = [
        # Early stopping
        EarlyStopping(
            monitor='val_accuracy',
            patience=15,
            restore_best_weights=True,
            verbose=1,
            mode='max'
        ),
        
        # Reduce learning rate on plateau
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=config.MIN_LR,
            verbose=1,
            mode='min'
        ),
        
        # Save best model
        ModelCheckpoint(
            filepath=os.path.join(config.MODEL_DIR, f'{model_name}_best_{timestamp}.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            save_weights_only=False,
            mode='max',
            verbose=1
        ),
        
        # TensorBoard logging
        TensorBoard(
            log_dir=os.path.join(config.LOGS_DIR, f'{model_name}_{timestamp}'),
            histogram_freq=1,
            write_graph=True,
            write_images=True,
            update_freq='epoch'
        ),
        
        # CSV Logger
        CSVLogger(
            filename=os.path.join(config.LOGS_DIR, f'{model_name}_{timestamp}_training.csv'),
            separator=',',
            append=False
        )
    ]
    
    return callbacks

def train_model(config, model_type='efficientnetv2b0'):
    """
    Main training function with two-phase training
    
    Phase 1: Train classification head only
    Phase 2: Fine-tune entire model
    """
    
    print("\n" + "="*70)
    print(f"🚀 STARTING TRAINING: {model_type.upper()}")
    print("="*70 + "\n")
    
    # Create data generators
    train_gen, val_gen = create_data_generators(config)
    
    # Create model
    model, base_model = create_improved_model(config, model_type)
    
    # Compile model for Phase 1
    model.compile(
        optimizer=Adam(learning_rate=config.INITIAL_LR),
        loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
        metrics=['accuracy', 
                 tf.keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy'),
                 tf.keras.metrics.Precision(name='precision'),
                 tf.keras.metrics.Recall(name='recall')]
    )
    
    # Get callbacks
    callbacks = get_callbacks(config, model_type)
    
    # ==================== PHASE 1: Train Classification Head ====================
    print("\n" + "="*70)
    print("📚 PHASE 1: Training Classification Head (20 epochs)")
    print("="*70 + "\n")
    
    history_phase1 = model.fit(
        train_gen,
        epochs=20,
        validation_data=val_gen,
        callbacks=callbacks,
        verbose=1
    )
    
    # ==================== PHASE 2: Fine-tune Entire Model ====================
    print("\n" + "="*70)
    print("🔧 PHASE 2: Fine-tuning Entire Model")
    print("="*70 + "\n")
    
    # Unfreeze base model
    base_model.trainable = True
    
    # Freeze early layers, fine-tune later layers
    fine_tune_at = len(base_model.layers) // 2
    for layer in base_model.layers[:fine_tune_at]:
        layer.trainable = False
    
    print(f"Trainable layers: {sum([1 for layer in model.layers if layer.trainable])}")
    
    # Recompile with lower learning rate
    model.compile(
        optimizer=Adam(learning_rate=config.INITIAL_LR / 10),  # 10x lower LR
        loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
        metrics=['accuracy', 
                 tf.keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy'),
                 tf.keras.metrics.Precision(name='precision'),
                 tf.keras.metrics.Recall(name='recall')]
    )
    
    # Continue training
    history_phase2 = model.fit(
        train_gen,
        epochs=config.EPOCHS - 20,  # Remaining epochs
        validation_data=val_gen,
        callbacks=callbacks,
        initial_epoch=20,
        verbose=1
    )
    
    # ==================== Save Final Model ====================
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    final_model_path = os.path.join(config.MODEL_DIR, f'{model_type}_final_{timestamp}.h5')
    model.save(final_model_path)
    print(f"\n✅ Final model saved: {final_model_path}")
    
    # Convert to TFLite
    convert_to_tflite(model, model_type, config)
    
    # Evaluate on validation set
    print("\n" + "="*70)
    print("📊 FINAL EVALUATION")
    print("="*70 + "\n")
    
    results = model.evaluate(val_gen, verbose=1)
    metrics_names = model.metrics_names
    
    print("\n🎯 Final Metrics:")
    for name, value in zip(metrics_names, results):
        print(f"   {name}: {value:.4f}")
    
    # Save training history
    history_path = os.path.join(config.LOGS_DIR, f'{model_type}_history_{timestamp}.json')
    with open(history_path, 'w') as f:
        json.dump({
            'phase1': history_phase1.history,
            'phase2': history_phase2.history
        }, f, indent=2, default=str)
    
    return model, history_phase1, history_phase2

def convert_to_tflite(model, model_type, config):
    """Convert trained model to TensorFlow Lite"""
    
    print("\n📱 Converting to TFLite...")
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    tflite_path = os.path.join(config.MODEL_DIR, f'{model_type}_model_{timestamp}.tflite')
    
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    # Get file size
    size_mb = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"✅ TFLite model saved: {tflite_path} ({size_mb:.2f} MB)")

def check_dataset(config):
    """Check if dataset exists and is properly organized"""
    
    print("\n🔍 Checking dataset...")
    
    # Check directories
    for dir_name, dir_path in [
        ("Training", config.TRAIN_DIR),
        ("Validation", config.VAL_DIR)
    ]:
        if not os.path.exists(dir_path):
            print(f"❌ {dir_name} directory not found: {dir_path}")
            return False
        
        # Count classes
        classes = [d for d in os.listdir(dir_path) 
                  if os.path.isdir(os.path.join(dir_path, d)) and not d.startswith('.')]
        
        # Count images
        total_images = sum([len(os.listdir(os.path.join(dir_path, cls))) 
                           for cls in classes])
        
        print(f"✅ {dir_name}: {len(classes)} classes, {total_images} images")
        
        # Warn if insufficient data
        if total_images < 1000:
            print(f"⚠️  Warning: Only {total_images} images. Recommend 2000+ per class for best accuracy")
    
    return True

def main():
    """Main training script"""
    
    config = Config()
    
    print("\n" + "="*70)
    print("🌱 PRAKRUTI - Advanced Plant Disease Detection Training")
    print("="*70 + "\n")
    
    # Check GPU
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"✅ GPU available: {gpus}")
        # Enable mixed precision for faster training
        from tensorflow.keras import mixed_precision
        policy = mixed_precision.Policy('mixed_float16')
        mixed_precision.set_global_policy(policy)
        print("✅ Mixed precision enabled (faster training)")
    else:
        print("⚠️  No GPU found, training will be slower on CPU")
    
    # Check dataset
    if not check_dataset(config):
        print("\n❌ Dataset check failed!")
        print("\n📋 Dataset should be organized as:")
        print("""
        dataset/
        ├── train/
        │   ├── Healthy/
        │   ├── Rice_Blast/
        │   ├── Wheat_Rust_Yellow/
        │   └── ... (all 47 classes)
        └── validation/
            ├── Healthy/
            ├── Rice_Blast/
            └── ... (all 47 classes)
        """)
        return
    
    # Train models
    model_types = ['efficientnetv2b0']  # Add more: 'efficientnetv2b1'
    
    for model_type in model_types:
        try:
            model, hist1, hist2 = train_model(config, model_type)
            print(f"\n🎉 {model_type.upper()} training completed successfully!")
        except Exception as e:
            print(f"\n❌ Error training {model_type}: {str(e)}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "="*70)
    print("✅ TRAINING COMPLETED!")
    print("="*70)
    print(f"\nModels saved in: {config.MODEL_DIR}")
    print(f"Training logs in: {config.LOGS_DIR}")
    print("\nTo visualize training:")
    print(f"  tensorboard --logdir {config.LOGS_DIR}")

if __name__ == "__main__":
    main()
