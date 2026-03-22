# KidCloud — FastAPI Backend Integration Guide

## 1. Configuration

Open `lib/utils/api_config.dart` and set your FastAPI server URL:

```dart
const String kBaseUrl = 'http://localhost:8000'; // ← change this
```

---

## 2. New Files Added

| File | Purpose |
|---|---|
| `lib/services/api_service.dart` | All HTTP calls (login, signup, logout, children, alerts) |
| `lib/utils/api_config.dart` | Base URL + endpoint constants |
| `lib/utils/session_manager.dart` | JWT token storage via `shared_preferences` |

---

## 3. New Dependencies (`pubspec.yaml`)

```yaml
http: ^1.2.0             # HTTP calls
shared_preferences: ^2.2.3  # Token persistence
```

Run `flutter pub get` after cloning.

---

## 4. FastAPI Endpoints Required

### POST `/auth/signup`
**Request body:**
```json
{ "name": "Alex", "email": "alex@email.com", "phone": "+60123456789", "password": "mypassword" }
```
**Response:**
```json
{ "access_token": "<jwt>", "token_type": "bearer", "user": { "name": "Alex" } }
```

---

### POST `/auth/login`
**Request body:**
```json
{ "email": "alex@email.com", "password": "mypassword" }
```
**Response:**
```json
{ "access_token": "<jwt>", "token_type": "bearer", "user": { "name": "Alex" } }
```

---

### POST `/auth/logout`
**Headers:** `Authorization: Bearer <token>`  
**Response:** `200 OK` (token invalidated server-side)

---

### GET `/children`
**Headers:** `Authorization: Bearer <token>`  
**Response:**
```json
[
  {
    "id": 1,
    "name": "Emma",
    "age": 9,
    "avatar": "👧",
    "color_hex": "4293951688",
    "battery": 78,
    "steps": 4320,
    "status": "At School",
    "last_seen": "2 min ago",
    "school": "SK Damansara",
    "device_id": "KC-A2F3",
    "online": true
  }
]
```

---

### POST `/children`
**Headers:** `Authorization: Bearer <token>`  
**Request body:**
```json
{ "name": "Sara", "age": 6, "avatar": "👧", "color_hex": "...", "school": "SK PJ", "device_id": "KC-C9D2" }
```
**Response:** `201 Created` with the new child object.

---

### GET `/alerts`
**Headers:** `Authorization: Bearer <token>`  
**Response:**
```json
[
  { "id": 1, "type": "SOS", "child": "Emma", "message": "Emergency button pressed", "time": "5 min ago" }
]
```

---

## 5. CORS

Add this to your FastAPI `main.py`:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten for production
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 6. Token Flow

```
User logs in
    → ApiService.login() POSTs credentials
    → FastAPI returns { access_token }
    → SessionManager.saveToken() stores it in SharedPreferences
    → All subsequent API calls include Authorization: Bearer <token>

User logs out
    → ApiService.logout() calls POST /auth/logout
    → SessionManager.clearToken() wipes local storage
    → App navigates back to welcome screen
```
