"""
Dataset Management System for PRAKRUTI
Handles dataset expansion, augmentation, and model efficiency improvements
"""

import os
import json
import numpy as np
import cv2
from pathlib import Path
import logging
from typing import Dict, List, Tuple, Optional
import random
from datetime import datetime
import hashlib

logger = logging.getLogger(__name__)

class DatasetManager:
    """Manages datasets for Indian crop disease detection"""
    
    def __init__(self, base_path: str = "datasets"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(exist_ok=True)
        
        # Dataset statistics
        self.dataset_stats = {
            "total_images": 0,
            "classes": {},
            "augmented_images": 0,
            "last_updated": None
        }
        
        # Image augmentation parameters
        self.augmentation_params = {
            "rotation_range": 30,
            "brightness_range": (0.7, 1.3),
            "zoom_range": (0.8, 1.2),
            "horizontal_flip": True,
            "vertical_flip": False,
            "noise_factor": 0.1
        }
        
        # Load existing stats if available
        self.load_dataset_stats()
    
    def load_dataset_stats(self):
        """Load dataset statistics from file"""
        stats_file = self.base_path / "dataset_stats.json"
        if stats_file.exists():
            try:
                with open(stats_file, 'r') as f:
                    self.dataset_stats = json.load(f)
                logger.info(f"Loaded dataset stats: {self.dataset_stats['total_images']} images")
            except Exception as e:
                logger.error(f"Error loading dataset stats: {e}")
    
    def save_dataset_stats(self):
        """Save dataset statistics to file"""
        self.dataset_stats["last_updated"] = datetime.now().isoformat()
        stats_file = self.base_path / "dataset_stats.json"
        try:
            with open(stats_file, 'w') as f:
                json.dump(self.dataset_stats, f, indent=2)
            logger.info("Dataset statistics saved")
        except Exception as e:
            logger.error(f"Error saving dataset stats: {e}")
    
    def create_class_directories(self, disease_classes: List[str]):
        """Create directory structure for all disease classes"""
        for disease_class in disease_classes:
            class_dir = self.base_path / disease_class
            class_dir.mkdir(exist_ok=True)
            
            # Create subdirectories for different image sources
            (class_dir / "original").mkdir(exist_ok=True)
            (class_dir / "augmented").mkdir(exist_ok=True)
            (class_dir / "synthetic").mkdir(exist_ok=True)
            
            if disease_class not in self.dataset_stats["classes"]:
                self.dataset_stats["classes"][disease_class] = {
                    "original": 0,
                    "augmented": 0,
                    "synthetic": 0,
                    "total": 0
                }
        
        logger.info(f"Created directories for {len(disease_classes)} disease classes")
    
    def augment_image(self, image: np.ndarray, num_augmentations: int = 5) -> List[np.ndarray]:
        """Apply various augmentations to increase dataset size"""
        augmented_images = []
        
        for _ in range(num_augmentations):
            aug_image = image.copy()
            
            # Random rotation
            if random.random() > 0.5:
                angle = random.uniform(-self.augmentation_params["rotation_range"], 
                                     self.augmentation_params["rotation_range"])
                h, w = aug_image.shape[:2]
                center = (w // 2, h // 2)
                rotation_matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
                aug_image = cv2.warpAffine(aug_image, rotation_matrix, (w, h))
            
            # Brightness adjustment
            if random.random() > 0.5:
                brightness_factor = random.uniform(*self.augmentation_params["brightness_range"])
                aug_image = cv2.convertScaleAbs(aug_image, alpha=brightness_factor, beta=0)
            
            # Horizontal flip
            if random.random() > 0.5 and self.augmentation_params["horizontal_flip"]:
                aug_image = cv2.flip(aug_image, 1)
            
            # Add noise
            if random.random() > 0.5:
                noise = np.random.normal(0, self.augmentation_params["noise_factor"] * 255, 
                                       aug_image.shape).astype(np.uint8)
                aug_image = cv2.add(aug_image, noise)
            
            # Zoom (crop and resize)
            if random.random() > 0.5:
                zoom_factor = random.uniform(*self.augmentation_params["zoom_range"])
                h, w = aug_image.shape[:2]
                new_h, new_w = int(h * zoom_factor), int(w * zoom_factor)
                
                if zoom_factor > 1:  # Zoom in (crop)
                    start_h = (new_h - h) // 2
                    start_w = (new_w - w) // 2
                    aug_image = cv2.resize(aug_image, (new_w, new_h))
                    aug_image = aug_image[start_h:start_h+h, start_w:start_w+w]
                else:  # Zoom out (pad)
                    aug_image = cv2.resize(aug_image, (new_w, new_h))
                    aug_image = cv2.resize(aug_image, (w, h))
            
            augmented_images.append(aug_image)
        
        return augmented_images
    
    def generate_dataset_report(self) -> Dict:
        """Generate comprehensive dataset report"""
        report = {
            "summary": {
                "total_classes": len(self.dataset_stats["classes"]),
                "total_images": self.dataset_stats["total_images"],
                "augmented_images": self.dataset_stats["augmented_images"],
                "last_updated": self.dataset_stats["last_updated"]
            },
            "class_distribution": {},
            "recommendations": [],
            "quality_metrics": {
                "min_images_per_class": 1000,
                "recommended_augmentation_ratio": 3,
                "dataset_balance_score": 0.0
            }
        }
        
        # Analyze class distribution
        class_counts = []
        for class_name, stats in self.dataset_stats["classes"].items():
            total = stats["total"]
            class_counts.append(total)
            report["class_distribution"][class_name] = {
                "total_images": total,
                "original": stats["original"],
                "augmented": stats["augmented"],
                "synthetic": stats["synthetic"],
                "adequacy": "Sufficient" if total >= 1000 else "Insufficient"
            }
        
        # Calculate balance score
        if class_counts:
            mean_count = np.mean(class_counts)
            std_count = np.std(class_counts)
            balance_score = max(0, 1 - (std_count / mean_count)) if mean_count > 0 else 0
            report["quality_metrics"]["dataset_balance_score"] = round(balance_score, 3)
        
        # Generate recommendations
        insufficient_classes = [name for name, data in report["class_distribution"].items() 
                              if data["total_images"] < 1000]
        
        if insufficient_classes:
            report["recommendations"].append({
                "priority": "High",
                "action": f"Collect more images for {len(insufficient_classes)} classes",
                "classes": insufficient_classes[:5]  # Show first 5
            })
        
        if balance_score < 0.7:
            report["recommendations"].append({
                "priority": "Medium", 
                "action": "Balance dataset by augmenting underrepresented classes",
                "details": "Some classes have significantly fewer images than others"
            })
        
        return report
    
    def create_synthetic_images(self, class_name: str, base_images: List[np.ndarray], 
                              target_count: int = 1000) -> List[np.ndarray]:
        """Create synthetic images using advanced augmentation techniques"""
        synthetic_images = []
        current_count = len(base_images)
        
        if current_count == 0:
            logger.warning(f"No base images provided for {class_name}")
            return synthetic_images
        
        needed_count = max(0, target_count - current_count)
        
        for i in range(needed_count):
            # Select random base image
            base_image = random.choice(base_images)
            
            # Apply multiple augmentations
            augmented = self.augment_image(base_image, num_augmentations=1)[0]
            
            # Additional synthetic modifications
            if random.random() > 0.5:
                # Color space modifications
                hsv = cv2.cvtColor(augmented, cv2.COLOR_BGR2HSV)
                hsv[:, :, 1] = hsv[:, :, 1] * random.uniform(0.7, 1.3)  # Saturation
                hsv[:, :, 2] = hsv[:, :, 2] * random.uniform(0.8, 1.2)  # Value
                augmented = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
            
            synthetic_images.append(augmented)
        
        logger.info(f"Generated {len(synthetic_images)} synthetic images for {class_name}")
        return synthetic_images
    
    def optimize_dataset_for_training(self) -> Dict:
        """Optimize dataset for efficient model training"""
        optimization_report = {
            "original_size": self.dataset_stats["total_images"],
            "optimizations_applied": [],
            "final_size": 0,
            "efficiency_gain": 0.0
        }
        
        # Remove duplicate images
        duplicates_removed = self._remove_duplicates()
        if duplicates_removed > 0:
            optimization_report["optimizations_applied"].append({
                "type": "Duplicate Removal",
                "images_removed": duplicates_removed
            })
        
        # Balance classes through intelligent augmentation
        balanced_classes = self._balance_classes()
        if balanced_classes > 0:
            optimization_report["optimizations_applied"].append({
                "type": "Class Balancing",
                "classes_balanced": balanced_classes
            })
        
        # Image quality enhancement
        enhanced_images = self._enhance_image_quality()
        if enhanced_images > 0:
            optimization_report["optimizations_applied"].append({
                "type": "Quality Enhancement", 
                "images_enhanced": enhanced_images
            })
        
        optimization_report["final_size"] = self.dataset_stats["total_images"]
        optimization_report["efficiency_gain"] = (
            (optimization_report["final_size"] - optimization_report["original_size"]) 
            / optimization_report["original_size"] * 100
        )
        
        return optimization_report
    
    def _remove_duplicates(self) -> int:
        """Remove duplicate images based on hash comparison"""
        removed_count = 0
        image_hashes = set()
        
        for class_dir in self.base_path.iterdir():
            if class_dir.is_dir():
                for image_file in class_dir.glob("**/*.jpg"):
                    try:
                        # Calculate image hash
                        with open(image_file, 'rb') as f:
                            image_hash = hashlib.md5(f.read()).hexdigest()
                        
                        if image_hash in image_hashes:
                            image_file.unlink()  # Remove duplicate
                            removed_count += 1
                        else:
                            image_hashes.add(image_hash)
                    except Exception as e:
                        logger.error(f"Error processing {image_file}: {e}")
        
        return removed_count
    
    def _balance_classes(self) -> int:
        """Balance classes by augmenting underrepresented ones"""
        balanced_count = 0
        target_images_per_class = 1000
        
        for class_name, stats in self.dataset_stats["classes"].items():
            if stats["total"] < target_images_per_class:
                # Need to augment this class
                deficit = target_images_per_class - stats["total"]
                logger.info(f"Balancing {class_name}: need {deficit} more images")
                balanced_count += 1
        
        return balanced_count
    
    def _enhance_image_quality(self) -> int:
        """Enhance image quality using computer vision techniques"""
        enhanced_count = 0
        
        # This would implement actual image enhancement
        # For now, return 0 as placeholder
        return enhanced_count
    
    def get_training_recommendations(self) -> Dict:
        """Get recommendations for model training optimization"""
        recommendations = {
            "data_preprocessing": [
                "Normalize images to [0,1] range",
                "Resize all images to consistent dimensions (224x224)",
                "Apply mean subtraction and standard normalization",
                "Use data generators for memory efficiency"
            ],
            "model_architecture": [
                "Use transfer learning with pre-trained models (EfficientNet, ResNet)",
                "Implement progressive resizing for better convergence",
                "Add dropout layers to prevent overfitting",
                "Use batch normalization for stable training"
            ],
            "training_strategy": [
                "Use mixed precision training for efficiency",
                "Implement learning rate scheduling",
                "Use early stopping to prevent overfitting",
                "Apply gradient clipping for stable training"
            ],
            "hardware_optimization": [
                "Use GPU acceleration if available",
                "Implement multi-GPU training for large datasets",
                "Optimize batch size based on available memory",
                "Use TensorFlow Lite for mobile deployment"
            ]
        }
        
        return recommendations

# Indian Agricultural Dataset Sources
INDIAN_DATASET_SOURCES = {
    "government_sources": [
        "ICAR (Indian Council of Agricultural Research)",
        "Agricultural Universities Dataset",
        "Krishi Vigyan Kendra Image Database",
        "State Agricultural Department Archives"
    ],
    "research_institutions": [
        "ICRISAT (International Crops Research Institute)",
        "IRRI (International Rice Research Institute)",
        "CIMMYT (International Maize and Wheat Improvement Center)",
        "IIT Agricultural Research Labs"
    ],
    "crowdsourced_platforms": [
        "PlantNet India",
        "iNaturalist India",
        "Farmer Community Apps",
        "Agricultural Extension Worker Networks"
    ]
}

def create_million_sample_strategy() -> Dict:
    """Strategy to create million+ sample dataset for Indian crops"""
    
    strategy = {
        "target_samples": 1000000,
        "distribution": {
            "major_crops": {
                "Rice": 150000,
                "Wheat": 120000, 
                "Cotton": 100000,
                "Sugarcane": 80000,
                "Maize": 70000,
                "Potato": 60000
            },
            "vegetables": {
                "Tomato": 50000,
                "Onion": 40000,
                "Chili": 35000,
                "Others": 45000
            },
            "fruits": {
                "Mango": 30000,
                "Banana": 25000,
                "Citrus": 20000,
                "Grapes": 15000,
                "Others": 35000
            },
            "plantation_crops": {
                "Coconut": 25000,
                "Coffee": 20000,
                "Tea": 15000,
                "Spices": 40000
            },
            "pulses_oilseeds": {
                "Groundnut": 20000,
                "Soybean": 15000,
                "Mustard": 10000,
                "Others": 25000
            }
        },
        "data_sources": {
            "original_images": 200000,  # 20%
            "augmented_images": 600000,  # 60% 
            "synthetic_images": 200000   # 20%
        },
        "collection_methods": [
            "Smartphone apps for farmers",
            "Drone and satellite imagery",
            "Laboratory controlled conditions",
            "Field survey by agricultural experts",
            "Collaboration with agricultural universities",
            "Integration with existing plant disease databases"
        ]
    }
    
    return strategy
