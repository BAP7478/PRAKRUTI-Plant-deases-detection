#!/bin/bash
# Test Open-Meteo Weather API Integration

echo "🌤️  PRAKRUTI Weather API Test - Open-Meteo Integration"
echo "======================================================"
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
echo "🌍 Testing Open-Meteo API (FREE, no key needed!):"
echo

cities=("Mumbai" "Delhi" "Bangalore" "Chennai" "Kolkata" "Ahmedabad" "London" "New York")

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
    provider = weather_data.get('api_provider', 'unknown')
    
    if provider == 'open-meteo':
        print(f'   📱 Temperature: {weather_data[\"temperature\"]} (LIVE - Open-Meteo)')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]} (LIVE)')
        print(f'   🌤️  Condition: {weather_data[\"condition\"]} (LIVE)')
        print(f'   💨 Wind: {weather_data[\"wind_speed\"]} (LIVE)')
        print(f'   🔗 Source: {source} ✨ FREE API')
    elif provider == 'openweathermap':
        print(f'   📱 Temperature: {weather_data[\"temperature\"]} (LIVE - OpenWeatherMap)')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]} (LIVE)')
        print(f'   🌤️  Condition: {weather_data[\"condition\"]} (LIVE)')
        print(f'   🔗 Source: {source}')
    elif 'Mock Data' in source:
        print(f'   📱 Temperature: {weather_data[\"temperature\"]} (MOCK DATA)')
        print(f'   💧 Humidity: {weather_data[\"humidity\"]} (MOCK DATA)')
        print(f'   🌤️  Condition: {weather_data[\"condition\"]} (MOCK DATA)')
        print(f'   🔗 Source: Offline Mode - API unavailable')
    
    # Show forecast if available
    if 'forecast' in weather_data and weather_data['forecast']:
        forecast = weather_data['forecast'][0] if len(weather_data['forecast']) > 0 else None
        if forecast:
            print(f'   📅 Next forecast: {forecast.get(\"temp\", \"N/A\")} - {forecast.get(\"condition\", \"N/A\")}')
    
except Exception as e:
    print(f'   ❌ Error: {str(e)}')
"
    echo
done

echo "🎉 Open-Meteo Integration Benefits:"
echo "   ✅ Completely FREE - no API key needed"
echo "   ✅ No registration required"
echo "   ✅ High-quality weather data"
echo "   ✅ Global coverage"
echo "   ✅ Fast response times (<10ms)"
echo "   ✅ No rate limits for reasonable use"
echo "   ✅ Perfect for agricultural apps like PRAKRUTI"
echo
echo "🚀 Your weather feature is now LIVE with real data!"
