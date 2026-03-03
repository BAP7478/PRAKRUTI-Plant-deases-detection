# PRAKRUTI Backend API Documentation

## Overview
PRAKRUTI Enhanced Backend API provides comprehensive Indian crop disease detection, remedies, and agricultural information services. This API supports 45+ diseases across major Indian crops with million-scale dataset capabilities.

## Authentication
All protected endpoints require an API key in the request headers:
```
X-API-Key: your_api_key_here
```

## Endpoints

### Health Check
```
GET /health
```
Returns system health status and basic information.

### Disease Detection
```
POST /predict
Content-Type: multipart/form-data
```
**Parameters:**
- `file`: Image file (JPG, PNG, JPEG)

**Response:**
```json
{
  "predicted_class": "Rice_Blast",
  "confidence": 0.95,
  "remedies": [...],
  "additional_info": {...},
  "timestamp": 1234567890
}
```

### Disease Management

#### List All Diseases
```
GET /diseases
```
Returns comprehensive list of all supported diseases with categories and regional information.

#### Get Diseases by Category
```
GET /diseases/category/{category}
```
**Categories:**
- `Field_Crops` - Rice, Wheat, Cotton, Sugarcane, etc.
- `Vegetables` - Tomato, Potato, Chili, Okra, etc.
- `Fruits` - Mango, Banana, Apple, Grapes, etc.
- `Plantation_Crops` - Tea, Coffee, Coconut, etc.
- `Spices` - Turmeric, Cardamom, Black Pepper, etc.

#### Get Diseases by Region
```
GET /diseases/region/{region}
```
**Regions:**
- `North_India` - Punjab, Haryana, UP diseases
- `South_India` - Tamil Nadu, Karnataka, AP diseases  
- `West_India` - Maharashtra, Gujarat diseases
- `East_India` - West Bengal, Odisha diseases
- `Central_India` - MP, Chhattisgarh diseases

### Crop Information
```
GET /crop-info/{crop_name}
```
Get comprehensive information about specific crops including:
- Scientific name and family
- Major growing states
- Optimal growing conditions
- Common varieties
- Disease susceptibility
- Fertilizer schedules

### Dataset Management (Protected)
```
GET /dataset/stats
```
Returns comprehensive dataset statistics and expansion strategies.

### Model Performance (Protected)
```
GET /model/performance
```
Returns detailed model performance metrics and optimization reports.

## Supported Diseases (45+)

### Field Crops (12)
- Rice_Blast, Rice_Brown_Spot, Rice_Bacterial_Blight
- Wheat_Rust, Wheat_Powdery_Mildew, Wheat_Smut
- Cotton_Bollworm, Cotton_Leaf_Curl, Cotton_Bacterial_Blight
- Sugarcane_Red_Rot, Sugarcane_Smut, Sugarcane_Rust

### Vegetables (15)
- Tomato_Early_Blight, Tomato_Late_Blight, Tomato_Leaf_Mold
- Potato_Late_Blight, Potato_Early_Blight, Potato_Black_Scurf
- Chili_Anthracnose, Chili_Bacterial_Spot, Chili_Powdery_Mildew
- Okra_Yellow_Vein_Mosaic, Brinjal_Shoot_Borer, Onion_Purple_Blotch
- Cabbage_Black_Rot, Cauliflower_Black_Rot, Carrot_Leaf_Blight

### Fruits (8)
- Mango_Anthracnose, Mango_Powdery_Mildew
- Banana_Panama_Disease, Banana_Black_Sigatoka
- Apple_Scab, Apple_Fire_Blight
- Grapes_Downy_Mildew, Grapes_Powdery_Mildew

### Plantation Crops (6)
- Tea_Blister_Blight, Tea_Red_Rust
- Coffee_Leaf_Rust, Coffee_Berry_Disease
- Coconut_Lethal_Yellowing, Areca_Nut_Fruit_Rot

### Spices (4)
- Turmeric_Leaf_Spot, Cardamom_Azhukal_Disease
- Black_Pepper_Slow_Decline, Coriander_Wilt

## Regional Disease Mapping

### North India Focus
- Wheat diseases (Rust, Powdery Mildew)
- Rice diseases (Blast, Bacterial Blight)
- Cotton diseases (Bollworm, Leaf Curl)

### South India Focus
- Tea and Coffee plantation diseases
- Coconut and Areca Nut diseases
- Rice diseases (Brown Spot, Blast)

