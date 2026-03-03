"""
Weather Service for PRAKRUTI Backend
Integrates with OpenWeatherMap API for real weather data
"""

import aiohttp
import asyncio
from typing import Dict, Optional, List
import logging
from config import settings

logger = logging.getLogger(__name__)

class WeatherService:
    """Service for fetching real weather data from OpenWeatherMap API"""
    
    def __init__(self):
        self.api_key = settings.weather_api_key
        self.base_url = settings.weather_api_url
        self.cache = {}  # Simple in-memory cache
        self.cache_ttl = 300  # 5 minutes cache
        
    async def get_weather_by_location(self, location: str) -> Optional[Dict]:
        """Get current weather data for a specific location"""
        
        if not self.api_key or self.api_key == "demo_key":
            logger.warning("No valid weather API key configured, returning mock data")
            return self._get_mock_weather_data(location)
        
        # Check cache first
        cache_key = f"weather_{location.lower()}"
        if cache_key in self.cache:
            cached_data, timestamp = self.cache[cache_key]
            if (asyncio.get_event_loop().time() - timestamp) < self.cache_ttl:
                logger.info(f"Returning cached weather data for {location}")
                return cached_data
        
        try:
            async with aiohttp.ClientSession() as session:
                # Get current weather
                current_url = f"{self.base_url}/weather"
                params = {
                    'q': location,
                    'appid': self.api_key,
                    'units': 'metric'  # Celsius
                }
                
                async with session.get(current_url, params=params) as response:
                    if response.status == 200:
                        current_data = await response.json()
                        
                        # Get forecast data
                        forecast_data = await self._get_forecast_data(session, location)
                        
                        # Process and format the data
                        weather_data = self._format_weather_data(current_data, forecast_data)
                        
                        # Cache the result
                        self.cache[cache_key] = (weather_data, asyncio.get_event_loop().time())
                        
                        logger.info(f"Successfully fetched weather data for {location}")
                        return weather_data
                    
                    elif response.status == 401:
                        logger.error("Invalid API key for OpenWeatherMap")
                        return self._get_mock_weather_data(location, error="Invalid API key")
                    
                    elif response.status == 404:
                        logger.error(f"Location '{location}' not found")
                        return self._get_mock_weather_data(location, error="Location not found")
                    
                    else:
                        logger.error(f"Weather API error: {response.status}")
                        return self._get_mock_weather_data(location, error=f"API error: {response.status}")
                        
        except Exception as e:
            logger.error(f"Error fetching weather data: {e}")
            return self._get_mock_weather_data(location, error=str(e))
    
    async def _get_forecast_data(self, session: aiohttp.ClientSession, location: str) -> Optional[Dict]:
        """Get 5-day forecast data"""
        try:
            forecast_url = f"{self.base_url}/forecast"
            params = {
                'q': location,
                'appid': self.api_key,
                'units': 'metric',
                'cnt': 8  # Next 24 hours (8 * 3-hour intervals)
            }
            
            async with session.get(forecast_url, params=params) as response:
                if response.status == 200:
                    return await response.json()
                return None
        except Exception as e:
            logger.error(f"Error fetching forecast data: {e}")
            return None
    
    def _format_weather_data(self, current: Dict, forecast: Optional[Dict] = None) -> Dict:
        """Format weather data for frontend consumption"""
        
        # Extract current weather data
        main = current.get('main', {})
        weather = current.get('weather', [{}])[0]
        wind = current.get('wind', {})
        
        formatted_data = {
            'location': current.get('name', 'Unknown'),
            'country': current.get('sys', {}).get('country', ''),
            'temperature': f"{round(main.get('temp', 0))}°C",
            'feels_like': f"{round(main.get('feels_like', 0))}°C",
            'humidity': f"{main.get('humidity', 0)}%",
            'pressure': f"{main.get('pressure', 0)} hPa",
            'wind_speed': f"{round(wind.get('speed', 0) * 3.6)} km/h",  # Convert m/s to km/h
            'wind_direction': wind.get('deg', 0),
            'visibility': f"{current.get('visibility', 0) / 1000} km",
            'condition': weather.get('main', 'Unknown'),
            'description': weather.get('description', '').title(),
            'icon': weather.get('icon', '01d'),
            'sunrise': current.get('sys', {}).get('sunrise'),
            'sunset': current.get('sys', {}).get('sunset'),
            'data_source': 'OpenWeatherMap API',
            'last_updated': 'Just now'
        }
        
        # Add forecast data if available
        if forecast and 'list' in forecast:
            forecast_list = []
            for item in forecast['list'][:3]:  # Next 3 forecasts (9 hours)
                forecast_weather = item.get('weather', [{}])[0]
                forecast_list.append({
                    'time': item.get('dt_txt', ''),
                    'temp': f"{round(item.get('main', {}).get('temp', 0))}°C",
                    'condition': forecast_weather.get('main', 'Unknown'),
                    'description': forecast_weather.get('description', '').title(),
                    'icon': forecast_weather.get('icon', '01d')
                })
            
            formatted_data['forecast'] = forecast_list
        
        return formatted_data
    
    def _get_mock_weather_data(self, location: str, error: Optional[str] = None) -> Dict:
        """Return mock weather data when API is unavailable"""
        
        base_mock_data = {
            'location': location,
            'country': 'IN',
            'temperature': '28°C',
            'feels_like': '31°C',
            'humidity': '65%',
            'pressure': '1013 hPa',
            'wind_speed': '12 km/h',
            'wind_direction': 180,
            'visibility': '10 km',
            'condition': 'Partly Cloudy',
            'description': 'Partly Cloudy',
            'icon': '02d',
            'data_source': 'Mock Data (Offline Mode)',
            'last_updated': 'Simulated data',
            'forecast': [
                {
                    'time': 'Next 3 hours',
                    'temp': '29°C',
                    'condition': 'Sunny',
                    'description': 'Clear Sky',
                    'icon': '01d'
                },
                {
                    'time': 'Next 6 hours',
                    'temp': '31°C',
                    'condition': 'Sunny',
                    'description': 'Clear Sky',
                    'icon': '01d'
                },
                {
                    'time': 'Next 9 hours',
                    'temp': '26°C',
                    'condition': 'Cloudy',
                    'description': 'Few Clouds',
                    'icon': '02n'
                }
            ]
        }
        
        if error:
            base_mock_data['error'] = error
            base_mock_data['data_source'] = f'Mock Data (Error: {error})'
        
        return base_mock_data

    async def get_weather_by_coordinates(self, lat: float, lon: float) -> Optional[Dict]:
        """Get weather data by latitude and longitude"""
        
        if not self.api_key or self.api_key == "demo_key":
            return self._get_mock_weather_data(f"Lat:{lat}, Lon:{lon}")
        
        try:
            async with aiohttp.ClientSession() as session:
                url = f"{self.base_url}/weather"
                params = {
                    'lat': lat,
                    'lon': lon,
                    'appid': self.api_key,
                    'units': 'metric'
                }
                
                async with session.get(url, params=params) as response:
                    if response.status == 200:
                        current_data = await response.json()
                        forecast_data = await self._get_forecast_by_coordinates(session, lat, lon)
                        return self._format_weather_data(current_data, forecast_data)
                    else:
                        return self._get_mock_weather_data(f"Lat:{lat}, Lon:{lon}", 
                                                         error=f"API error: {response.status}")
        
        except Exception as e:
            logger.error(f"Error fetching weather by coordinates: {e}")
            return self._get_mock_weather_data(f"Lat:{lat}, Lon:{lon}", error=str(e))
    
    async def _get_forecast_by_coordinates(self, session: aiohttp.ClientSession, 
                                         lat: float, lon: float) -> Optional[Dict]:
        """Get forecast data by coordinates"""
        try:
            url = f"{self.base_url}/forecast"
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.api_key,
                'units': 'metric',
                'cnt': 8
            }
            
            async with session.get(url, params=params) as response:
                if response.status == 200:
                    return await response.json()
                return None
        except Exception as e:
            logger.error(f"Error fetching forecast by coordinates: {e}")
            return None
    
    # Alias methods for API compatibility
    async def get_weather_data(self, location: str) -> Optional[Dict]:
        """Alias for get_weather_by_location"""
        return await self.get_weather_by_location(location)
    
    async def get_forecast(self, location: str, days: int = 5) -> Optional[List[Dict]]:
        """Get weather forecast for a location"""
        try:
            async with aiohttp.ClientSession() as session:
                forecast_data = await self._get_forecast_data(session, location)
                if forecast_data and 'list' in forecast_data:
                    # Convert to simple list format
                    forecast_list = []
                    for item in forecast_data['list'][:days]:
                        forecast_list.append({
                            'date': item['dt_txt'].split(' ')[0],
                            'temperature': round(item['main']['temp'] - 273.15, 1),  # Convert K to C
                            'humidity': item['main']['humidity'],
                            'description': item['weather'][0]['description'].title(),
                            'wind_speed': item['wind']['speed'],
                            'pressure': item['main']['pressure']
                        })
                    return forecast_list
                return None
        except Exception as e:
            logger.error(f"Error getting forecast: {e}")
            return None

# Global weather service instance
weather_service = WeatherService()
