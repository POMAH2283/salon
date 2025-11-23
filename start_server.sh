#!/bin/bash
# Quick script to start the local development server

echo "🚀 Starting AutoSalon Development Server..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Navigate to backend directory
cd lib/backend

echo "📁 Current directory: $(pwd)"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please ensure you're in the correct directory."
    exit 1
fi

echo "✅ Dependencies installed"
echo "🔧 Starting server..."
echo ""
echo "📍 Server will run on: http://localhost:3000"
echo "🗄️ Database: PostgreSQL (autosalon)"
echo ""
echo "🧪 Test endpoints:"
echo "   http://localhost:3000/api/test"
echo "   http://localhost:3000/api/db-test"
echo "   http://localhost:3000/api/stats"
echo "   http://localhost:3000/api/cars"
echo ""
echo "👤 Default login:"
echo "   Email: admin@autosalon.com"
echo "   Password: 123456"
echo ""

# Start the server
npm start