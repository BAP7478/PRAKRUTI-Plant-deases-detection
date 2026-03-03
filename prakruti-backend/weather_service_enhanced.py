"""
Enhanced Weather Service for PRAKRUTI Backend
Integrates with Open-Meteo (FREE, no API key needed) and OpenWeatherMap
"""

import aiohttp
import asyncio
from typing import Dict, Optional, List
import logging
from config import settings
import time
from datetime import datetime, timedelta
import ssl

logger = logging.getLogger(__name__)

class WeatherService:
    """Service for fetching real weather data using multiple free APIs"""
    
    def __init__(self):
        self.openweather_api_key = settings.weather_api_key
        self.openweather_base_url = settings.weather_api_url
        
        # Open-Meteo API (FREE, no key needed!)
        self.open_meteo_base_url = "https://api.open-meteo.com/v1"
        self.geocoding_url = "https://geocoding-api.open-meteo.com/v1"
        
        self.cache = {}  # Simple in-memory cache
        self.cache_ttl = 300  # 5 minutes cache
        
    async def get_weather_by_location(self, location: str) -> Optional[Dict]:
        """Get current weather data using Open-Meteo (preferred) or OpenWeatherMap fallback"""
        
        # Check cache first
        cache_key = f"weather_{location.lower()}"
        if cache_key in self.cache:
            cached_data, timestamp = self.cache[cache_key]
            if (time.time() - timestamp) < self.cache_ttl:
                logger.info(f"Returning cached weather data for {location}")
                return cached_data
        
        # Try Open-Meteo first (no API key needed!)
        weather_data = await self._get_open_meteo_weather(location)
        
        # Fallback to OpenWeatherMap if Open-Meteo fails
        if not weather_data:
            logger.info("Open-Meteo failed, trying OpenWeatherMap fallback...")
            weather_data = await self._get_openweather_weather(location)
        
        # Final fallback to mock data
        if not weather_data:
            logger.warning("All APIs failed, using mock data")
            weather_data = self._get_mock_weather_data(location, error="All APIs unavailable")
        
        # Cache the result
        if weather_data:
            self.cache[cache_key] = (weather_data, time.time())
        
        return weather_data
    
    async def _get_open_meteo_weather(self, location: str) -> Optional[Dict]:
        """Get weather data from Open-Meteo API (FREE, no key needed)"""
        try:
            # Create SSL context that doesn't verify certificates (for development)
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE
            
            connector = aiohttp.TCPConnector(ssl=ssl_context)
            async with aiohttp.ClientSession(connector=connector) as session:
                # First, get coordinates for the location
                coordinates = await self._geocode_location(session, location)
                if not coordinates:
                    logger.error(f"Could not geocode location: {location}")
                    return None
                
                lat, lon, city_name, country = coordinates
                
                # Get current weather and forecast
                weather_url = f"{self.open_meteo_base_url}/forecast"
                params = {
                    'latitude': lat,
                    'longitude': lon,
                    'current': [
                        'temperature_2m', 'relative_humidity_2m', 'apparent_temperature',
                        'is_day', 'precipitation', 'weather_code', 'cloud_cover',
                        'pressure_msl', 'surface_pressure', 'wind_speed_10m',
                        'wind_direction_10m', 'wind_gusts_10m'
                    ],
                    'hourly': [
                        'temperature_2m', 'relative_humidity_2m', 'weather_code',
                        'precipitation_probability', 'wind_speed_10m'
                    ],
                    'daily': [
                        'temperature_2m_max', 'temperature_2m_min', 'weather_code',
                        'precipitation_sum', 'wind_speed_10m_max'
                    ],
                    'timezone': 'auto',
                    'forecast_days': 3
                }
                
                async with session.get(weather_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        return self._format_open_meteo_data(data, city_name, country)
                    else:
                        logger.error(f"Open-Meteo API error: {response.status}")
                        return None
                        
        except Exception as e:
            logger.error(f"Error fetching Open-Meteo weather data: {e}")
            return None
    
    async def _geocode_location(self, session: aiohttp.ClientSession, location: str) -> Optional[tuple]:
        """Geocode location name to coordinates using Open-Meteo geocoding"""
        try:
            geocode_url = f"{self.geocoding_url}/search"
            params = {
                'name': location,
                'count': 1,
                'language': 'en',
                'format': 'json'
            }
            
            async with session.get(geocode_url, params=params) as response:
                if response.status == 200:
                    data = await response.json()
                    if data.get('results') and len(data['results']) > 0:
                        result = data['results'][0]
                        return (
                            result['latitude'],
                            result['longitude'],
                            result['name'],
                            result.get('country', 'Unknown')
                        )
                return None
                
        except Exception as e:
            logger.error(f"Error geocoding location {location}: {e}")
            return None
    
    def _format_open_meteo_data(self, data: Dict, city_name: str, country: str) -> Dict:
        """Format Open-Meteo data for frontend consumption"""
        try:
            current = data.get('current', {})
            daily = data.get('daily', {})
            hourly = data.get('hourly', {})
            
            # Weather code to description mapping (WMO codes)
            weather_codes = {
                0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
                45: "Fog", 48: "Depositing rime fog", 51: "Light drizzle", 53: "Moderate drizzle",
                55: "Dense drizzle", 56: "Light freezing drizzle", 57: "Dense freezing drizzle",
                61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain", 66: "Light freezing rain",
                67: "Heavy freezing rain", 71: "Slight snow", 73: "Moderate snow", 75: "Heavy snow",
                77: "Snow grains", 80: "Slight rain showers", 81: "Moderate rain showers",
                82: "Violent rain showers", 85: "Slight snow showers", 86: "Heavy snow showers",
                95: "Thunderstorm", 96: "Thunderstorm with slight hail", 99: "Thunderstorm with heavy hail"
            }
            
            weather_code = current.get('weather_code', 0)
            condition = weather_codes.get(weather_code, "Unknown")
            
            formatted_data = {
                'location': city_name,
                'country': country,
                'temperature': f"{round(current.get('temperature_2m', 0))}°C",
                'feels_like': f"{round(current.get('apparent_temperature', 0))}°C",
                'humidity': f"{current.get('relative_humidity_2m', 0)}%",
                'pressure': f"{round(current.get('pressure_msl', 1013))} hPa",
                'wind_speed': f"{round(current.get('wind_speed_10m', 0) * 3.6)} km/h",  # Convert m/s to km/h
                'wind_direction': current.get('wind_direction_10m', 0),
                'wind_gusts': f"{round(current.get('wind_gusts_10m', 0) * 3.6)} km/h",
                'cloud_cover': f"{current.get('cloud_cover', 0)}%",
                'condition': condition,
                'description': condition,
                'weather_code': weather_code,
                'is_day': current.get('is_day', 1) == 1,
                'precipitation': f"{current.get('precipitation', 0)} mm",
                'data_source': 'Open-Meteo API (FREE)',
                'last_updated': 'Live data',
                'api_provider': 'open-meteo'
            }
            
            # Add forecast data if available
            if hourly and 'time' in hourly and len(hourly['time']) > 0:
                forecast_list = []
                for i in range(min(6, len(hourly['time']))):  # Next 6 hours
                    hour_weather_code = hourly.get('weather_code', [0])[i] if i < len(hourly.get('weather_code', [])) else 0
                    hour_condition = weather_codes.get(hour_weather_code, "Unknown")
                    
                    forecast_list.append({
                        'time': hourly['time'][i],
                        'temp': f"{round(hourly.get('temperature_2m', [0])[i] if i < len(hourly.get('temperature_2m', [])) else 0)}°C",
                        'humidity': f"{hourly.get('relative_humidity_2m', [0])[i] if i < len(hourly.get('relative_humidity_2m', [])) else 0}%",
                        'condition': hour_condition,
                        'description': hour_condition,
                        'precipitation_probability': f"{hourly.get('precipitation_probability', [0])[i] if i < len(hourly.get('precipitation_probability', [])) else 0}%",
                        'wind_speed': f"{round((hourly.get('wind_speed_10m', [0])[i] if i < len(hourly.get('wind_speed_10m', [])) else 0) * 3.6)} km/h"
                    })
                
                formatted_data['forecast'] = forecast_list
            
            # Add daily forecast
            if daily and 'time' in daily and len(daily['time']) > 0:
                daily_forecast = []
                for i in range(min(3, len(daily['time']))):  # Next 3 days
                    day_weather_code = daily.get('weather_code', [0])[i] if i < len(daily.get('weather_code', [])) else 0
                    day_condition = weather_codes.get(day_weather_code, "Unknown")
                    
                    daily_forecast.append({
                        'date': daily['time'][i],
                        'temp_max': f"{round(daily.get('temperature_2m_max', [0])[i] if i < len(daily.get('temperature_2m_max', [])) else 0)}°C",
                        'temp_min': f"{round(daily.get('temperature_2m_min', [0])[i] if i < len(daily.get('temperature_2m_min', [])) else 0)}°C",
                        'condition': day_condition,
                        'precipitation': f"{daily.get('precipitation_sum', [0])[i] if i < len(daily.get('precipitation_sum', [])) else 0} mm",
                        'wind_speed_max': f"{round((daily.get('wind_speed_10m_max', [0])[i] if i < len(daily.get('wind_speed_10m_max', [])) else 0) * 3.6)} km/h"
                    })
                
                formatted_data['daily_forecast'] = daily_forecast
            
            return formatted_data
            
        except Exception as e:
            logger.error(f"Error formatting Open-Meteo data: {e}")
            return None
    
    async def _get_openweather_weather(self, location: str) -> Optional[Dict]:
        """Fallback to OpenWeatherMap API if available"""
        if not self.openweather_api_key or self.openweather_api_key == "demo_key":
            return None
        
        try:
            async with aiohttp.ClientSession() as session:
                # Get current weather
                current_url = f"{self.openweather_base_url}/weather"
                params = {
                    'q': location,
                    'appid': self.openweather_api_key,
                    'units': 'metric'
                }
                
                async with session.get(current_url, params=params) as response:
                    if response.status == 200:
                        current_data = await response.json()
                        forecast_data = await self._get_openweather_forecast(session, location)
                        return self._format_openweather_data(current_data, forecast_data)
                    else:
                        logger.error(f"OpenWeatherMap API error: {response.status}")
                        return None
                        
        except Exception as e:
            logger.error(f"Error fetching OpenWeatherMap data: {e}")
            return None
    
    async def _get_openweather_forecast(self, session: aiohttp.ClientSession, location: str) -> Optional[Dict]:
        """Get OpenWeatherMap forecast data"""
        try:
            forecast_url = f"{self.openweather_base_url}/forecast"
            params = {
                'q': location,
                'appid': self.openweather_api_key,
                'units': 'metric',
                'cnt': 8  # Next 24 hours
            }
            
            async with session.get(forecast_url, params=params) as response:
                if response.status == 200:
                    return await response.json()
                return None
        except Exception as e:
            logger.error(f"Error fetching OpenWeatherMap forecast: {e}")
            return None
    
    def _format_openweather_data(self, current: Dict, forecast: Optional[Dict] = None) -> Dict:
        """Format OpenWeatherMap data for frontend consumption"""
        try:
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
                'wind_speed': f"{round(wind.get('speed', 0) * 3.6)} km/h",
                'wind_direction': wind.get('deg', 0),
                'condition': weather.get('main', 'Unknown'),
                'description': weather.get('description', '').title(),
                'data_source': 'OpenWeatherMap API',
                'last_updated': 'Live data',
                'api_provider': 'openweathermap'
            }
            
            # Add forecast data if available
            if forecast and 'list' in forecast:
                forecast_list = []
                for item in forecast['list'][:6]:  # Next 6 forecasts
                    forecast_weather = item.get('weather', [{}])[0]
                    forecast_list.append({
                        'time': item.get('dt_txt', ''),
                        'temp': f"{round(item.get('main', {}).get('temp', 0))}°C",
                        'condition': forecast_weather.get('main', 'Unknown'),
                        'description': forecast_weather.get('description', '').title()
                    })
                
                formatted_data['forecast'] = forecast_list
            
            return formatted_data
            
        except Exception as e:
            logger.error(f"Error formatting OpenWeatherMap data: {e}")
            return None
    
    def _get_mock_weather_data(self, location: str, error: Optional[str] = None) -> Dict:
        """Return mock weather data when APIs are unavailable"""
        base_mock_data = {
            'location': location,
            'country': 'IN',
            'temperature': '28°C',
            'feels_like': '31°C',
            'humidity': '65%',
            'pressure': '1013 hPa',
            'wind_speed': '12 km/h',
            'wind_direction': 180,
            'condition': 'Partly Cloudy',
            'description': 'Partly Cloudy',
            'data_source': 'Mock Data (Offline Mode)',
            'last_updated': 'Simulated data',
            'api_provider': 'mock',
            'forecast': [
                {
                    'time': 'Next 3 hours',
                    'temp': '29°C',
                    'condition': 'Sunny',
                    'description': 'Clear Sky'
                },
                {
                    'time': 'Next 6 hours',
                    'temp': '31°C',
                    'condition': 'Sunny',
                    'description': 'Clear Sky'
                },
                {
                    'time': 'Next 9 hours',
                    'temp': '26°C',
                    'condition': 'Cloudy',
                    'description': 'Few Clouds'
                }
            ]
        }
        
        if error:
            base_mock_data['error'] = error
            base_mock_data['data_source'] = f'Mock Data (Error: {error})'
        
        return base_mock_data

    # Alias methods for API compatibility
    async def get_weather_data(self, location: str) -> Optional[Dict]:
        """Alias for get_weather_by_location"""
        return await self.get_weather_by_location(location)
    
    async def get_weather_by_coordinates(self, lat: float, lon: float) -> Optional[Dict]:
        """Get weather data by coordinates using Open-Meteo"""
        try:
            # Create SSL context that doesn't verify certificates (for development)
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE
            
            connector = aiohttp.TCPConnector(ssl=ssl_context)
            async with aiohttp.ClientSession(connector=connector) as session:
                weather_url = f"{self.open_meteo_base_url}/forecast"
                params = {
                    'latitude': lat,
                    'longitude': lon,
                    'current': [
                        'temperature_2m', 'relative_humidity_2m', 'apparent_temperature',
                        'weather_code', 'pressure_msl', 'wind_speed_10m', 'wind_direction_10m'
                    ],
                    'timezone': 'auto'
                }
                
                async with session.get(weather_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        return self._format_open_meteo_data(data, f"Lat:{lat}", f"Lon:{lon}")
                    else:
                        return self._get_mock_weather_data(f"Lat:{lat}, Lon:{lon}", 
                                                         error=f"API error: {response.status}")
        
        except Exception as e:
            logger.error(f"Error fetching weather by coordinates: {e}")
            return self._get_mock_weather_data(f"Lat:{lat}, Lon:{lon}", error=str(e))
    
    async def get_forecast(self, location: str, days: int = 5) -> Optional[List[Dict]]:
        """Get weather forecast for a location"""
        try:
            weather_data = await self.get_weather_by_location(location)
            if weather_data and 'daily_forecast' in weather_data:
                return weather_data['daily_forecast'][:days]
            elif weather_data and 'forecast' in weather_data:
                # Convert hourly to daily approximation
                return weather_data['forecast'][:days]
            return None
        except Exception as e:
            logger.error(f"Error getting forecast: {e}")
            return None

# Global weather service instance
weather_service = WeatherService()
