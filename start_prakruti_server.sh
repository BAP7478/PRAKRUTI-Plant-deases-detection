#!/bin/bash
# PRAKRUTI Backend Startup Script
# This script ensures the server always starts from the correct directory

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/prakruti-backend"

echo "🌱 PRAKRUTI Backend Startup Script"
echo "Script directory: $SCRIPT_DIR"
echo "Backend directory: $BACKEND_DIR"

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ Backend directory not found: $BACKEND_DIR"
    exit 1
fi

# Check if app_enhanced.py exists
if [ ! -f "$BACKEND_DIR/app_enhanced.py" ]; then
    echo "❌ app_enhanced.py not found in: $BACKEND_DIR"
    exit 1
fi

# Change to backend directory
cd "$BACKEND_DIR"
echo "✅ Changed to backend directory: $(pwd)"

# Kill any existing uvicorn processes
echo "🔄 Stopping any existing servers..."
pkill -f "uvicorn.*app_enhanced" || true
sleep 2

# Start the server
echo "🚀 Starting PRAKRUTI Backend Server..."
echo "   - Host: 0.0.0.0"
echo "   - Port: 8002"
echo "   - Module: app_enhanced:app"
echo ""

# Start uvicorn with proper error handling
if command -v python3 &> /dev/null; then
    python3 -m uvicorn app_enhanced:app --host 0.0.0.0 --port 8002 --reload
else
    echo "❌ python3 not found. Please install Python 3."
    exit 1
fi
