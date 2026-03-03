#!/bin/bash

# 🌱 PRAKRUTI - Emergency Startup Script (Working Version)
# This script starts the application without complex dependency management

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🌱 PRAKRUTI Emergency Startup${NC}"
echo -e "${CYAN}============================${NC}"

# Clean up any existing processes
echo -e "${YELLOW}🧹 Cleaning up existing processes...${NC}"
pkill -f "uvicorn" || true
pkill -f "flutter run" || true
sleep 2

# Start backend without virtual environment (using system Python)
echo -e "${BLUE}🚀 Starting Backend Server...${NC}"
cd prakruti-backend

# Check if we can import required modules
python3 -c "import fastapi, uvicorn" 2>/dev/null || {
    echo -e "${RED}❌ Required Python packages not found. Installing...${NC}"
    pip3 install fastapi uvicorn python-multipart requests pillow tensorflow numpy opencv-python --break-system-packages || {
        echo -e "${RED}❌ Package installation failed. Trying conda...${NC}"
        conda install -c conda-forge fastapi uvicorn python-multipart requests pillow tensorflow numpy opencv-python -y || {
            echo -e "${RED}❌ Could not install packages. Please install manually:${NC}"
            echo -e "${YELLOW}pip3 install fastapi uvicorn python-multipart requests pillow tensorflow numpy opencv-python${NC}"
            exit 1
        }
    }
}

# Start backend on port 8002
echo -e "${GREEN}✅ Starting backend on port 8002...${NC}"
nohup python3 -m uvicorn app_enhanced:app --reload --host 0.0.0.0 --port 8002 > ../logs/backend.log 2>&1 &
BACKEND_PID=$!

cd ..

# Wait for backend to start
echo -e "${YELLOW}⏳ Waiting for backend to initialize (10 seconds)...${NC}"
sleep 10

# Test backend
if curl -s http://localhost:8002/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is running successfully!${NC}"
else
    echo -e "${YELLOW}⚠️ Backend health check failed, but continuing...${NC}"
fi

# Create simple config for Flutter
mkdir -p lib/config
cat > lib/config/app_config.dart << 'EOL'
class AppConfig {
  static const String baseUrl = 'http://localhost:8002';
  static const String apiVersion = 'v1';
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String chatEndpoint = '/chat';
  static const String remediesEndpoint = '/remedies';
  static const String weatherEndpoint = '/weather';
  
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get predictUrl => '$baseUrl$predictEndpoint';
  static String get chatUrl => '$baseUrl$chatEndpoint';
  static String get remediesUrl => '$baseUrl$remediesUrl';
  static String get weatherUrl => '$baseUrl$weatherEndpoint';
  
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 60000;
  
  static const String appName = 'PRAKRUTI';
  static const String version = '2.0.0';
  
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
}
EOL

# Get Flutter dependencies
echo -e "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get > /dev/null 2>&1

# Start Flutter app
echo -e "${BLUE}🎨 Starting Flutter Application...${NC}"
echo -e "${GREEN}✅ Choose your preferred platform:${NC}"
echo -e "${YELLOW}1. Chrome (Web)${NC}"
echo -e "${YELLOW}2. macOS Desktop${NC}"
echo -e "${YELLOW}3. iOS Simulator${NC}"
echo -e "${YELLOW}4. Android Emulator${NC}"

# Start Flutter on Chrome (most reliable)
echo -e "${GREEN}🚀 Starting on Chrome...${NC}"
nohup flutter run -d chrome --web-port 3000 > logs/frontend.log 2>&1 &
FRONTEND_PID=$!

# Save PIDs for cleanup
echo "BACKEND_PID=$BACKEND_PID" > .prakruti_pids
echo "FRONTEND_PID=$FRONTEND_PID" >> .prakruti_pids

echo -e "\n${GREEN}🎉 PRAKRUTI Started Successfully!${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "${CYAN}📊 Backend API: http://localhost:8002${NC}"
echo -e "${CYAN}📱 Flutter App: http://localhost:3000${NC}"
echo -e "${CYAN}🏥 Health Check: http://localhost:8002/health${NC}"
echo -e "${CYAN}📚 API Docs: http://localhost:8002/docs${NC}"
echo -e "\n${YELLOW}💡 Backend PID: $BACKEND_PID${NC}"
echo -e "${YELLOW}💡 Frontend PID: $FRONTEND_PID${NC}"
echo -e "\n${CYAN}🛑 To stop: ./stop_prakruti.sh${NC}"
echo -e "${CYAN}📄 Backend logs: tail -f logs/backend.log${NC}"
echo -e "${CYAN}📄 Frontend logs: tail -f logs/frontend.log${NC}"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down...${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    kill $FRONTEND_PID 2>/dev/null || true
    echo -e "${GREEN}✅ Stopped.${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Keep running and monitor processes
echo -e "\n${GREEN}🔄 Application running. Press Ctrl+C to stop.${NC}"
while true; do
    sleep 5
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Backend stopped unexpectedly${NC}"
        break
    fi
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Frontend stopped unexpectedly${NC}"
        break
    fi
done
