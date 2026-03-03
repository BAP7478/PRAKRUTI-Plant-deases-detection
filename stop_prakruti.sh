#!/bin/bash

# 🌱 PRAKRUTI - Application Stop Script
# This script gracefully stops both backend and frontend

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🛑 Stopping PRAKRUTI Application${NC}"
echo -e "${CYAN}===============================${NC}"

# Function to kill process by PID
kill_process() {
    local pid=$1
    local name=$2
    
    if [ ! -z "$pid" ]; then
        if kill -0 $pid 2>/dev/null; then
            echo -e "${YELLOW}Stopping $name (PID: $pid)...${NC}"
            kill $pid 2>/dev/null
            sleep 2
            
            # Force kill if still running
            if kill -0 $pid 2>/dev/null; then
                echo -e "${YELLOW}Force stopping $name...${NC}"
                kill -9 $pid 2>/dev/null
            fi
            
            echo -e "${GREEN}✅ $name stopped${NC}"
        else
            echo -e "${YELLOW}$name was not running${NC}"
        fi
    fi
}

# Function to kill processes by port
kill_by_port() {
    local port=$1
    local name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}Stopping processes on port $port ($name)...${NC}"
        lsof -ti:$port | xargs kill -9 2>/dev/null || true
        sleep 1
        echo -e "${GREEN}✅ Processes on port $port stopped${NC}"
    else
        echo -e "${YELLOW}No processes running on port $port${NC}"
    fi
}

# Read saved PIDs if available
if [ -f ".prakruti_pids" ]; then
    source .prakruti_pids
    
    kill_process $BACKEND_PID "Backend"
    kill_process $FRONTEND_PID "Frontend"
    
    # Clean up PID file
    rm -f .prakruti_pids
else
    echo -e "${YELLOW}No PID file found, attempting to stop by port...${NC}"
    
    # Stop common ports
    kill_by_port 8002 "Backend"
    kill_by_port 8003 "Backend (alt)"
    kill_by_port 3000 "Frontend"
    kill_by_port 3001 "Frontend (alt)"
fi

# Kill any remaining Flutter processes
if pgrep -f "flutter run" > /dev/null; then
    echo -e "${YELLOW}Stopping remaining Flutter processes...${NC}"
    pkill -f "flutter run" 2>/dev/null || true
    echo -e "${GREEN}✅ Flutter processes stopped${NC}"
fi

# Kill any remaining Python/uvicorn processes for PRAKRUTI
if pgrep -f "uvicorn app_enhanced:app" > /dev/null; then
    echo -e "${YELLOW}Stopping remaining backend processes...${NC}"
    pkill -f "uvicorn app_enhanced:app" 2>/dev/null || true
    echo -e "${GREEN}✅ Backend processes stopped${NC}"
fi

echo -e "\n${GREEN}🎉 PRAKRUTI Application stopped successfully!${NC}"
echo -e "${CYAN}To start the application again, run: ${YELLOW}./start_prakruti.sh${NC}"
