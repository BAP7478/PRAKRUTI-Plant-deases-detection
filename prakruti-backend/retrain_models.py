#!/usr/bin/env python3
"""
Retrain Pre-trained Models for Plant Disease Detection
Convert ImageNet models (1000 classes) to Plant Disease models (47 classes)
"""

import tensorflow as tf
from tensorflow.keras.applications import ResNet50, MobileNetV2, EfficientNetB0
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import numpy as np
import os

# Plant Disease Classes (from your config.py)
PLANT_DISEASE_CLASSES = [
    "Healthy",
    "Rice_Blast", "Rice_Brown_Spot", "Rice_Bacterial_Blight",
    "Wheat_Rust_Yellow", "Wheat_Rust_Brown", "Wheat_Rust_Black",
    "Maize_Common_Rust", "Maize_Northern_Leaf_Blight",
    "Cotton_Bacterial_Blight", "Cotton_Fusarium_Wilt",
    "Sugarcane_Red_Rot", "Sugarcane_Smut",
    "Potato_Late_Blight", "Potato_Early_Blight",
    "Chili_Leaf_Curl", "Chili_Anthracnose",
    "Onion_Purple_Blotch", "Groundnut_Tikka",
    # Add all 47 classes here...
]

NUM_CLASSES = len(PLANT_DISEASE_CLASSES)  # 47 classes
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 20

