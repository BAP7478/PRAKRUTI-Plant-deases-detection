"""
Configuration management for PRAKRUTI Backend
Handles environment variables and application settings
"""

import os
from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import field_validator
from pathlib import Path
import logging

# Configure logging for config module
logger = logging.getLogger(__name__)

class Settings(BaseSettings):
    """Application settings with environment variable support"""
    
    # API Settings
    app_name: str = "🌱 PRAKRUTI Backend"
    app_version: str = "2.0"
    debug: bool = False
    
    # Server Settings
    host: str = "0.0.0.0"
    port: int = 8000
    reload: bool = True
    workers: int = 1
    
    # Security Settings
    allowed_origins: List[str] = ["*"]
    max_file_size: int = 10 * 1024 * 1024  # 10MB
    api_key: Optional[str] = None
    
    # Model Settings
    model_path: str = "models/mobilenet_model.tflite"
    model_warm_up: bool = True
    
    # Performance Settings
    max_concurrent_requests: int = 10
    thread_pool_workers: int = 4
    cache_ttl: int = 3600  # 1 hour
    cache_size: int = 1000
    
    # Database Settings (for future use)
    database_url: Optional[str] = None
    
    # External API Settings
    weather_api_key: Optional[str] = None
    weather_api_url: str = "https://api.openweathermap.org/data/2.5"
    
    # AI Chatbot API Settings
    openai_api_key: Optional[str] = None
    gemini_api_key: Optional[str] = None
    chatbot_provider: str = "auto"  # "openai", "gemini", or "auto"
    
    # Logging Settings
    log_level: str = "INFO"
    log_format: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # File Paths
    remedies_file: str = "disease_remedies.json"
    models_dir: str = "models"
    logs_dir: str = "logs"
    
    @field_validator('port')
    @classmethod
    def validate_port(cls, v):
        if not 1024 <= v <= 65535:
            raise ValueError('Port must be between 1024 and 65535')
        return v
    
    @field_validator('max_file_size')
    @classmethod
    def validate_file_size(cls, v):
        if v <= 0 or v > 50 * 1024 * 1024:  # Max 50MB
            raise ValueError('File size must be between 1 byte and 50MB')
        return v
    
    @field_validator('cache_ttl')
    @classmethod
    def validate_cache_ttl(cls, v):
        if v < 60:  # Minimum 1 minute
            raise ValueError('Cache TTL must be at least 60 seconds')
        return v
    
    @field_validator('model_path')
    @classmethod
    def validate_model_path(cls, v):
        if not Path(v).exists():
            logger.warning(f"Model file not found: {v}")
        return v
    
    @field_validator('log_level')
    @classmethod
    def validate_log_level(cls, v):
        valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
        if v.upper() not in valid_levels:
            raise ValueError(f'Log level must be one of: {valid_levels}')
        return v.upper()
    
    def setup_logging(self):
        """Configure logging based on settings"""
        logging.basicConfig(
            level=getattr(logging, self.log_level),
            format=self.log_format
        )
        
        # Create logs directory if it doesn't exist
        Path(self.logs_dir).mkdir(exist_ok=True)
        
        # Add file handler
        file_handler = logging.FileHandler(
            Path(self.logs_dir) / "prakruti_backend.log"
        )
        file_handler.setFormatter(logging.Formatter(self.log_format))
        logging.getLogger().addHandler(file_handler)
    
    def get_model_info(self) -> dict:
        """Get model configuration info"""
        return {
            "model_path": self.model_path,
            "models_directory": self.models_dir,
            "warm_up_enabled": self.model_warm_up,
            "model_exists": Path(self.model_path).exists()
        }
    
    def get_performance_config(self) -> dict:
        """Get performance-related configuration"""
        return {
            "max_concurrent_requests": self.max_concurrent_requests,
            "thread_pool_workers": self.thread_pool_workers,
            "cache_ttl": self.cache_ttl,
            "cache_size": self.cache_size,
            "max_file_size": self.max_file_size
        }
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        # Environment variable prefix
        env_prefix = "PRAKRUTI_"

# Create global settings instance
settings = Settings()

# Setup logging
settings.setup_logging()

