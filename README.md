<p align="center">
  <img src="assets/icons/app_icon.png" alt="PRAKRUTI Logo" width="150" height="150">
</p>

<h1 align="center">🌿 PRAKRUTI</h1>
<h3 align="center">AI-Powered Plant Disease Detection System</h3>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.35-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/TensorFlow-2.x-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" alt="TensorFlow">
  <img src="https://img.shields.io/badge/FastAPI-0.100+-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status">
</p>

---

## 🎯 Overview

**PRAKRUTI** is an intelligent mobile application that leverages **Deep Learning** and **Computer Vision** to detect plant diseases from leaf images. The app empowers farmers and agricultural enthusiasts to identify crop diseases early, enabling timely intervention and reducing crop losses.

<p align="center">
  <img src="https://img.shields.io/badge/Accuracy-88%25--94%25-brightgreen?style=flat-square&logo=chart.js" alt="Accuracy">
  <img src="https://img.shields.io/badge/Diseases%20Detected-38+-blue?style=flat-square" alt="Diseases">
  <img src="https://img.shields.io/badge/Crops%20Supported-14+-orange?style=flat-square" alt="Crops">
</p>

---

## ✨ Key Features

### 🔬 AI-Powered Disease Detection
- **Deep Learning Models**: Utilizes CNN architectures (MobileNet, ResNet50, EfficientNet)
- **Real-time Analysis**: Instant disease prediction from camera or gallery images
- **High Accuracy**: 88-94% confidence in disease identification
- **Multi-crop Support**: Detects diseases across 14+ crop varieties

### 🤖 Intelligent AI Chatbot
- **Agricultural Expert**: Get instant answers to farming queries
- **Disease Guidance**: Detailed treatment recommendations
- **Multilingual Support**: Available in English and Gujarati (ગુજરાતી)
- **Context-Aware**: Remembers conversation history for better assistance

### 🌤️ Weather Integration
- **Real-time Weather**: Current conditions for your location
- **Forecast Data**: 7-day weather predictions
- **Agricultural Insights**: Weather-based farming recommendations
- **Location-based**: Automatic location detection

### 🌐 Multilingual Interface
- **English**: Full application support
- **Gujarati (ગુજરાતી)**: Complete localization for regional users
- **Easy Switching**: Toggle languages with one tap

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRAKRUTI APP                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │   Camera    │    │   Gallery   │    │   Weather   │        │
│   │   Input     │    │   Upload    │    │   Service   │        │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘        │
│          │                  │                  │                │
│          └─────────────┬────┴──────────────────┘                │
│                        │                                        │
│                        ▼                                        │
│          ┌─────────────────────────────┐                        │
│          │      Flutter Frontend       │                        │
│          │   (Cross-platform UI/UX)    │                        │
│          └─────────────┬───────────────┘                        │
│                        │                                        │
│                        │ REST API                               │
│                        ▼                                        │
│          ┌─────────────────────────────┐                        │
│          │     FastAPI Backend         │                        │
│          │   (Python ML Server)        │                        │
│          └─────────────┬───────────────┘                        │
│                        │                                        │
│          ┌─────────────┴───────────────┐                        │
│          ▼                             ▼                        │
│   ┌─────────────┐            ┌─────────────────┐               │
│   │  TensorFlow │            │   AI Chatbot    │               │
│   │  CNN Models │            │   (NLP Engine)  │               │
│   └─────────────┘            └─────────────────┘               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧠 AI/ML Components

### Deep Learning Models

| Model | Architecture | Purpose | Accuracy |
|-------|-------------|---------|----------|
| **MobileNetV2** | Lightweight CNN | Mobile deployment | 89% |
| **ResNet50** | Deep Residual Network | High accuracy | 92% |
| **EfficientNetB0** | Efficient scaling | Balanced performance | 91% |

### Disease Classification Pipeline

```python
Input Image → Preprocessing → Feature Extraction → Classification → Disease Prediction
     │              │                  │                 │               │
     ▼              ▼                  ▼                 ▼               ▼
  224x224     Normalization      CNN Backbone      Softmax Layer    38 Classes
```

### Supported Crops & Diseases

<details>
<summary>🌾 <b>Click to expand full list</b></summary>

| Crop | Diseases Detected |
|------|------------------|
| 🍎 Apple | Scab, Black Rot, Cedar Rust, Healthy |
| 🫐 Blueberry | Healthy |
| 🍒 Cherry | Powdery Mildew, Healthy |
| 🌽 Corn | Cercospora Leaf Spot, Common Rust, Northern Leaf Blight, Healthy |
| 🍇 Grape | Black Rot, Esca, Leaf Blight, Healthy |
| 🍊 Orange | Haunglongbing (Citrus Greening) |
| 🍑 Peach | Bacterial Spot, Healthy |
| 🌶️ Pepper | Bacterial Spot, Healthy |
| 🥔 Potato | Early Blight, Late Blight, Healthy |
| 🍓 Strawberry | Leaf Scorch, Healthy |
| 🍅 Tomato | Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spider Mites, Target Spot, Yellow Leaf Curl Virus, Mosaic Virus, Healthy |
| 🌱 Soybean | Healthy |
| 🎃 Squash | Powdery Mildew |
| 🌿 Raspberry | Healthy |

