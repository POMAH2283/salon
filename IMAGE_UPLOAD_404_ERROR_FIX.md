# Image Upload 404 Error - Complete Solution

## Problem Diagnosis

You're getting a 404 error because:

1. **URL Mismatch**: Your Flutter app is configured to use `https://autosalon1.onrender.com` but this server either:
   - Is not running
   - Doesn't have the photo upload endpoints implemented
   - Is not accessible

2. **Authentication Issues**: The photo upload endpoint requires a valid JWT token

## Available Solutions

### Solution 1: Use Local Development Server (Recommended)

**Step 1: Update API Configuration**
Change your `lib/core/services/api_service.dart` to use the local server:

```dart
// В api_service.dart, измените baseUrl на:
// Для локальной разработки:
static const String baseUrl = 'http://localhost:3000';
// Для продакшена (закомментируйте):
// static const String baseUrl = 'https://autosalon1.onrender.com';
```

**Step 2: Start the Local Server**
```bash
# В терминале, перейдите в папку backend:
cd lib/backend

# Установите зависимости (если не установлены):
npm install

# Запустите сервер:
npm start
# или
node real_server.js
```

**Step 3: Verify Server is Running**
Test the server endpoints:
```bash
curl http://localhost:3000/api/test
curl http://localhost:3000/api/cars
```

### Solution 2: Fix Remote Server Connection

**If you want to use the remote server:**

1. **Verify Server Status**: Check if `https://autosalon1.onrender.com` is running
2. **Update Deployment**: Make sure the server has the latest code with photo endpoints
3. **Check Authentication**: Ensure you have a valid login token

### Solution 3: Mock Image Upload (for testing)

Create a temporary mock service for development:

```dart
// В lib/core/services/image_upload_service.dart
// Добавьте в начало класса:
static const bool USE_MOCK_UPLOAD = true;

// В методе uploadImage:
Future<String> uploadImage(XFile imageFile, int carId) async {
  if (USE_MOCK_UPLOAD) {
    // Возвращаем mock URL для тестирования
    return 'https://via.placeholder.com/400x300?text=Car+Photo+${carId}';
  }
  // Остальной код остается прежним...
}
```

## Authentication Requirements

The photo upload endpoint **requires authentication**. Make sure:

1. **User is logged in** with valid credentials
2. **Token is stored** in secure storage
3. **Token is not expired**

## Complete Testing Steps

### 1. Server Verification
```bash
# Test if server is running
curl http://localhost:3000/api/test

# Expected response:
# {"message":"✅ AutoSalon Server is working!","timestamp":"...","database":"PostgreSQL","version":"1.0.0"}
```

### 2. Authentication Test
```bash
# Login to get token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@autosalon.com","password":"123456"}'

# Use the token for photo upload
curl -X POST http://localhost:3000/api/cars/1/photos \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "photo=@/path/to/image.jpg"
```

### 3. Flutter App Testing

1. **Update API URL** to localhost
2. **Login first** (get authentication token)
3. **Try uploading** a photo

## Database Migration Requirement

**IMPORTANT**: Before testing photo upload, ensure the database migration has been applied:

```bash
# Apply the fixed migration:
psql -U your_user -d autosalon -f migration_add_car_photos.sql

# Or if you ran the broken version first:
psql -U your_user -d autosalon -f rollback_photos_migration.sql
psql -U your_user -d autosalon -f migration_add_car_photos.sql
```

## Quick Fix - Emergency Workaround

If you need immediate image upload functionality, temporarily disable authentication:

```javascript
// В lib/backend/real_server.js, найдите строку 1436:
app.post('/api/cars/:id/photos', authenticateToken, upload.single('photo'), async (req, res) => {
// Измените на:
// app.post('/api/cars/:id/photos', upload.single('photo'), async (req, res) => {
```

## File Structure Check

Ensure these files exist and are correctly configured:
- ✅ `lib/backend/real_server.js` (has photo endpoints)
- ✅ `lib/core/services/image_upload_service.dart`
- ✅ `lib/core/services/api_service.dart`
- ✅ Database migration applied

## Troubleshooting

**If still getting 404:**
1. Check server logs for errors
2. Verify network connectivity
3. Test with curl directly
4. Check Flutter app network permissions

**If getting 401/403:**
1. Verify user login
2. Check token validity
3. Ensure token is sent in requests

**If getting 500:**
1. Check database connection
2. Verify photos column exists in cars table
3. Check file upload permissions