### West India Focus
- Cotton diseases (major growing region)
- Sugarcane diseases
- Mango and Grapes diseases

### East India Focus
- Rice diseases (major rice growing region)
- Tea plantation diseases
- Vegetable crop diseases

## Sample Requests

### Disease Prediction
```bash
curl -X POST "http://localhost:8002/predict" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@diseased_leaf.jpg"
```

### Get Rice Diseases
```bash
curl "http://localhost:8002/diseases/category/Field_Crops" | jq '.diseases[] | select(.name | contains("Rice"))'
```

### Get North India Diseases
```bash
curl "http://localhost:8002/diseases/region/North_India"
```

### Get Crop Information
```bash
curl "http://localhost:8002/crop-info/rice"
```

## Error Handling

The API returns structured error responses:
```json
{
  "detail": "Error description",
  "status_code": 400,
  "timestamp": 1234567890
}
```

**Common Status Codes:**
- `200` - Success
- `400` - Bad Request (invalid input)
- `401` - Unauthorized (invalid API key)
- `404` - Not Found (disease/crop not found)
- `422` - Validation Error
- `500` - Internal Server Error

## Dataset Capabilities

### Current Scale
- **Disease Classes**: 45+ Indian crop diseases
- **Crop Coverage**: 25+ major Indian crops
- **Regional Coverage**: 5 major Indian regions
- **Image Categories**: Field photos, lab samples, microscopic images

### Million-Scale Strategy
- **Synthetic Data Generation**: AI-powered image augmentation
- **Crowd-Sourcing**: Farmer community contributions
- **Research Partnerships**: Agricultural universities collaboration
- **Government Data**: Integration with agricultural surveys

### Data Quality
- **Expert Validation**: Agricultural pathologist verification
- **Regional Verification**: Location-specific disease validation
- **Seasonal Tracking**: Time-series disease progression
- **Multi-variety Coverage**: Different crop varieties inclusion

## Model Optimization Features

### Performance Metrics
- **Accuracy**: >95% on Indian crop diseases
- **Inference Speed**: <100ms on mobile devices
- **Model Size**: Optimized for edge deployment
- **Memory Usage**: <50MB RAM requirement

### Optimization Techniques
- **Quantization**: INT8 quantization for speed
- **Pruning**: Network pruning for size reduction
- **Knowledge Distillation**: Teacher-student training
- **Multi-threading**: Parallel inference capability

## Integration Examples

### Flutter Integration
```dart
Future<Map<String, dynamic>> predictDisease(File imageFile) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/predict'),
  );
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  
  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  return json.decode(responseData);
}
```

### Python Integration
```python
import requests

def predict_disease(image_path):
    with open(image_path, 'rb') as f:
        files = {'file': f}
        response = requests.post('http://localhost:8002/predict', files=files)
    return response.json()
```

## Deployment Configuration

### Environment Variables
```bash
PRAKRUTI_DEBUG=false
PRAKRUTI_API_KEY=your_secure_api_key
PRAKRUTI_MODEL_PATH=./models/prakruti_indian_crops_v2.tflite
PRAKRUTI_LOG_LEVEL=INFO
PRAKRUTI_MAX_IMAGE_SIZE=10485760
PRAKRUTI_ALLOWED_EXTENSIONS=jpg,jpeg,png
```

### Production Setup
```bash
# Install dependencies
pip install -r requirements.txt

# Start server
uvicorn app_enhanced:app --host 0.0.0.0 --port 8002 --workers 4
```

## Future Enhancements

### Planned Features
- **Real-time Disease Monitoring**: IoT sensor integration
- **Weather-based Predictions**: Weather-disease correlation
- **Treatment Tracking**: Post-treatment monitoring
- **Yield Impact Analysis**: Disease-yield relationship

### Scaling Improvements
- **Multi-model Ensemble**: Combining multiple AI models
- **Edge Computing**: On-device inference capability
- **Blockchain Integration**: Secure farmer data management
- **AR/VR Support**: Augmented reality disease diagnosis

## Support and Contact

For technical support or feature requests:
- **Repository**: [GitHub Repository URL]
- **Documentation**: This file and inline API docs
- **Issues**: Report bugs via GitHub issues
- **Email**: technical.support@prakruti.com

---

**Version**: 2.0.0  
**Last Updated**: December 2024  
**API Stability**: Production Ready
