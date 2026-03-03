#!/usr/bin/env python3
"""
Dataset Preparation for Plant Disease Detection
Organize images into proper directory structure for training
"""

import os
import shutil
from pathlib import Path
import random
from PIL import Image
import json

# Your 47 plant disease classes
DISEASE_CLASSES = [
    "Healthy",
    "Rice_Blast", "Rice_Brown_Spot", "Rice_Bacterial_Blight", "Rice_Hispa", 
    "Rice_Tungro", "Rice_Leaf_Scald", "Rice_Narrow_Brown_Spot",
    "Wheat_Rust_Yellow", "Wheat_Rust_Brown", "Wheat_Rust_Black", "Wheat_Septoria", 
    "Wheat_Tan_Spot", "Wheat_Powdery_Mildew", "Wheat_Loose_Smut",
    "Maize_Common_Rust", "Maize_Northern_Leaf_Blight", "Maize_Gray_Leaf_Spot", 
    "Maize_Southern_Rust", "Maize_Ear_Rot",
    "Cotton_Bacterial_Blight", "Cotton_Fusarium_Wilt", "Cotton_Verticillium_Wilt", 
    "Cotton_Target_Spot", "Cotton_Alternaria_Leaf_Spot",
    "Sugarcane_Red_Rot", "Sugarcane_Smut", "Sugarcane_Rust", "Sugarcane_Ring_Spot",
    "Potato_Late_Blight", "Potato_Early_Blight", "Potato_Common_Scab", "Potato_Black_Scurf",
    "Tomato_Late_Blight", "Tomato_Early_Blight", "Tomato_Leaf_Mold", "Tomato_Septoria_Leaf_Spot",
    "Chili_Leaf_Curl", "Chili_Anthracnose", "Chili_Bacterial_Spot",
    "Onion_Purple_Blotch", "Onion_Stemphylium_Blight",
    "Groundnut_Tikka", "Groundnut_Rust", "Groundnut_Late_Leaf_Spot",
    "Apple_Scab"
]