# Comprehensive Indian Crop Disease Classes (100+ diseases)
DISEASE_CLASSES = [
    # General Health
    "Healthy",
    
    # Rice Diseases (15 classes)
    "Rice_Blast",
    "Rice_Brown_Spot", 
    "Rice_Bacterial_Blight",
    "Rice_Hispa",
    "Rice_Tungro",
    "Rice_Leaf_Scald",
    "Rice_Narrow_Brown_Spot",
    "Rice_Sheath_Blight",
    "Rice_False_Smut",
    "Rice_Bakanae_Disease",
    "Rice_Stem_Rot",
    "Rice_White_Backed_Planthopper",
    "Rice_Brown_Planthopper",
    "Rice_Green_Leafhopper",
    "Rice_Yellow_Stem_Borer",
    
    # Wheat Diseases (12 classes)
    "Wheat_Rust_Yellow",
    "Wheat_Rust_Brown",
    "Wheat_Rust_Black",
    "Wheat_Septoria",
    "Wheat_Tan_Spot",
    "Wheat_Powdery_Mildew",
    "Wheat_Loose_Smut",
    "Wheat_Karnal_Bunt",
    "Wheat_Flag_Smut",
    "Wheat_Foot_Rot",
    "Wheat_Take_All",
    "Wheat_Ergot",
    
    # Maize/Corn Diseases (10 classes)
    "Maize_Common_Rust",
    "Maize_Northern_Leaf_Blight",
    "Maize_Gray_Leaf_Spot",
    "Maize_Southern_Rust",
    "Maize_Ear_Rot",
    "Maize_Stalk_Rot",
    "Maize_Smut",
    "Maize_Downy_Mildew",
    "Maize_Borer",
    "Maize_Fall_Armyworm",
    
    # Cotton Diseases (8 classes)
    "Cotton_Bacterial_Blight",
    "Cotton_Fusarium_Wilt",
    "Cotton_Verticillium_Wilt",
    "Cotton_Target_Spot",
    "Cotton_Alternaria_Leaf_Spot",
    "Cotton_Bollworm",
    "Cotton_Pink_Bollworm",
    "Cotton_Whitefly",
    
    # Sugarcane Diseases (6 classes)
    "Sugarcane_Red_Rot",
    "Sugarcane_Smut",
    "Sugarcane_Rust",
    "Sugarcane_Ring_Spot",
    "Sugarcane_Mosaic",
    "Sugarcane_Borer",
    
    # Potato Diseases (8 classes)
    "Potato_Late_Blight",
    "Potato_Early_Blight",
    "Potato_Common_Scab",
    "Potato_Black_Scurf",
    "Potato_Wart_Disease",
    "Potato_Virus_Y",
    "Potato_Virus_X",
    "Potato_Tuber_Moth",
    
    # Tomato Diseases (12 classes)
    "Tomato_Late_Blight",
    "Tomato_Early_Blight",
    "Tomato_Leaf_Mold",
    "Tomato_Septoria_Leaf_Spot",
    "Tomato_Bacterial_Spot",
    "Tomato_Target_Spot",
    "Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato_Mosaic_Virus",
    "Tomato_Fusarium_Wilt",
    "Tomato_Verticillium_Wilt",
    "Tomato_Blossom_End_Rot",
    "Tomato_Fruit_Fly",
    
    # Chili/Pepper Diseases (6 classes)
    "Chili_Leaf_Curl",
    "Chili_Anthracnose",
    "Chili_Bacterial_Spot",
    "Chili_Powdery_Mildew",
    "Chili_Thrips",
    "Chili_Virus_Disease",
    
    # Onion Diseases (4 classes)
    "Onion_Purple_Blotch",
    "Onion_Stemphylium_Blight",
    "Onion_Downy_Mildew",
    "Onion_Thrips",
    
    # Pulse/Oilseed Diseases (8 classes)
    "Groundnut_Tikka",
    "Groundnut_Rust",
    "Groundnut_Late_Leaf_Spot",
    "Mustard_White_Rust",
    "Mustard_Alternaria_Blight",
    "Soybean_Rust",
    "Soybean_Bacterial_Blight",
    "Chickpea_Wilt",
    
    # Fruit Diseases (15 classes)
    "Banana_Panama_Wilt",
    "Banana_Black_Sigatoka",
    "Mango_Anthracnose",
    "Mango_Powdery_Mildew",
    "Citrus_Canker",
    "Citrus_Greening",
    "Apple_Scab",
    "Apple_Fire_Blight",
    "Grape_Downy_Mildew",
    "Grape_Powdery_Mildew",
    "Papaya_Ring_Spot",
    "Papaya_Mosaic",
    "Guava_Wilt",
    "Pomegranate_Bacterial_Blight",
    "Strawberry_Leaf_Spot",
    
    # Plantation Crop Diseases (6 classes)
    "Coconut_Bud_Rot",
    "Coconut_Leaf_Rot",
    "Coffee_Berry_Disease",
    "Coffee_Leaf_Rust",
    "Tea_Blister_Blight",
    "Tea_Red_Rust",
    
    # Spice Crop Diseases (10 classes)
    "Cardamom_Rhizome_Rot",
    "Cardamom_Leaf_Spot",
    "Black_Pepper_Quick_Wilt",
    "Black_Pepper_Anthracnose",
    "Turmeric_Rhizome_Rot",
    "Turmeric_Leaf_Spot",
    "Ginger_Soft_Rot",
    "Ginger_Bacterial_Wilt",
    "Cashew_Anthracnose",
    "Areca_Nut_Fruit_Rot",
    
    # Vegetable Diseases (8 classes)
    "Brinjal_Shoot_Borer",
    "Brinjal_Bacterial_Wilt",
    "Cabbage_Black_Rot",
    "Cabbage_Club_Root",
    "Cauliflower_Black_Rot",
    "Okra_Yellow_Mosaic",
    "Cucumber_Downy_Mildew",
    "Bitter_Gourd_Mosaic",
    
    # Flower Diseases (4 classes)
    "Rose_Black_Spot",
    "Rose_Powdery_Mildew",
    "Jasmine_Leaf_Spot",
    "Marigold_Leaf_Blight",
    
    # General Disease Types (5 classes)
    "Fungal_Disease",
    "Bacterial_Disease",
    "Viral_Disease",
    "Nematode_Disease",
    "Insect_Damage",
    
    # === MISSING CRITICAL INDIAN CROPS (Adding ~62 diseases for complete coverage) ===
    
    # Cereals & Millets (12 diseases)
    "Jowar_Grain_Mold",
    "Jowar_Charcoal_Rot",
    "Jowar_Downy_Mildew",
    "Bajra_Downy_Mildew",
    "Bajra_Blast",
    "Bajra_Ergot",
    "Ragi_Blast",
    "Ragi_Brown_Spot",
    "Ragi_Blight",
    "Barley_Stripe_Disease",
    "Barley_Loose_Smut",
    "Barley_Net_Blotch",
    
    # Cash Crops (8 diseases)
    "Jute_Stem_Rot",
    "Jute_Black_Band",
    "Sesame_Phyllody",
    "Sesame_Bacterial_Blight",
    "Sunflower_Rust",
    "Sunflower_Necrosis_Virus",
    "Safflower_Rust",
    "Safflower_Wilt",
    
    # Pulses (10 diseases)
    "Arhar_Wilt",
    "Arhar_Sterility_Mosaic",
    "Moong_Yellow_Mosaic",
    "Moong_Bacterial_Leaf_Spot",
    "Urad_Yellow_Mosaic",
    "Urad_Leaf_Crinkle_Virus",
    "Masoor_Rust",
    "Masoor_Blight",
    "Rajma_Anthracnose",
    "Rajma_Angular_Leaf_Spot",
    
    # Spices & Condiments (14 diseases)
    "Coriander_Stem_Gall",
    "Coriander_Wilt",
    "Cumin_Blight",
    "Cumin_Wilt",
    "Fenugreek_Root_Rot",
    "Fenugreek_Downy_Mildew",
    "Fennel_Blight",
    "Fennel_Rust",
    "Ajwain_Blight",
    "Ajwain_Powdery_Mildew",
    "Cloves_Sudden_Wilt",
    "Cloves_Leaf_Spot",
    "Nutmeg_Fruit_Rot",
    "Nutmeg_Thread_Blight",
    
    # Vegetables (18 diseases)
    "Brinjal_Shoot_Borer",
    "Brinjal_Bacterial_Wilt",
    "Brinjal_Little_Leaf",
    "Okra_Yellow_Mosaic",
    "Okra_Enation_Leaf_Curl",
    "Okra_Powdery_Mildew",
    "Cabbage_Black_Rot",
    "Cabbage_Club_Root",
    "Cabbage_Diamondback_Moth",
    "Cauliflower_Black_Rot",
    "Cauliflower_Curd_Rot",
    "Cauliflower_Clubroot",
    "Carrot_Cavity_Spot",
    "Carrot_Leaf_Blight",
    "Radish_White_Rust",
    "Spinach_Downy_Mildew",
    "Bottle_Gourd_Mosaic",
    "Ridge_Gourd_Mosaic",
    "Bitter_Gourd_Mosaic",
    "Pumpkin_Downy_Mildew",
    "Cucumber_Downy_Mildew",
    "Watermelon_Fusarium_Wilt",
    "Muskmelon_Powdery_Mildew",
    
    # More Fruits (10 diseases)
    "Papaya_Ring_Spot_Enhanced",
    "Papaya_Mosaic_Enhanced",
    "Papaya_Leaf_Curl",
    "Guava_Wilt_Enhanced",
    "Guava_Canker",
    "Pomegranate_Bacterial_Blight_Enhanced",
    "Pomegranate_Fruit_Spot",
    "Jackfruit_Soft_Rot",
    "Litchi_Downy_Blight",
    "Litchi_Fruit_Borer",
    
    # Additional Plantation & Cash Crops (8 diseases)
    "Cashew_Anthracnose_Enhanced",
    "Cashew_Dieback",
    "Areca_Nut_Fruit_Rot_Enhanced",
    "Areca_Nut_Bud_Rot",
    "Rubber_South_American_Leaf_Blight",
    "Rubber_Pink_Disease",
    "Oil_Palm_Blast_Disease",
    "Oil_Palm_Crown_Disease"
]

