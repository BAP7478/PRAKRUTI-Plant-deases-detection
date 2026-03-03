#!/usr/bin/env python3
"""
Test script to verify PRAKRUTI backend improvements
"""

import requests
import json
import time

BASE_URL = "http://127.0.0.1:8002"

def test_endpoint(endpoint, description):
    """Test an endpoint and print results"""
    print(f"\n🧪 Testing {description}")
    print(f"   Endpoint: {endpoint}")
    try:
        response = requests.get(f"{BASE_URL}{endpoint}", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Status: {response.status_code}")
            print(f"   📊 Response keys: {list(data.keys())}")
            return True
        else:
            print(f"   ❌ Status: {response.status_code}")
            print(f"   📄 Response: {response.text}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Connection error: {e}")
        return False

def main():
    print("🌱 PRAKRUTI Backend Improvement Tests")
    print("=" * 50)
    
    # Test basic endpoints
    tests = [
        ("/", "Root endpoint with configuration info"),
        ("/health", "Enhanced health check"),
        ("/diseases", "Disease list endpoint"),
        ("/recommend/Healthy", "Disease remedy lookup"),
        ("/recommend/Late_blight", "Specific disease remedy"),
        ("/config", "Configuration endpoint (may require auth)")
    ]
    
    passed = 0
    total = len(tests)
    
    for endpoint, description in tests:
        if test_endpoint(endpoint, description):
            passed += 1
        time.sleep(0.5)  # Brief pause between tests
    
    print(f"\n📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Backend improvements are working correctly.")
    else:
        print("⚠️  Some tests failed. Check the backend logs for details.")

if __name__ == "__main__":
    main()
