@echo off
REM Quick script to start the local development server on Windows

echo 🚀 Starting AutoSalon Development Server...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    pause
    exit /b 1
)

REM Check if npm is installed
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed. Please install npm first.
    pause
    exit /b 1
)

REM Navigate to backend directory
cd lib\backend

echo 📁 Current directory: %cd%

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
)

REM Check if package.json exists
if not exist "package.json" (
    echo ❌ package.json not found. Please ensure you're in the correct directory.
    pause
    exit /b 1
)

echo ✅ Dependencies installed
echo 🔧 Starting server...
echo.
echo 📍 Server will run on: http://localhost:3000
echo 🗄️ Database: PostgreSQL (autosalon)
echo.
echo 🧪 Test endpoints:
echo    http://localhost:3000/api/test
echo    http://localhost:3000/api/db-test
echo    http://localhost:3000/api/stats
echo    http://localhost:3000/api/cars
echo.
echo 👤 Default login:
echo    Email: admin@autosalon.com
echo    Password: 123456
echo.

REM Start the server
npm start

pause