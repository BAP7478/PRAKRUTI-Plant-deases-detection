#!/bin/bash

# 🌱 PRAKRUTI - Final Working Startup Script
# This script starts PRAKRUTI application successfully

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🌱 PRAKRUTI Application Startup${NC}"
echo -e "${CYAN}================================${NC}"

# Clean up function
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down PRAKRUTI...${NC}"
    pkill -f "uvicorn" 2>/dev/null || true
    pkill -f "flutter run" 2>/dev/null || true
    echo -e "${GREEN}✅ Shutdown complete.${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Clean up any existing processes
echo -e "${YELLOW}🧹 Cleaning up existing processes...${NC}"
pkill -f "uvicorn" 2>/dev/null || true
pkill -f "flutter run" 2>/dev/null || true
sleep 2

# Create logs directory
mkdir -p logs

# Start backend
echo -e "${BLUE}🚀 Starting Backend Server...${NC}"
cd prakruti-backend

# Start backend in background
nohup python3 -m uvicorn app_enhanced:app --reload --host 0.0.0.0 --port 8002 > ../logs/backend.log 2>&1 &
BACKEND_PID=$!

cd ..

# Wait for backend to start
echo -e "${YELLOW}⏳ Waiting for backend to initialize (15 seconds)...${NC}"
sleep 15

# Test backend health
echo -e "${YELLOW}🏥 Testing backend health...${NC}"
for i in {1..5}; do
    if curl -s http://localhost:8002/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy and running!${NC}"
        break
    else
        echo -e "${YELLOW}⏳ Attempt $i: Backend not ready yet...${NC}"
        sleep 3
    fi
done

# Create Flutter config
echo -e "${BLUE}⚙️ Configuring Flutter app...${NC}"
mkdir -p lib/config
cat > lib/config/app_config.dart << 'EOL'
class AppConfig {
  static const String baseUrl = 'http://localhost:8002';
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String chatEndpoint = '/chat';
  static const String remediesEndpoint = '/remedies';
  static const String weatherEndpoint = '/weather';
  
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get predictUrl => '$baseUrl$predictEndpoint';
  static String get chatUrl => '$baseUrl$chatEndpoint';
  static String get remediesUrl => '$baseUrl$remediesEndpoint';
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
nohup flutter run -d chrome --web-port 3000 > logs/frontend.log 2>&1 &
FRONTEND_PID=$!

# Save PIDs
echo "BACKEND_PID=$BACKEND_PID" > .prakruti_pids
echo "FRONTEND_PID=$FRONTEND_PID" >> .prakruti_pids

echo -e "\n${GREEN}🎉 PRAKRUTI Started Successfully!${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "${CYAN}📊 Backend API: http://localhost:8002${NC}"
echo -e "${CYAN}📱 Flutter App: http://localhost:3000${NC}"
echo -e "${CYAN}🏥 Health Check: http://localhost:8002/health${NC}"
echo -e "${CYAN}📚 API Documentation: http://localhost:8002/docs${NC}"
echo -e "\n${YELLOW}💡 Backend PID: $BACKEND_PID${NC}"
echo -e "${YELLOW}💡 Frontend PID: $FRONTEND_PID${NC}"
echo -e "\n${CYAN}📄 View backend logs: tail -f logs/backend.log${NC}"
echo -e "${CYAN}📄 View frontend logs: tail -f logs/frontend.log${NC}"
echo -e "${CYAN}🛑 Stop application: Press Ctrl+C or run ./stop_prakruti.sh${NC}"

# Monitor processes
echo -e "\n${GREEN}🔄 Application is running. Monitoring processes...${NC}"
echo -e "${GREEN}Press Ctrl+C to stop the application.${NC}"

while true; do
    sleep 10
    
    # Check if backend is still running
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Backend process stopped unexpectedly${NC}"
        echo -e "${YELLOW}📄 Check backend logs: tail logs/backend.log${NC}"
        break
    fi
    
    # Check if frontend is still running
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Frontend process stopped unexpectedly${NC}"
        echo -e "${YELLOW}📄 Check frontend logs: tail logs/frontend.log${NC}"
        break
    fi
    
    # Periodic health check
    if ! curl -s http://localhost:8002/health > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️ Backend health check failed${NC}"
    fi
done

cleanup