# Disease categories for better organization (200+ diseases organized)
DISEASE_CATEGORIES = {
    "Cereals": [
        # Rice (15 diseases)
        "Rice_Blast", "Rice_Brown_Spot", "Rice_Bacterial_Blight", "Rice_Hispa",
        "Rice_Tungro", "Rice_Leaf_Scald", "Rice_Narrow_Brown_Spot", "Rice_Sheath_Blight",
        "Rice_False_Smut", "Rice_Bakanae_Disease", "Rice_Stem_Rot", 
        "Rice_White_Backed_Planthopper", "Rice_Brown_Planthopper", "Rice_Green_Leafhopper", "Rice_Yellow_Stem_Borer",
        
        # Wheat (12 diseases)
        "Wheat_Rust_Yellow", "Wheat_Rust_Brown", "Wheat_Rust_Black", "Wheat_Septoria",
        "Wheat_Tan_Spot", "Wheat_Powdery_Mildew", "Wheat_Loose_Smut", "Wheat_Karnal_Bunt",
        "Wheat_Flag_Smut", "Wheat_Foot_Rot", "Wheat_Take_All", "Wheat_Ergot",
        
        # Maize (10 diseases)
        "Maize_Common_Rust", "Maize_Northern_Leaf_Blight", "Maize_Gray_Leaf_Spot",
        "Maize_Southern_Rust", "Maize_Ear_Rot", "Maize_Stalk_Rot", "Maize_Smut",
        "Maize_Downy_Mildew", "Maize_Borer", "Maize_Fall_Armyworm",
        
        # Millets (12 diseases) - NEW INDIAN CROPS
        "Jowar_Grain_Mold", "Jowar_Charcoal_Rot", "Jowar_Downy_Mildew",
        "Bajra_Downy_Mildew", "Bajra_Blast", "Bajra_Ergot",
        "Ragi_Blast", "Ragi_Brown_Spot", "Ragi_Blight",
        "Barley_Stripe_Disease", "Barley_Loose_Smut", "Barley_Net_Blotch"
    ],
    
    "Cash_Crops": [
        # Cotton (8 diseases)
        "Cotton_Bacterial_Blight", "Cotton_Fusarium_Wilt", "Cotton_Verticillium_Wilt",
        "Cotton_Target_Spot", "Cotton_Alternaria_Leaf_Spot", "Cotton_Bollworm", 
        "Cotton_Pink_Bollworm", "Cotton_Whitefly",
        
        # Sugarcane (6 diseases)
        "Sugarcane_Red_Rot", "Sugarcane_Smut", "Sugarcane_Rust", "Sugarcane_Ring_Spot",
        "Sugarcane_Mosaic", "Sugarcane_Borer",
        
        # New Cash Crops (8 diseases) - EXPANDED INDIAN COVERAGE
        "Jute_Stem_Rot", "Jute_Black_Band", "Sesame_Phyllody", "Sesame_Bacterial_Blight",
        "Sunflower_Rust", "Sunflower_Necrosis_Virus", "Safflower_Rust", "Safflower_Wilt"
    ],
    
    "Pulses_Oilseeds": [
        # Existing pulses
        "Groundnut_Tikka", "Groundnut_Rust", "Groundnut_Late_Leaf_Spot",
        "Mustard_White_Rust", "Mustard_Alternaria_Blight", "Soybean_Rust", 
        "Soybean_Bacterial_Blight", "Chickpea_Wilt",
        
        # New Major Indian Pulses (10 diseases) - CRITICAL EXPANSION
        "Arhar_Wilt", "Arhar_Sterility_Mosaic", "Moong_Yellow_Mosaic", "Moong_Bacterial_Leaf_Spot",
        "Urad_Yellow_Mosaic", "Urad_Leaf_Crinkle_Virus", "Masoor_Rust", "Masoor_Blight",
        "Rajma_Anthracnose", "Rajma_Angular_Leaf_Spot"
    ],
    
    "Vegetables": [
        # Solanaceous crops
        "Potato_Late_Blight", "Potato_Early_Blight", "Potato_Common_Scab", "Potato_Black_Scurf",
        "Potato_Wart_Disease", "Potato_Virus_Y", "Potato_Virus_X", "Potato_Tuber_Moth",
        
        "Tomato_Late_Blight", "Tomato_Early_Blight", "Tomato_Leaf_Mold", "Tomato_Septoria_Leaf_Spot",
        "Tomato_Bacterial_Spot", "Tomato_Target_Spot", "Tomato_Yellow_Leaf_Curl_Virus",
        "Tomato_Mosaic_Virus", "Tomato_Fusarium_Wilt", "Tomato_Verticillium_Wilt",
        "Tomato_Blossom_End_Rot", "Tomato_Fruit_Fly",
        
        "Chili_Leaf_Curl", "Chili_Anthracnose", "Chili_Bacterial_Spot", "Chili_Powdery_Mildew",
        "Chili_Thrips", "Chili_Virus_Disease",
        
        # Brinjal (Expanded)
        "Brinjal_Shoot_Borer", "Brinjal_Bacterial_Wilt", "Brinjal_Little_Leaf",
        
        # Other vegetables (Expanded Indian Coverage)
        "Onion_Purple_Blotch", "Onion_Stemphylium_Blight", "Onion_Downy_Mildew", "Onion_Thrips",
        "Cabbage_Black_Rot", "Cabbage_Club_Root", "Cabbage_Diamondback_Moth",
        "Cauliflower_Black_Rot", "Cauliflower_Curd_Rot", "Cauliflower_Clubroot",
        "Okra_Yellow_Mosaic", "Okra_Enation_Leaf_Curl", "Okra_Powdery_Mildew",
        "Carrot_Cavity_Spot", "Carrot_Leaf_Blight", "Radish_White_Rust", "Spinach_Downy_Mildew",
        
        # Gourds & Cucurbits
        "Bottle_Gourd_Mosaic", "Ridge_Gourd_Mosaic", "Bitter_Gourd_Mosaic", "Pumpkin_Downy_Mildew",
        "Cucumber_Downy_Mildew", "Watermelon_Fusarium_Wilt", "Muskmelon_Powdery_Mildew"
    ],
    
    "Fruits": [
        # Tropical fruits (Expanded)
        "Banana_Panama_Wilt", "Banana_Black_Sigatoka", "Mango_Anthracnose", "Mango_Powdery_Mildew",
        "Papaya_Ring_Spot", "Papaya_Mosaic", "Papaya_Ring_Spot_Enhanced", "Papaya_Mosaic_Enhanced", "Papaya_Leaf_Curl",
        "Guava_Wilt", "Guava_Wilt_Enhanced", "Guava_Canker",
        
        # Citrus
        "Citrus_Canker", "Citrus_Greening",
        
        # Temperate fruits
        "Apple_Scab", "Apple_Fire_Blight", "Grape_Downy_Mildew", "Grape_Powdery_Mildew",
        "Strawberry_Leaf_Spot", 
        
        # Expanded Indian Fruits
        "Pomegranate_Bacterial_Blight", "Pomegranate_Bacterial_Blight_Enhanced", "Pomegranate_Fruit_Spot",
        "Jackfruit_Soft_Rot", "Litchi_Downy_Blight", "Litchi_Fruit_Borer"
    ],
    
    "Plantation_Crops": [
        # Coconut
        "Coconut_Bud_Rot", "Coconut_Leaf_Rot",
        
        # Coffee & Tea
        "Coffee_Berry_Disease", "Coffee_Leaf_Rust", "Tea_Blister_Blight", "Tea_Red_Rust",
        
        # Expanded Plantation Crops
        "Cashew_Anthracnose", "Cashew_Anthracnose_Enhanced", "Cashew_Dieback",
        "Areca_Nut_Fruit_Rot", "Areca_Nut_Fruit_Rot_Enhanced", "Areca_Nut_Bud_Rot",
        "Rubber_South_American_Leaf_Blight", "Rubber_Pink_Disease",
        "Oil_Palm_Blast_Disease", "Oil_Palm_Crown_Disease"
    ],
    
    "Spices_Condiments": [
        # Major spices (Original)
        "Cardamom_Rhizome_Rot", "Cardamom_Leaf_Spot", "Black_Pepper_Quick_Wilt", 
        "Black_Pepper_Anthracnose", "Turmeric_Rhizome_Rot", "Turmeric_Leaf_Spot",
        "Ginger_Soft_Rot", "Ginger_Bacterial_Wilt",
        
        # Expanded Indian Spices (14 new diseases)
        "Coriander_Stem_Gall", "Coriander_Wilt", "Cumin_Blight", "Cumin_Wilt",
        "Fenugreek_Root_Rot", "Fenugreek_Downy_Mildew", "Fennel_Blight", "Fennel_Rust",
        "Ajwain_Blight", "Ajwain_Powdery_Mildew", "Cloves_Sudden_Wilt", "Cloves_Leaf_Spot",
        "Nutmeg_Fruit_Rot", "Nutmeg_Thread_Blight"
    ],

    
    "Ornamental": [
        "Rose_Black_Spot", "Rose_Powdery_Mildew", "Jasmine_Leaf_Spot", "Marigold_Leaf_Blight"
    ],
    
    "General_Health": [
        "Healthy"
    ],
    
    "Disease_Types": [
        "Fungal_Disease", "Bacterial_Disease", "Viral_Disease", "Nematode_Disease", "Insect_Damage"
    ]
}