class PlantDiseaseModelTrainer:
    """Train plant disease detection models using transfer learning"""
    
    def __init__(self, data_dir: str):
        """
        Initialize trainer
        Args:
            data_dir: Path to dataset organized as:
                data_dir/
                ├── train/
                │   ├── Healthy/
                │   ├── Rice_Blast/
                │   ├── Rice_Brown_Spot/
                │   └── ...
                └── validation/
                    ├── Healthy/
                    ├── Rice_Blast/
                    └── ...
        """
        self.data_dir = data_dir
        self.train_dir = os.path.join(data_dir, 'train')
        self.val_dir = os.path.join(data_dir, 'validation')
        
    def create_data_generators(self):
        """Create data augmentation and preprocessing generators"""
        
        # Training data augmentation
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            fill_mode='nearest'
        )
        
        # Validation data (no augmentation)
        val_datagen = ImageDataGenerator(rescale=1./255)
        
        # Create generators
        train_generator = train_datagen.flow_from_directory(
            self.train_dir,
            target_size=IMG_SIZE,
            batch_size=BATCH_SIZE,
            class_mode='categorical',
            classes=PLANT_DISEASE_CLASSES
        )
        
        val_generator = val_datagen.flow_from_directory(
            self.val_dir,
            target_size=IMG_SIZE,
            batch_size=BATCH_SIZE,
            class_mode='categorical',
            classes=PLANT_DISEASE_CLASSES
        )
        
        return train_generator, val_generator
    
    def create_resnet50_model(self):
        """Create ResNet50 model for plant disease detection"""
        
        # Load pre-trained ResNet50 (without top layer)
        base_model = ResNet50(
            weights='imagenet',
            include_top=False,
            input_shape=(*IMG_SIZE, 3)
        )
        
        # Freeze base model layers initially
        base_model.trainable = False
        
        # Add custom classification head
        x = base_model.output
        x = GlobalAveragePooling2D()(x)
        x = Dense(512, activation='relu')(x)
        x = Dropout(0.5)(x)
        predictions = Dense(NUM_CLASSES, activation='softmax')(x)  # 47 classes
        
        model = Model(inputs=base_model.input, outputs=predictions)
        
        return model, base_model
    
    def create_mobilenet_model(self):
        """Create MobileNetV2 model for plant disease detection"""
        
        # Load pre-trained MobileNetV2
        base_model = MobileNetV2(
            weights='imagenet',
            include_top=False,
            input_shape=(*IMG_SIZE, 3)
        )
        
        base_model.trainable = False
        
        # Add custom head
        x = base_model.output
        x = GlobalAveragePooling2D()(x)
        x = Dense(256, activation='relu')(x)
        x = Dropout(0.3)(x)
        predictions = Dense(NUM_CLASSES, activation='softmax')(x)
        
        model = Model(inputs=base_model.input, outputs=predictions)
        
        return model, base_model
    
    def create_efficientnet_model(self):
        """Create EfficientNetB0 model for plant disease detection"""
        
        # Load pre-trained EfficientNetB0
        base_model = EfficientNetB0(
            weights='imagenet',
            include_top=False,
            input_shape=(*IMG_SIZE, 3)
        )
        
        base_model.trainable = False
        
        # Add custom head
        x = base_model.output
        x = GlobalAveragePooling2D()(x)
        x = Dense(256, activation='relu')(x)
        x = Dropout(0.4)(x)
        predictions = Dense(NUM_CLASSES, activation='softmax')(x)
        
        model = Model(inputs=base_model.input, outputs=predictions)
        
        return model, base_model
    
    def train_model(self, model_type='resnet50'):
        """Train a specific model type"""
        
        print(f"🚀 Starting training for {model_type.upper()}")
        
        # Create data generators
        train_gen, val_gen = self.create_data_generators()
        
        # Create model
        if model_type == 'resnet50':
            model, base_model = self.create_resnet50_model()
        elif model_type == 'mobilenet':
            model, base_model = self.create_mobilenet_model()
        elif model_type == 'efficientnet':
            model, base_model = self.create_efficientnet_model()
        else:
            raise ValueError(f"Unknown model type: {model_type}")
        
        # Compile model
        model.compile(
            optimizer=Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_3_accuracy']
        )
        
        print(f"📊 Model Summary:")
        model.summary()
        
        # Callbacks
        callbacks = [
            tf.keras.callbacks.EarlyStopping(
                monitor='val_accuracy',
                patience=5,
                restore_best_weights=True
            ),
            tf.keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=3,
                min_lr=1e-7
            ),
            tf.keras.callbacks.ModelCheckpoint(
                f'models/{model_type}_plant_disease_model.h5',
                monitor='val_accuracy',
                save_best_only=True,
                verbose=1
            )
        ]
        
        # Phase 1: Train only the top layers
        print("📚 Phase 1: Training classification head...")
        history1 = model.fit(
            train_gen,
            epochs=10,
            validation_data=val_gen,
            callbacks=callbacks,
            verbose=1
        )
        
        # Phase 2: Fine-tune some base model layers
        print("🔧 Phase 2: Fine-tuning base model...")
        base_model.trainable = True
        
        # Freeze early layers, fine-tune later layers
        fine_tune_at = len(base_model.layers) // 2
        for layer in base_model.layers[:fine_tune_at]:
            layer.trainable = False
        
        # Recompile with lower learning rate
        model.compile(
            optimizer=Adam(learning_rate=0.0001),  # Lower LR for fine-tuning
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_3_accuracy']
        )
        
        history2 = model.fit(
            train_gen,
            epochs=EPOCHS - 10,
            validation_data=val_gen,
            callbacks=callbacks,
            verbose=1
        )
        
        # Save final model
        model.save(f'models/{model_type}_plant_disease_final.h5')
        
        # Convert to TFLite for mobile deployment
        self.convert_to_tflite(model, model_type)
        
        print(f"✅ Training completed! Models saved:")
        print(f"   - models/{model_type}_plant_disease_model.h5")
        print(f"   - models/{model_type}_plant_disease_final.h5")
        print(f"   - models/{model_type}_plant_disease_model.tflite")
        
        return model, history1, history2
    
    def convert_to_tflite(self, model, model_type):
        """Convert trained model to TensorFlow Lite"""
        
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Optional: Use quantization for smaller models
        # converter.target_spec.supported_types = [tf.float16]
        
        tflite_model = converter.convert()
        
        # Save TFLite model
        tflite_path = f'models/{model_type}_plant_disease_model.tflite'
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"📱 TFLite model saved: {tflite_path}")
    
    def evaluate_model(self, model_path, model_type='h5'):
        """Evaluate trained model"""
        
        if model_type == 'h5':
            model = tf.keras.models.load_model(model_path)
        else:
            # Load TFLite model
            interpreter = tf.lite.Interpreter(model_path=model_path)
            interpreter.allocate_tensors()
        
        _, val_gen = self.create_data_generators()
        
        if model_type == 'h5':
            results = model.evaluate(val_gen, verbose=1)
            print(f"📊 Model Evaluation Results:")
            print(f"   - Loss: {results[0]:.4f}")
            print(f"   - Accuracy: {results[1]:.4f}")
            print(f"   - Top-3 Accuracy: {results[2]:.4f}")
        
        return results

def main():
    """Main training script"""
    
    # Example usage - you need to prepare your dataset first
    data_directory = "path/to/your/plant_disease_dataset"
    
    if not os.path.exists(data_directory):
        print("❌ Dataset directory not found!")
        print("📋 Please organize your dataset as follows:")
        print("""
        dataset/
        ├── train/
        │   ├── Healthy/
        │   ├── Rice_Blast/
        │   ├── Rice_Brown_Spot/
        │   └── ... (all 47 classes)
        └── validation/
            ├── Healthy/
            ├── Rice_Blast/
            └── ... (all 47 classes)
        """)
        return
    
    trainer = PlantDiseaseModelTrainer(data_directory)
    
    # Train all models
    models = ['mobilenet', 'efficientnet', 'resnet50']
    
    for model_type in models:
        print(f"\n{'='*50}")
        print(f"🌱 Training {model_type.upper()} for Plant Disease Detection")
        print(f"{'='*50}")
        
        model, hist1, hist2 = trainer.train_model(model_type)
        
        # Evaluate the model
        model_path = f'models/{model_type}_plant_disease_final.h5'
        trainer.evaluate_model(model_path)

if __name__ == "__main__":
    main()
