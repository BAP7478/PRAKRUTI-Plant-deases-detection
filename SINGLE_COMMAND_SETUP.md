# 🌱 PRAKRUTI - Single-Command Setup Guide

## 🚀 Quick Start (One Command)

### Start Everything with One Command:
```bash
./start_prakruti.sh
```

That's it! This single command will:
- ✅ Start the backend API server
- ✅ Start the Flutter frontend application  
- ✅ Handle port conflicts automatically
- ✅ Set up proper environment configuration
- ✅ Show you all running services with URLs

## 📋 What the Script Does

### 🔧 Automatic Setup:
1. **Backend Server**: Starts FastAPI server with disease detection AI
2. **Frontend App**: Launches Flutter web application
3. **Port Detection**: Automatically finds available ports (8002+, 3000+)
4. **Error Handling**: Gracefully handles conflicts and failures
5. **Health Checks**: Verifies backend is running before starting frontend
6. **Logging**: Creates detailed logs for debugging

### 🎯 Smart Features:
- **Port Conflict Resolution**: If port 8002 is busy, tries 8003, 8004, etc.
- **Backend Connectivity**: Frontend automatically connects to detected backend port
- **Process Management**: Tracks all process IDs for clean shutdown
- **Real-time Status**: Shows live status of all services

## 📱 Access Your Application

Once started, you'll see:
```
🎉 PRAKRUTI Application Started Successfully!
===========================================
📊 Backend API: http://localhost:8002
📱 Frontend App: http://localhost:3000
🏥 Health Check: http://localhost:8002/health
📚 API Docs: http://localhost:8002/docs
```

## 🛠 Management Commands

### Start Application:
```bash
./start_prakruti.sh
```

### Stop Application:
```bash
./stop_prakruti.sh
```

### View Logs:
```bash
./logs_prakruti.sh
```

## 📊 Log Management

The logs viewer provides interactive options:
1. **Backend logs**: See API server activity
2. **Frontend logs**: View Flutter app output
3. **Both logs**: Combined view
4. **Live tail**: Real-time log monitoring
5. **Clear logs**: Clean up old log files

## 🔧 Configuration

### Environment Variables
The startup script automatically sets:
- `PRAKRUTI_HOST=0.0.0.0`
- `PRAKRUTI_PORT=8002` (or next available)
- `PRAKRUTI_DEBUG=true`

### Frontend Configuration
- Automatically detects backend URL
- Handles connection timeouts
- Supports offline mode if backend unavailable
- Multi-platform support (Android, iOS, web, desktop)

## 🔄 Automatic Features

### Port Management
- **Backend**: Starts on 8002, auto-increments if busy
- **Frontend**: Starts on 3000, auto-increments if busy
- **Conflict Resolution**: Kills existing processes if needed

### Error Recovery
- **Health Monitoring**: Continuous backend health checks
- **Auto-restart**: Restarts failed services (planned feature)
- **Graceful Shutdown**: Proper cleanup on exit

### Development Workflow
- **Hot Reload**: Backend auto-reloads on code changes
- **Live Updates**: Frontend updates automatically
- **Cross-Platform**: Works on macOS, Linux, Windows

## 📁 Project Structure

```
prakruti/
├── start_prakruti.sh          # 🚀 Main startup script
├── stop_prakruti.sh           # 🛑 Shutdown script  
├── logs_prakruti.sh           # 📄 Log viewer
├── lib/
│   ├── config/
│   │   └── app_config.dart    # ⚙️ Configuration
│   ├── services/
│   │   └── api_service.dart   # 🌐 API client
│   └── main.dart              # 🏠 App entry point
├── prakruti-backend/
│   ├── app_enhanced.py        # 🤖 AI backend
│   ├── requirements.txt       # 📦 Dependencies
│   └── models/                # 🧠 ML models
└── logs/
    ├── backend.log            # 📊 Backend logs
    └── frontend.log           # 📱 Frontend logs
```

## 🐛 Troubleshooting

### Common Issues

#### Backend Won't Start
```bash
# Check if port is in use
lsof -i :8002

# Kill process on port
./stop_prakruti.sh

# Restart
./start_prakruti.sh
```

#### Frontend Connection Issues
```bash
# Check backend health
curl http://localhost:8002/health

# View logs
./logs_prakruti.sh
```

#### Permission Issues
```bash
# Make scripts executable
chmod +x *.sh
```

### Detailed Debugging

#### Check Running Processes
```bash
# View saved process info
cat .prakruti_pids

# Check all processes
ps aux | grep -E "(uvicorn|flutter)"
```

#### Manual Backend Start
```bash
cd prakruti-backend
python3 -m uvicorn app_enhanced:app --reload --host 0.0.0.0 --port 8002
```

#### Manual Frontend Start
```bash
flutter run -d web-server --web-port 3000
```

## ⚡ Performance Optimization

### Development Mode
- Backend auto-reloads on file changes
- Frontend hot-reloads during development
- Debug logging enabled by default

### Production Mode
- Set `PRAKRUTI_DEBUG=false` for production
- Update `AppConfig.baseUrl` for production API
- Disable verbose logging

## 🔒 Security Considerations

### Development
- Backend runs on `0.0.0.0` (all interfaces) for testing
- Debug mode enabled for detailed error messages
- CORS enabled for frontend access

### Production
- Change host to specific IP for production
- Disable debug mode
- Configure proper CORS origins
- Use HTTPS for production deployment

## 🎯 Features Working

### ✅ Fully Integrated
- **Disease Detection**: AI-powered plant disease identification
- **Remedies Database**: 45+ Indian crop diseases with treatments
- **Weather Integration**: Location-based weather information
- **Community Features**: Social platform for farmers
- **Multi-language**: English/Gujarati support
- **Offline Mode**: Works without backend connection

### ✅ Enhanced UI
- **Modern Design**: Premium gradients and animations
- **Password Toggle**: Show/hide password functionality
- **Responsive Layout**: Works on all screen sizes
- **Professional Styling**: Production-ready interface

## 📞 Support

If you encounter any issues:

1. **Check logs**: `./logs_prakruti.sh`
2. **Stop and restart**: `./stop_prakruti.sh && ./start_prakruti.sh`
3. **Clear logs**: Choose option 6 in log viewer
4. **Check ports**: Make sure ports 8002 and 3000 are available

## 🎉 Success Indicators

When everything is working correctly, you should see:
- ✅ Backend API responding at health endpoint
- ✅ Frontend loading at web URL
- ✅ No error messages in logs
- ✅ API documentation accessible
- ✅ Disease detection working
- ✅ Gujarati localization active

---

**🌱 PRAKRUTI - Making agriculture smart, one command at a time!**
