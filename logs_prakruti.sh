#!/bin/bash

# 🌱 PRAKRUTI - Logs Viewer Script
# This script displays logs from both backend and frontend

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOG_DIR="logs"
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"

echo -e "${CYAN}📄 PRAKRUTI Application Logs${NC}"
echo -e "${CYAN}=============================${NC}"

# Function to display menu
show_menu() {
    echo -e "\n${YELLOW}Select log to view:${NC}"
    echo -e "${GREEN}1)${NC} Backend logs"
    echo -e "${GREEN}2)${NC} Frontend logs"
    echo -e "${GREEN}3)${NC} Both logs (side by side)"
    echo -e "${GREEN}4)${NC} Tail backend logs (live)"
    echo -e "${GREEN}5)${NC} Tail frontend logs (live)"
    echo -e "${GREEN}6)${NC} Clear all logs"
    echo -e "${GREEN}7)${NC} Exit"
    echo -e "\n${CYAN}Enter your choice [1-7]: ${NC}"
}

# Function to view backend logs
view_backend_logs() {
    echo -e "\n${BLUE}📊 Backend Logs:${NC}"
    echo -e "${BLUE}================${NC}"
    if [ -f "$BACKEND_LOG" ]; then
        cat "$BACKEND_LOG"
    else
        echo -e "${YELLOW}No backend logs found${NC}"
    fi
}

# Function to view frontend logs
view_frontend_logs() {
    echo -e "\n${BLUE}📱 Frontend Logs:${NC}"
    echo -e "${BLUE}=================${NC}"
    if [ -f "$FRONTEND_LOG" ]; then
        cat "$FRONTEND_LOG"
    else
        echo -e "${YELLOW}No frontend logs found${NC}"
    fi
}

# Function to view both logs
view_both_logs() {
    echo -e "\n${BLUE}📊📱 All Application Logs:${NC}"
    echo -e "${BLUE}=========================${NC}"
    
    if [ -f "$BACKEND_LOG" ] && [ -f "$FRONTEND_LOG" ]; then
        echo -e "\n${GREEN}--- Backend Logs ---${NC}"
        cat "$BACKEND_LOG"
        echo -e "\n${GREEN}--- Frontend Logs ---${NC}"
        cat "$FRONTEND_LOG"
    elif [ -f "$BACKEND_LOG" ]; then
        echo -e "${YELLOW}Only backend logs available${NC}"
        cat "$BACKEND_LOG"
    elif [ -f "$FRONTEND_LOG" ]; then
        echo -e "${YELLOW}Only frontend logs available${NC}"
        cat "$FRONTEND_LOG"
    else
        echo -e "${YELLOW}No logs found${NC}"
    fi
}

# Function to tail backend logs
tail_backend_logs() {
    echo -e "\n${BLUE}📊 Backend Live Logs (Press Ctrl+C to stop):${NC}"
    echo -e "${BLUE}=============================================${NC}"
    if [ -f "$BACKEND_LOG" ]; then
        tail -f "$BACKEND_LOG"
    else
        echo -e "${YELLOW}No backend logs found. Waiting for logs...${NC}"
        tail -f "$BACKEND_LOG" 2>/dev/null || echo -e "${RED}Backend log file not created yet${NC}"
    fi
}

# Function to tail frontend logs
tail_frontend_logs() {
    echo -e "\n${BLUE}📱 Frontend Live Logs (Press Ctrl+C to stop):${NC}"
    echo -e "${BLUE}===============================================${NC}"
    if [ -f "$FRONTEND_LOG" ]; then
        tail -f "$FRONTEND_LOG"
    else
        echo -e "${YELLOW}No frontend logs found. Waiting for logs...${NC}"
        tail -f "$FRONTEND_LOG" 2>/dev/null || echo -e "${RED}Frontend log file not created yet${NC}"
    fi
}

# Function to clear logs
clear_logs() {
    echo -e "\n${YELLOW}🧹 Clearing all logs...${NC}"
    rm -f "$BACKEND_LOG" "$FRONTEND_LOG"
    echo -e "${GREEN}✅ All logs cleared${NC}"
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            view_backend_logs
            ;;
        2)
            view_frontend_logs
            ;;
        3)
            view_both_logs
            ;;
        4)
            tail_backend_logs
            ;;
        5)
            tail_frontend_logs
            ;;
        6)
            clear_logs
            ;;
        7)
            echo -e "\n${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}❌ Invalid option. Please choose 1-7.${NC}"
            ;;
    esac
    
    if [ "$choice" != "4" ] && [ "$choice" != "5" ]; then
        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
    fi
done
