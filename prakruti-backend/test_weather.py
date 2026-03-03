#!/usr/bin/env python3
"""
Simple test script for PRAKRUTI Weather API
"""
import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from weather_service import WeatherService

async def test_weather_api():
    print("🌤️  Testing PRAKRUTI Weather Service")
    print("=" * 50)
    
    # Test locations
    locations = ["Ahmedabad", "Mumbai", "Delhi", "Rajkot"]
    
    weather_service = WeatherService()
    
    for location in locations:
        print(f"\n📍 Testing weather for: {location}")
        try:
            weather_data = await weather_service.get_weather_by_location(location)
            if weather_data:
                print(f"✅ Success! Temperature: {weather_data.get('temperature', 'N/A')}°C")
                print(f"   Humidity: {weather_data.get('humidity', 'N/A')}%")
                print(f"   Description: {weather_data.get('description', 'N/A')}")
                print(f"   Source: {weather_data.get('source', 'N/A')}")
            else:
                print("❌ No weather data received")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("✨ Weather API test completed!")

if __name__ == "__main__":
    asyncio.run(test_weather_api())
