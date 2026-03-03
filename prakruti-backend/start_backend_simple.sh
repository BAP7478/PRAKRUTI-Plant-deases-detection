#!/bin/bash

# Simple PRAKRUTI Backend Startup Script
# This starts the backend server with minimal configuration

echo "🌱 Starting PRAKRUTI Backend Server..."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Working directory: $(pwd)"
echo ""

# Kill any existing servers on port 5000-5003
echo "🔄 Checking for existing servers..."
lsof -ti:5000 | xargs kill -9 2>/dev/null || true
lsof -ti:5001 | xargs kill -9 2>/dev/null || true
lsof -ti:5002 | xargs kill -9 2>/dev/null || true
lsof -ti:8000 | xargs kill -9 2>/dev/null || true
lsof -ti:8002 | xargs kill -9 2>/dev/null || true

echo "✅ Ports cleared"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found"
    exit 1
fi

echo "✅ Python found: $(which python3)"
echo ""

# Try different app files in order of preference
if [ -f "app_lite.py" ]; then
    echo "🚀 Starting with app_lite.py (recommended)..."
    echo "📡 Server will run on: http://localhost:8000"
    echo ""
    python3 -m uvicorn app_lite:app --host 0.0.0.0 --port 8000 --reload
elif [ -f "app_simple.py" ]; then
    echo "🚀 Starting with app_simple.py..."
    echo "📡 Server will run on: http://localhost:8000"
    echo ""
    python3 -m uvicorn app_simple:app --host 0.0.0.0 --port 8000 --reload
elif [ -f "app.py" ]; then
    echo "🚀 Starting with app.py..."
    echo "📡 Server will run on: http://localhost:5002"
    echo ""
    python3 app.py
else
    echo "❌ No suitable app file found"
    exit 1
fi