</details>

---

## 📱 App Screenshots

<table>
  <tr>
    <td align="center"><b>🏠 Home Screen</b></td>
    <td align="center"><b>🔬 Disease Detection</b></td>
    <td align="center"><b>🤖 AI Chatbot</b></td>
    <td align="center"><b>🌤️ Weather</b></td>
  </tr>
  <tr>
    <td>Intuitive dashboard with quick access to all features</td>
    <td>Upload or capture plant images for instant analysis</td>
    <td>Ask agricultural questions in natural language</td>
    <td>Real-time weather data for farming decisions</td>
  </tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.35 or higher
- **Python**: 3.10 or higher
- **Git**: Latest version

### Installation

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/BAP7478/PRAKRUTI-Plant-deases-detection.git
cd PRAKRUTI-Plant-deases-detection
```

#### 2️⃣ Setup Backend Server

```bash
# Navigate to backend directory
cd prakruti-backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the server
./start_backend_simple.sh
# Or manually: uvicorn app_lite:app --host 0.0.0.0 --port 8000
```

#### 3️⃣ Setup Flutter App

```bash
# Navigate back to root
cd ..

# Get Flutter dependencies
flutter pub get

# Run on iOS Simulator
flutter run -d iPhone

# Run on Android Emulator
flutter run -d android

# Run on Web
flutter run -d chrome
```

### ⚡ Quick Start (One Command)

```bash
# Start everything with one command
./start_prakruti.sh
```

---

## 🔧 Configuration

### API Configuration

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String predictEndpoint = '/predict';
  static const String chatEndpoint = '/chat';
}
```

### Weather API Setup

The app uses **Open-Meteo API** (free, no API key required). For custom weather providers, edit the weather service configuration.

---

## 📊 Model Performance

### Training Metrics

| Metric | Value |
|--------|-------|
| **Training Accuracy** | 94.2% |
| **Validation Accuracy** | 91.8% |
| **Test Accuracy** | 89.5% |
| **F1-Score** | 0.90 |
| **Precision** | 0.91 |
| **Recall** | 0.89 |

### Confusion Matrix

The model demonstrates strong performance across all 38 disease classes with minimal false positives and negatives. See `CONFUSION_MATRIX_EXPLANATION.md` for detailed analysis.

---

## 🛠️ Tech Stack

<table>
<tr>
<td>

### 📱 Frontend
- **Framework**: Flutter 3.35
- **Language**: Dart
- **State Management**: Provider
- **HTTP Client**: Dio
- **Localization**: flutter_localizations

</td>
<td>

### ⚙️ Backend
- **Framework**: FastAPI
- **Language**: Python 3.10+
- **ML Framework**: TensorFlow 2.x
- **Server**: Uvicorn
- **Image Processing**: Pillow, OpenCV

</td>
</tr>
</table>

### 🤖 AI/ML Libraries

```
tensorflow==2.15.0
keras==2.15.0
numpy==1.24.0
pillow==10.0.0
scikit-learn==1.3.0
opencv-python==4.8.0
```

---

## 📁 Project Structure

```
prakruti/
├── 📱 lib/                      # Flutter application source
│   ├── config/                  # App configuration
│   ├── models/                  # Data models
│   ├── screens/                 # UI screens
│   ├── services/                # API services
│   ├── widgets/                 # Reusable widgets
│   └── main.dart                # App entry point
│
├── 🎨 assets/                   # Static assets
│   ├── fonts/                   # Custom fonts
│   ├── icons/                   # App icons
│   ├── images/                  # Images
│   └── lang/                    # Localization files
│
├── 🐍 prakruti-backend/         # Python ML backend
│   ├── models/                  # Trained ML models
│   ├── app_lite.py              # FastAPI server
│   ├── requirements.txt         # Python dependencies
│   └── start_backend_simple.sh  # Startup script
│
├── 🤖 android/                  # Android platform files
├── 🍎 ios/                      # iOS platform files
├── 🌐 web/                      # Web platform files
│
└── 📚 Documentation
    ├── README.md
    ├── PRAKRUTI_TECHNICAL_DOCUMENTATION.md
    ├── PRAKRUTI_VIVA_QUESTIONS.md
    └── CONFUSION_MATRIX_EXPLANATION.md
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Author

<p align="center">
  <img src="https://github.com/BAP7478.png" width="100" height="100" style="border-radius: 50%;">
</p>

<h3 align="center">Bhargav Patel</h3>
<p align="center">
  <a href="https://github.com/BAP7478">
    <img src="https://img.shields.io/badge/GitHub-BAP7478-181717?style=for-the-badge&logo=github" alt="GitHub">
  </a>
</p>

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **PlantVillage Dataset** - For providing the training data
- **TensorFlow Team** - For the amazing ML framework
- **Flutter Team** - For the beautiful cross-platform framework
- **Open-Meteo** - For free weather API

---

<p align="center">
  <b>⭐ If you found this project helpful, please give it a star! ⭐</b>
</p>

<p align="center">
  Made with ❤️ for farmers and agriculture
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Plant%20Health-Matters-green?style=for-the-badge" alt="Plant Health Matters">
</p>
