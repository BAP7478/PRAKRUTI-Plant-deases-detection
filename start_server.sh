#!/bin/bash
# PRAKRUTI Backend Startup Script
# This script ensures server starts from correct directory

echo "🌱 Starting PRAKRUTI Backend Server..."
cd /Users/bhargav/Desktop/PRAKRUTI/prakruti/prakruti-backend
echo "📁 Changed to: $(pwd)"
echo "🚀 Starting server on port 8002..."
python3 -m uvicorn app_enhanced:app --host 0.0.0.0 --port 8002 --reload
