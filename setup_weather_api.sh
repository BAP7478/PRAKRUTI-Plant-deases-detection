#!/bin/bash
# OpenWeatherMap API Key Setup Script

echo "🔑 OpenWeatherMap API Key Setup for PRAKRUTI"
echo "============================================="
echo

# Check if user provided API key as argument
if [ "$1" != "" ]; then
    API_KEY="$1"
    echo "✅ API Key provided: ${API_KEY:0:8}****** (hidden for security)"
else
    echo "📝 Please enter your OpenWeatherMap API key:"
    echo "   (Get it FREE from: https://openweathermap.org/api)"
    echo
    read -p "🔑 API Key: " API_KEY
fi

if [ "$API_KEY" = "" ]; then
    echo "❌ No API key provided. Exiting."
    exit 1
fi

# Backup current .env file
cp prakruti-backend/.env prakruti-backend/.env.backup
echo "💾 Backed up current .env to .env.backup"

# Replace the API key in .env file
sed -i.tmp "s/PRAKRUTI_WEATHER_API_KEY=demo_key/PRAKRUTI_WEATHER_API_KEY=$API_KEY/" prakruti-backend/.env
rm prakruti-backend/.env.tmp

echo "✅ API key updated in prakruti-backend/.env"

# Check if backend is running and restart it
if pgrep -f "uvicorn app_enhanced:app" > /dev/null; then
    echo "🔄 Restarting backend server to apply new API key..."
    pkill -f "uvicorn app_enhanced:app"
    sleep 2
    cd prakruti-backend
    nohup python3 -m uvicorn app_enhanced:app --host 0.0.0.0 --port 8002 > server.log 2>&1 &
    cd ..
    sleep 3
    echo "✅ Backend server restarted"
else
    echo "ℹ️  Backend server not running. Start it manually if needed."
fi

echo
echo "🧪 Testing with real API key..."
echo

# Test the API
if curl -s http://localhost:8002/health > /dev/null; then
    echo "📍 Testing real weather data for Mumbai:"
    response=$(curl -s "http://localhost:8002/weather?location=Mumbai")
    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    weather_data = data['data']
    source = weather_data.get('data_source', 'Unknown')
    
    if 'Mock Data' in source:
        print('❌ Still using mock data - API key may be invalid')
        print(f'   Error: {weather_data.get(\"error\", \"Unknown error\")}')
    else:
        print('🎉 SUCCESS! Real weather data retrieved:')
        print(f'   🌡️  Temperature: {weather_data[\"temperature\"]}')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]}')
        print(f'   🌤️  Condition: {weather_data[\"description\"]}')
        print(f'   💨 Wind: {weather_data[\"wind_speed\"]}')
        print(f'   🔗 Source: {source}')
        
except Exception as e:
    print(f'❌ Error testing API: {str(e)}')
"
else
    echo "❌ Backend server is not responding"
fi

echo
echo "🎯 Setup Complete!"
echo "   • Your API key is now active"
echo "   • Weather data is live (if API key is valid)"
echo "   • Frontend will show real weather data"
echo "   • Automatic fallback to offline mode if API fails"
echo
echo "🚀 Next steps:"
echo "   1. Open PRAKRUTI app"
echo "   2. Go to Weather section"  
echo "   3. Enter any city name"
echo "   4. Enjoy real weather data!"