class DatasetOrganizer:
    """Organize plant disease images into training structure"""
    
    def __init__(self, source_dir: str, output_dir: str = "plant_disease_dataset"):
        """
        Args:
            source_dir: Directory containing raw images
            output_dir: Output directory for organized dataset
        """
        self.source_dir = Path(source_dir)
        self.output_dir = Path(output_dir)
        self.train_split = 0.8  # 80% for training, 20% for validation
        
    def create_directory_structure(self):
        """Create train/validation directory structure"""
        
        print("📁 Creating directory structure...")
        
        for split in ['train', 'validation']:
            for disease_class in DISEASE_CLASSES:
                class_dir = self.output_dir / split / disease_class
                class_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"✅ Created directories for {len(DISEASE_CLASSES)} classes")
    
    def organize_existing_dataset(self, annotation_file=None):
        """
        Organize existing dataset if you have images with annotations
        
        Expected structure of source_dir:
        source_dir/
        ├── healthy_plant1.jpg
        ├── rice_blast_1.jpg
        ├── wheat_rust_2.jpg
        └── annotations.json  # Optional: {"image_name": "class_name"}
        """
        
        if annotation_file and os.path.exists(annotation_file):
            with open(annotation_file, 'r') as f:
                annotations = json.load(f)
        else:
            annotations = {}
        
        image_files = list(self.source_dir.glob("*.jpg")) + \
                     list(self.source_dir.glob("*.png")) + \
                     list(self.source_dir.glob("*.jpeg"))
        
        print(f"📸 Found {len(image_files)} images")
        
        class_counts = {cls: [] for cls in DISEASE_CLASSES}
        
        # Organize images by class
        for img_path in image_files:
            img_name = img_path.name
            
            # Try to get class from annotations
            if img_name in annotations:
                predicted_class = annotations[img_name]
            else:
                # Try to infer class from filename
                predicted_class = self.infer_class_from_filename(img_name)
            
            if predicted_class in DISEASE_CLASSES:
                class_counts[predicted_class].append(img_path)
            else:
                print(f"⚠️  Unknown class for {img_name}, adding to 'Healthy'")
                class_counts['Healthy'].append(img_path)
        
        # Split and copy images
        for class_name, images in class_counts.items():
            if not images:
                print(f"⚠️  No images found for class: {class_name}")
                continue
                
            random.shuffle(images)
            train_count = int(len(images) * self.train_split)
            
            train_images = images[:train_count]
            val_images = images[train_count:]
            
            # Copy training images
            for img_path in train_images:
                dst_path = self.output_dir / 'train' / class_name / img_path.name
                shutil.copy2(img_path, dst_path)
            
            # Copy validation images
            for img_path in val_images:
                dst_path = self.output_dir / 'validation' / class_name / img_path.name
                shutil.copy2(img_path, dst_path)
            
            print(f"📊 {class_name}: {len(train_images)} train, {len(val_images)} val")
    
    def infer_class_from_filename(self, filename: str) -> str:
        """Try to infer disease class from filename"""
        
        filename_lower = filename.lower()
        
        # Common keywords mapping
        keyword_mapping = {
            'healthy': 'Healthy',
            'blast': 'Rice_Blast',
            'brown_spot': 'Rice_Brown_Spot', 
            'bacterial_blight': 'Rice_Bacterial_Blight',
            'yellow_rust': 'Wheat_Rust_Yellow',
            'brown_rust': 'Wheat_Rust_Brown',
            'black_rust': 'Wheat_Rust_Black',
            'common_rust': 'Maize_Common_Rust',
            'leaf_blight': 'Maize_Northern_Leaf_Blight',
            'late_blight': 'Potato_Late_Blight',
            'early_blight': 'Potato_Early_Blight',
            'leaf_curl': 'Chili_Leaf_Curl',
            'anthracnose': 'Chili_Anthracnose',
            'purple_blotch': 'Onion_Purple_Blotch',
            'tikka': 'Groundnut_Tikka',
        }
        
        for keyword, disease_class in keyword_mapping.items():
            if keyword in filename_lower:
                return disease_class
        
        # Default to healthy if no match
        return 'Healthy'
    
    def download_plantvillage_dataset(self):
        """Download PlantVillage dataset (example)"""
        
        print("📥 To download PlantVillage dataset:")
        print("1. Go to: https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset")
        print("2. Download the dataset")
        print("3. Extract to a directory")
        print("4. Run this script with the extracted directory as source_dir")
        
    def validate_dataset(self):
        """Validate the organized dataset"""
        
        print("🔍 Validating dataset...")
        
        total_train = 0
        total_val = 0
        
        for class_name in DISEASE_CLASSES:
            train_dir = self.output_dir / 'train' / class_name
            val_dir = self.output_dir / 'validation' / class_name
            
            train_count = len(list(train_dir.glob("*"))) if train_dir.exists() else 0
            val_count = len(list(val_dir.glob("*"))) if val_dir.exists() else 0
            
            total_train += train_count
            total_val += val_count
            
            if train_count == 0:
                print(f"⚠️  {class_name}: No training images!")
            elif train_count < 10:
                print(f"⚠️  {class_name}: Only {train_count} training images (recommend >50)")
            else:
                print(f"✅ {class_name}: {train_count} train, {val_count} val")
        
        print(f"\n📊 Dataset Summary:")
        print(f"   Total Training Images: {total_train}")
        print(f"   Total Validation Images: {total_val}")
        print(f"   Total Classes: {len(DISEASE_CLASSES)}")
        
        if total_train < 1000:
            print("⚠️  Recommendation: Collect more training data (>1000 images total)")
        
        return total_train, total_val
    
    def create_sample_annotations(self):
        """Create sample annotations file"""
        
        sample_annotations = {
            "healthy_rice_001.jpg": "Healthy",
            "rice_blast_sample_001.jpg": "Rice_Blast",
            "wheat_yellow_rust_001.jpg": "Wheat_Rust_Yellow",
            "potato_late_blight_001.jpg": "Potato_Late_Blight",
            # Add more examples...
        }
        
        annotation_file = self.output_dir / "sample_annotations.json"
        with open(annotation_file, 'w') as f:
            json.dump(sample_annotations, f, indent=2)
        
        print(f"📝 Sample annotations created: {annotation_file}")

def main():
    """Main dataset organization script"""
    
    print("🌱 PRAKRUTI Dataset Organizer")
    print("=" * 40)
    
    # Configuration
    source_directory = "raw_plant_images"  # Change this to your image directory
    output_directory = "plant_disease_dataset"
    
    organizer = DatasetOrganizer(source_directory, output_directory)
    
    # Create directory structure
    organizer.create_directory_structure()
    
    # Check if source directory exists
    if not os.path.exists(source_directory):
        print(f"❌ Source directory not found: {source_directory}")
        print("\n📋 To prepare your dataset:")
        print("1. Create a directory with your plant images")
        print("2. Name images descriptively (e.g., 'rice_blast_001.jpg')")
        print("3. Or create annotations.json with image->class mappings")
        print("4. Update source_directory in this script")
        
        # Show how to download popular datasets
        organizer.download_plantvillage_dataset()
        
        # Create sample structure
        organizer.create_sample_annotations()
        return
    
    # Organize the dataset
    print(f"\n📁 Organizing images from: {source_directory}")
    organizer.organize_existing_dataset()
    
    # Validate the result
    print(f"\n🔍 Validation Results:")
    train_count, val_count = organizer.validate_dataset()
    
    if train_count > 0:
        print(f"\n✅ Dataset ready for training!")
        print(f"📂 Output directory: {output_directory}")
        print(f"\n🚀 Next steps:")
        print(f"1. Update data_directory in retrain_models.py")
        print(f"2. Run: python3 retrain_models.py")
    else:
        print(f"\n❌ No images organized. Check your source directory and file naming.")

if __name__ == "__main__":
    main()
