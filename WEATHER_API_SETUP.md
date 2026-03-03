# 🌤️ OpenWeatherMap API Setup Guide

## Quick Setup (2 minutes)

### Step 1: Get Your FREE API Key
1. Go to: https://openweathermap.org/api
2. Click "Sign Up" (it's completely FREE!)
3. Fill out the form with your details
4. Check your email and verify your account
5. Log in to your dashboard
6. Copy your API key from the "API Keys" section

### Step 2: Configure PRAKRUTI
1. Open: `prakruti-backend/.env`
2. Replace `demo_key` with your actual API key:
   ```
   PRAKRUTI_WEATHER_API_KEY=your_actual_api_key_here
   ```
3. Save the file

### Step 3: Test the Weather Feature
1. Start PRAKRUTI: `./start_prakruti.sh`
2. Open the app and go to Weather section
3. Enter a city name (e.g., "Ahmedabad", "Mumbai", "Delhi")
4. You'll now see real weather data!

## API Details

### FREE Tier Benefits ✅
- **Cost:** $0 (Completely Free!)
- **Calls:** 1,000 per day
- **Rate Limit:** 60 calls per minute
- **Data:** Current weather + 5-day forecast
- **No Credit Card Required**

### Perfect for PRAKRUTI because:
- Agricultural app needs weather data
- 1,000 calls/day = plenty for farming community
- Automatic offline fallback if API is down
- No subscription fees

## Current Status
- ✅ Weather service fully implemented
- ✅ Offline fallback configured
- ✅ Error handling included
- ✅ Caching for efficiency
- ⏳ Just needs your API key!

## Test Without API Key
The app works perfectly without an API key too - it shows mock weather data with a clear "Offline Mode" indicator.

## Support
If you need help getting your API key, the OpenWeatherMap support is excellent and the process is very straightforward.