# Regional disease prevalence (Indian states/regions) - Expanded
REGIONAL_DISEASES = {
    "North_India": [
        # Punjab, Haryana, UP, Uttarakhand, Himachal, J&K
        "Wheat_Rust_Yellow", "Wheat_Rust_Brown", "Wheat_Rust_Black", "Wheat_Karnal_Bunt",
        "Rice_Blast", "Rice_Brown_Spot", "Mustard_White_Rust", "Mustard_Alternaria_Blight",
        "Potato_Late_Blight", "Potato_Early_Blight", "Potato_Common_Scab",
        "Apple_Scab", "Apple_Fire_Blight", "Maize_Common_Rust"
    ],
    
    "South_India": [
        # Tamil Nadu, Karnataka, Kerala, Andhra Pradesh, Telangana
        "Rice_Blast", "Rice_Bacterial_Blight", "Rice_Tungro", "Rice_Sheath_Blight",
        "Coconut_Bud_Rot", "Coconut_Leaf_Rot", "Coffee_Berry_Disease", "Coffee_Leaf_Rust",
        "Cardamom_Rhizome_Rot", "Cardamom_Leaf_Spot", "Black_Pepper_Quick_Wilt",
        "Banana_Panama_Wilt", "Banana_Black_Sigatoka", "Mango_Anthracnose",
        "Turmeric_Rhizome_Rot", "Ginger_Soft_Rot", "Cashew_Anthracnose"
    ],
    
    "West_India": [
        # Maharashtra, Gujarat, Rajasthan, Goa
        "Cotton_Bacterial_Blight", "Cotton_Fusarium_Wilt", "Cotton_Bollworm",
        "Sugarcane_Red_Rot", "Sugarcane_Smut", "Sugarcane_Rust",
        "Grape_Downy_Mildew", "Grape_Powdery_Mildew", "Pomegranate_Bacterial_Blight",
        "Onion_Purple_Blotch", "Chili_Leaf_Curl", "Tomato_Leaf_Curl_Virus"
    ],
    
    "East_India": [
        # West Bengal, Odisha, Bihar, Jharkhand
        "Rice_Brown_Spot", "Rice_Bacterial_Blight", "Rice_Hispa", "Rice_Stem_Rot",
        "Tea_Blister_Blight", "Tea_Red_Rust", "Potato_Late_Blight",
        "Brinjal_Shoot_Borer", "Okra_Yellow_Mosaic", "Maize_Borer"
    ],
    
    "Central_India": [
        # Madhya Pradesh, Chhattisgarh
        "Soybean_Rust", "Soybean_Bacterial_Blight", "Chickpea_Wilt",
        "Maize_Common_Rust", "Maize_Fall_Armyworm", "Cotton_Fusarium_Wilt",
        "Wheat_Rust_Brown", "Rice_Blast", "Groundnut_Tikka"
    ],
    
    "Northeast_India": [
        # Assam, Manipur, Meghalaya, Tripura, Arunachal, Mizoram, Nagaland, Sikkim  
        "Ginger_Soft_Rot", "Ginger_Bacterial_Wilt", "Black_Pepper_Quick_Wilt",
        "Tea_Blister_Blight", "Rice_Tungro", "Turmeric_Rhizome_Rot",
        "Banana_Panama_Wilt", "Citrus_Canker", "Areca_Nut_Fruit_Rot"
    ],
    
    "Coastal_Regions": [
        # Coastal areas of all states
        "Coconut_Bud_Rot", "Cashew_Anthracnose", "Mango_Anthracnose",
        "Banana_Black_Sigatoka", "Papaya_Ring_Spot", "Citrus_Canker"
    ],
    
    "Hill_Stations": [
        # Mountainous regions
        "Apple_Scab", "Strawberry_Leaf_Spot", "Potato_Late_Blight",
        "Tea_Blister_Blight", "Cardamom_Rhizome_Rot", "Ginger_Soft_Rot"
    ]
}

