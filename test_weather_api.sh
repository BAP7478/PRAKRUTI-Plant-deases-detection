#!/bin/bash
# Weather API Test Script for PRAKRUTI

echo "🌤️  PRAKRUTI Weather API Test"
echo "==============================="
echo

# Check if backend is running
if curl -s http://localhost:8002/health > /dev/null; then
    echo "✅ Backend server is running"
else
    echo "❌ Backend server is not running"
    echo "Please start it with: cd prakruti-backend && python3 -m uvicorn app_enhanced:app --host 0.0.0.0 --port 8002"
    exit 1
fi

echo
echo "📍 Testing weather for different Indian cities:"
echo

cities=("Mumbai" "Delhi" "Bangalore" "Chennai" "Kolkata" "Ahmedabad")

for city in "${cities[@]}"; do
    echo "🏙️  $city:"
    response=$(curl -s "http://localhost:8002/weather?location=$city")
    
    # Parse response using Python for better formatting
    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    weather_data = data['data']
    source = weather_data.get('data_source', 'Unknown')
    
    if 'Mock Data' in source:
        print(f'   📱 Temperature: {weather_data[\"temperature\"]} (MOCK DATA)')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]} (MOCK DATA)')
        print(f'   🌤️  Condition: {weather_data[\"condition\"]} (MOCK DATA)')
        print(f'   🔗 Source: Offline Mode - Add real API key for live data')
    else:
        print(f'   📱 Temperature: {weather_data[\"temperature\"]} (LIVE DATA)')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]} (LIVE DATA)')
        print(f'   🌤️  Condition: {weather_data[\"condition\"]} (LIVE DATA)')
        print(f'   🔗 Source: {source}')
    
except Exception as e:
    print(f'   ❌ Error: {str(e)}')
"
    echo
done

echo "🔑 To get REAL weather data:"
echo "1. Get free API key from: https://openweathermap.org/api"
echo "2. Replace 'demo_key' in prakruti-backend/.env with your real API key"
echo "3. Restart the backend server"
echo "4. Test again - you'll see LIVE weather data!"
echo
echo "💡 Current API key status:"
if grep -q "demo_key" /Users/bhargav/Desktop/PRAKRUTI/prakruti/prakruti-backend/.env; then
    echo "   📝 Using demo_key (mock data mode)"
else
    echo "   🔑 Using real API key (live data mode)"
fi
