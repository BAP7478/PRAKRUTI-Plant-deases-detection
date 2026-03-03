#!/bin/bash

# 🌱 PRAKRUTI - Complete Application Startup Script
# This script starts both backend and frontend with automatic error handling

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="prakruti-backend"
BACKEND_PORT=8002
FRONTEND_PORT=3000
LOG_DIR="logs"
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"

# Create logs directory
mkdir -p $LOG_DIR

echo -e "${CYAN}🌱 PRAKRUTI Application Startup${NC}"
echo -e "${CYAN}==============================${NC}"

# Function to check if port is available
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1  # Port is in use
    else
        return 0  # Port is available
    fi
}

# Function to find available port
find_available_port() {
    local start_port=$1
    local port=$start_port
    while ! check_port $port; do
        echo -e "${YELLOW}Port $port is in use, trying $((port + 1))...${NC}"
        port=$((port + 1))
    done
    echo $port
}

# Function to kill processes on specific ports
cleanup_ports() {
    echo -e "${YELLOW}🧹 Cleaning up existing processes...${NC}"
    
    # Kill processes on backend port
    if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}Killing process on port $BACKEND_PORT${NC}"
        lsof -ti:$BACKEND_PORT | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Kill processes on frontend port
    if lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}Killing process on port $FRONTEND_PORT${NC}"
        lsof -ti:$FRONTEND_PORT | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

# Function to start backend
start_backend() {
    echo -e "${BLUE}🚀 Starting Backend Server...${NC}"
    
    cd $BACKEND_DIR
    
    # Check if virtual environment exists, create if not
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Creating Python virtual environment...${NC}"
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install requirements
    echo -e "${YELLOW}Installing/updating Python dependencies...${NC}"
    pip install -q -r requirements.txt
    
    # Find available port for backend
    BACKEND_PORT=$(find_available_port $BACKEND_PORT)
    echo -e "${GREEN}Backend will use port: $BACKEND_PORT${NC}"
    
    # Update backend configuration with correct port
    export PRAKRUTI_HOST="0.0.0.0"
    export PRAKRUTI_PORT="$BACKEND_PORT"
    export PRAKRUTI_DEBUG="true"
    
    # Start backend server
    echo -e "${GREEN}✅ Backend starting on http://localhost:$BACKEND_PORT${NC}"
    nohup python3 -m uvicorn app_enhanced:app --reload --host 0.0.0.0 --port $BACKEND_PORT > "../$BACKEND_LOG" 2>&1 &
    BACKEND_PID=$!
    
    cd ..
    
    # Wait for backend to start
    echo -e "${YELLOW}⏳ Waiting for backend to initialize...${NC}"
    sleep 5
    
    # Check if backend is running
    if curl -s http://localhost:$BACKEND_PORT/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is running successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Backend failed to start. Check logs: $BACKEND_LOG${NC}"
        return 1
    fi
}

# Function to start frontend
start_frontend() {
    echo -e "${BLUE}🎨 Starting Frontend Application...${NC}"
    
    # Update frontend configuration with backend URL
    create_config_dart
    
    # Get Flutter dependencies
    echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
    flutter pub get > /dev/null 2>&1
    
    # Find available port for frontend
    FRONTEND_PORT=$(find_available_port $FRONTEND_PORT)
    echo -e "${GREEN}Frontend will use port: $FRONTEND_PORT${NC}"
    
    # Start frontend
    echo -e "${GREEN}✅ Frontend starting on http://localhost:$FRONTEND_PORT${NC}"
    nohup flutter run -d web-server --web-port $FRONTEND_PORT --web-hostname 0.0.0.0 > "$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    
    # Wait for frontend to start
    echo -e "${YELLOW}⏳ Waiting for frontend to build and start...${NC}"
    sleep 15
    
    echo -e "${GREEN}✅ Frontend is running successfully!${NC}"
}