# Model input configuration
MODEL_CONFIG = {
    "input_shape": (224, 224, 3),
    "input_dtype": "float32",
    "normalization_range": (0, 1),
    "batch_size": 1
}

# API Response configuration
API_RESPONSES = {
    "success": {"status": "success"},
    "error": {"status": "error"},
    "invalid_file": {"error": "Invalid file format or corrupted image"},
    "file_too_large": {"error": f"File size exceeds {settings.max_file_size} bytes"},
    "model_error": {"error": "Model prediction failed"},
    "rate_limit": {"error": "Too many requests, please try again later"}
}

def get_settings() -> Settings:
    """Get application settings"""
    return settings

def validate_config() -> bool:
    """Validate all configuration settings"""
    try:
        # Check if model file exists
        if not Path(settings.model_path).exists():
            logger.error(f"Model file not found: {settings.model_path}")
            return False
        
        # Check if remedies file exists
        if not Path(settings.remedies_file).exists():
            logger.error(f"Remedies file not found: {settings.remedies_file}")
            return False
        
        # Create required directories
        Path(settings.models_dir).mkdir(exist_ok=True)
        Path(settings.logs_dir).mkdir(exist_ok=True)
        
        logger.info("Configuration validation successful")
        return True
        
    except Exception as e:
        logger.error(f"Configuration validation failed: {e}")
        return False

def print_config_summary():
    """Print configuration summary for debugging"""
    logger.info("=== PRAKRUTI Backend Configuration ===")
    logger.info(f"App Name: {settings.app_name}")
    logger.info(f"Version: {settings.app_version}")
    logger.info(f"Debug Mode: {settings.debug}")
    logger.info(f"Host: {settings.host}:{settings.port}")
    logger.info(f"Model Path: {settings.model_path}")
    logger.info(f"Max File Size: {settings.max_file_size / (1024*1024):.1f}MB")
    logger.info(f"Cache TTL: {settings.cache_ttl}s")
    logger.info(f"Log Level: {settings.log_level}")
    logger.info("=====================================")

# Validate configuration on import
if not validate_config():
    logger.warning("Some configuration validations failed - check logs")

# Print config summary if debug mode
if settings.debug:
    print_config_summary()
