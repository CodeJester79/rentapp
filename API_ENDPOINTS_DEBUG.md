# 🚀 API Endpoints Debug Information

## 📍 Base URL
- **Production**: `http://platform.rentem.click`

## 🔐 Authentication Endpoints
- **Login**: `POST /auth/login`
- **Register**: `POST /auth/register`
- **Expected Body (Login)**:
  ```json
  {
    "email": "admin@gmail.com",
    "password": "lissa1014"
  }
  ```
- **Expected Body (Register)**:
  ```json
  {
    "username": "John Doe",
    "email": "john@example.com", 
    "password": "password123",
    "role": "customer"
  }
  ```

## 🏠 Property Endpoints
- **Get All Properties**: `GET /properties` (usado por getProperties())
- **Get All Properties Alt**: `GET /properties/properties` (usado por getAllProperties())
- **Get Property Details**: `GET /properties/{property_id}`
- **Create Property**: `POST /properties` (requiere auth)
- **Update Property**: `PUT /properties/{property_id}` (requiere auth)
- **Delete Property**: `DELETE /properties/{property_id}` (requiere auth)

## 📸 Photo Endpoints
- **Upload Photos**: `POST /properties/{property_id}/photos`
- **Get Property Photos**: `GET /properties/{property_id}/photos`
- **Serve Photo**: `GET /properties/photo/{file_id}`
- **Delete Photo**: `DELETE /properties/{property_id}/photos/{photo_id}`

## 👥 User Endpoints
- **Get All Users**: `GET /users/` (admin only)
- **Get User**: `GET /users/{user_id}`
- **Update User**: `PUT /users/{user_id}`
- **Delete User**: `DELETE /users/{user_id}` (admin only)

## 💬 Interaction Endpoints
- **Create Inquiry**: `POST /properties/{property_id}/inquiries`
- **Get Inquiries**: `GET /properties/{property_id}/inquiries`
- **Create Comment**: `POST /properties/{property_id}/comments`
- **Get Comments**: `GET /properties/{property_id}/comments`
- **Add Rating**: `POST /properties/{property_id}/ratings`
- **Get Ratings**: `GET /properties/{property_id}/ratings`

## ❤️ Favorites Endpoints
- **Like Property**: `POST /properties/{property_id}/likes`
- **Get Liked Properties**: `GET /users/{user_id}/liked_properties`

## 🏘️ Agent Endpoints
- **Get All Agents**: `GET /agents/`
- **Get Agent**: `GET /agents/{agent_id}`

## 🔍 Debug URLs to Test Manually
1. **API Docs**: `http://platform.rentem.click/docs`
2. **Basic Health**: `http://platform.rentem.click/`
3. **Properties**: `http://platform.rentem.click/properties`
4. **Properties Alt**: `http://platform.rentem.click/properties/properties`

## 📋 Common Issues to Check
1. **CORS**: The API should allow requests from mobile apps
2. **SSL/TLS**: Using HTTP instead of HTTPS
3. **Network**: Check if the domain is reachable
4. **Firewall**: Check if ports are open
5. **Headers**: Ensure Content-Type and Authorization headers are correct

## 🧪 Testing Commands
```bash
# Test basic connectivity
curl -v http://platform.rentem.click/

# Test properties endpoint
curl -v http://platform.rentem.click/properties

# Test login
curl -X POST http://platform.rentem.click/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gmail.com","password":"lissa1014"}'

# Test register
curl -X POST http://platform.rentem.click/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"Test User","email":"test@example.com","password":"test123","role":"customer"}'
```

## 📱 Flutter App Current Settings
- **AuthService Base URL**: `http://platform.rentem.click`
- **PropertyService Base URL**: `http://platform.rentem.click`
- **Login URL**: `http://platform.rentem.click/auth/login`
- **Register URL**: `http://platform.rentem.click/auth/register`
- **Properties URL**: `http://platform.rentem.click/properties`

## 🐛 Debug Logs to Look For
When you run the app, look for these log patterns:
- `🚀 LOGIN REQUEST:` - Shows login attempt
- `📨 LOGIN RESPONSE:` - Shows login response
- `🚀 REGISTER REQUEST:` - Shows registration attempt  
- `📨 REGISTER RESPONSE:` - Shows registration response
- `🚀 PROPERTIES REQUEST:` - Shows properties request
- `📨 PROPERTIES RESPONSE:` - Shows properties response
- `🧪 TESTING API CONNECTION...` - Shows API connectivity test
- `❌ Error al cargar propiedades:` - Shows API errors
- `💥 Exception in getProperties:` - Shows connection exceptions