# Function to create configuration for frontend
create_config_dart() {
    cat > lib/config/app_config.dart << EOL
// 🌱 PRAKRUTI App Configuration
// Auto-generated configuration file

class AppConfig {
  static const String baseUrl = 'http://localhost:$BACKEND_PORT';
  static const String apiVersion = 'v1';
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String remediesEndpoint = '/remedies';
  static const String weatherEndpoint = '/weather';
  
  // API URLs
  static String get healthUrl => '\$baseUrl\$healthEndpoint';
  static String get predictUrl => '\$baseUrl\$predictEndpoint';
  static String get remediesUrl => '\$baseUrl\$remediesEndpoint';
  static String get weatherUrl => '\$baseUrl\$weatherEndpoint';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  
  // App Info
  static const String appName = 'PRAKRUTI';
  static const String version = '2.0.0';
  
  // Development settings
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
}
EOL
    
    # Create config directory if it doesn't exist
    mkdir -p lib/config
}

# Function to display running services info
show_service_info() {
    echo -e "\n${PURPLE}🎉 PRAKRUTI Application Started Successfully!${NC}"
    echo -e "${PURPLE}===========================================${NC}"
    echo -e "${GREEN}📊 Backend API: ${CYAN}http://localhost:$BACKEND_PORT${NC}"
    echo -e "${GREEN}📱 Frontend App: ${CYAN}http://localhost:$FRONTEND_PORT${NC}"
    echo -e "${GREEN}🏥 Health Check: ${CYAN}http://localhost:$BACKEND_PORT/health${NC}"
    echo -e "${GREEN}📚 API Docs: ${CYAN}http://localhost:$BACKEND_PORT/docs${NC}"
    echo -e "\n${YELLOW}📋 Process Information:${NC}"
    echo -e "${YELLOW}Backend PID: $BACKEND_PID${NC}"
    echo -e "${YELLOW}Frontend PID: $FRONTEND_PID${NC}"
    echo -e "\n${YELLOW}📄 Log Files:${NC}"
    echo -e "${YELLOW}Backend: $BACKEND_LOG${NC}"
    echo -e "${YELLOW}Frontend: $FRONTEND_LOG${NC}"
    echo -e "\n${CYAN}🛑 To stop all services, run: ${YELLOW}./stop_prakruti.sh${NC}"
    echo -e "${CYAN}📊 To view logs, run: ${YELLOW}./logs_prakruti.sh${NC}"
}

# Function to save PIDs for later cleanup
save_pids() {
    cat > .prakruti_pids << EOL
BACKEND_PID=$BACKEND_PID
FRONTEND_PID=$FRONTEND_PID
BACKEND_PORT=$BACKEND_PORT
FRONTEND_PORT=$FRONTEND_PORT
EOL
}

# Cleanup function for graceful shutdown
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down PRAKRUTI application...${NC}"
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ Application stopped.${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    echo -e "${CYAN}🔍 Checking prerequisites...${NC}"
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
        exit 1
    fi
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 is not installed or not in PATH${NC}"
        exit 1
    fi
    
    # Check if backend directory exists
    if [ ! -d "$BACKEND_DIR" ]; then
        echo -e "${RED}❌ Backend directory '$BACKEND_DIR' not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
    
    # Clean up existing processes
    cleanup_ports
    
    # Start services
    if start_backend; then
        start_frontend
        save_pids
        show_service_info
        
        # Keep script running to maintain processes
        echo -e "\n${GREEN}🔄 Application is running. Press Ctrl+C to stop.${NC}"
        while true; do
            sleep 10
            # Check if processes are still running
            if ! kill -0 $BACKEND_PID 2>/dev/null; then
                echo -e "${RED}❌ Backend process stopped unexpectedly${NC}"
                break
            fi
            if ! kill -0 $FRONTEND_PID 2>/dev/null; then
                echo -e "${RED}❌ Frontend process stopped unexpectedly${NC}"
                break
            fi
        done
    else
        echo -e "${RED}❌ Failed to start backend. Aborting.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
