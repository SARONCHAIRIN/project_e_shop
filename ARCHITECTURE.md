# System Architecture

## E-Commerce Mobile Application Architecture

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                       User Interface Layer                       │
│  (Screens, Widgets, Animations, User Interactions)             │
│                                                                 │
│  ├─ Auth Screens (Login, Register)                             │
│  ├─ Home & Category Screens                                    │
│  ├─ Product Screens (List, Detail)                            │
│  ├─ Cart & Checkout Screens                                   │
│  └─ Profile & Order Screens                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌─────────────────────────────▼────────────────────────────────────┐
│                   State Management Layer                        │
│              (Provider, Business Logic)                         │
│                                                                 │
│  ├─ AuthController (Login, Register, Token Mgmt)               │
│  ├─ CartController (Add, Remove, Update Cart)                  │
│  ├─ OrderController (Create, Track Orders)                     │
│  ├─ ProductController (Browse, Search)                         │
│  └─ UserController (Profile Mgmt)                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌─────────────────────────────▼────────────────────────────────────┐
│                    Repository Pattern Layer                      │
│                  (Data Abstraction)                              │
│                                                                 │
│  ├─ AuthRepository                                              │
│  ├─ ProductRepository                                           │
│  ├─ CartRepository                                              │
│  ├─ OrderRepository                                             │
│  └─ UserRepository                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌─────────────────────────────▼────────────────────────────────────┐
│               Data Sources & Service Layer                      │
│                 (HTTP Client, Local Storage)                     │
│                                                                 │
│  ├─ API Services (HTTP Calls)                                  │
│  │  ├─ AuthService.dart                                        │
│  │  ├─ ProductService.dart                                     │
│  │  ├─ CartService.dart                                        │
│  │  ├─ OrderService.dart                                       │
│  │  └─ UserService.dart                                        │
│  │                                                              │
│  └─ Local Storage Services                                     │
│     ├─ TokenStorage.dart                                       │
│     ├─ UserStorage.dart                                        │
│     └─ CacheStorage.dart                                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌─────────────────────────────▼────────────────────────────────────┐
│               Core & Utilities Layer                            │
│                 (Networking, Security)                          │
│                                                                 │
│  ├─ ApiClient.dart (HTTP/Dio Configuration)                    │
│  ├─ TokenInterceptor (JWT Handling)                            │
│  ├─ ErrorHandler.dart                                          │
│  └─ Constants.dart (URLs, Keys)                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │   Backend API        │
                  │  (REST Endpoints)    │
                  └──────────┬───────────┘
                             │
                ┌────────────┴──────────────┐
                │                          │
                ▼                          ▼
        ┌──────────────────┐      ┌──────────────────┐
        │   API Server     │      │  Third-Party     │
        │  (Node.js/Django)│      │   Services       │
        └────────┬─────────┘      └──────────────────┘
                 │
        ┌────────▼──────────┐
        │  Business Logic   │
        │  (Controllers)    │
        └────────┬──────────┘
                 │
        ┌────────▼──────────┐
        │  Database Layer   │
        │ (PostgreSQL/MySQL)│
        └───────────────────┘
```

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── Presentation/                      # UI Layer
│   ├── controllers/                   # State Management
│   │   ├── auth/                      # Auth controllers
│   │   ├── cart/                      # Cart controller
│   │   ├── order/                     # Order controller
│   │   ├── product/                   # Product controller
│   │   └── user/                      # User controller
│   │
│   └── screen/                        # UI Screens
│       ├── auth/
│       │   ├── login/
│       │   ├── register/
│       │   └── forgot_password/
│       ├── home_main_page/
│       ├── category_main_page/
│       ├── sub_category_screen/
│       ├── product_detail/
│       ├── cart/
│       ├── checkout/
│       ├── order/
│       └── profile_main_page/
│
├── data/                              # Data Layer
│   ├── datasources/                   # API Services
│   │   ├── auth/
│   │   │   └── user_auth_service.dart
│   │   ├── product/
│   │   │   └── product_service.dart
│   │   ├── cart/
│   │   │   └── cart_service.dart
│   │   ├── order/
│   │   │   └── order_service.dart
│   │   └── user/
│   │       └── user_service.dart
│   │
│   ├── models/                        # Data Models
│   │   ├── user/
│   │   ├── product/
│   │   ├── cart/
│   │   └── order/
│   │
│   └── repositories/                  # Repository Pattern
│       ├── auth/
│       ├── product/
│       ├── cart/
│       ├── order/
│       └── user/
│
├── domains/                           # Domain Layer (Business Logic)
│   ├── entities/                      # Domain Models
│   ├── repositories/                  # Repository Interfaces
│   └── use_cases/                     # Use Cases (Future)
│
├── core/                              # Core & Utilities
│   ├── network/
│   │   └── api_client.dart           # HTTP Dio Configuration
│   │
│   ├── storage/
│   │   ├── token_storage.dart        # Token Management
│   │   ├── user_storage.dart         # User Preferences
│   │   └── cache_storage.dart        # Cache Management
│   │
│   ├── constants/
│   │   └── app_constants.dart        # API URLs, Keys, etc.
│   │
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── extensions.dart
│
├── utils/                             # Helper Functions
│   ├── logger.dart
│   ├── error_handler.dart
│   └── navigation.dart
│
└── assets/                            # Static Assets
    ├── images/
    ├── animations/
    └── icons/
```

---

## 🔄 Data Flow Diagram

### User Authentication Flow

```
User Input (Login Form)
        │
        ▼
   Controller
   (AuthController)
        │
        ▼
   Repository
   (AuthRepository)
        │
        ▼
   Service
   (AuthService)
        │
        ▼
   API Client
   (HttpClient)
        │
        ▼
   Backend API
   (POST /login)
        │
        ▼
   Database Query
        │
        ▼
   Response (Token)
        │
        ▼
   Save to Storage
   (TokenStorage)
        │
        ▼
   Update State
   (setState/notify)
        │
        ▼
   Update UI
   (Navigate to Home)
```

### Product Browsing Flow

```
User Navigates to Product List
        │
        ▼
   ProductScreen Widget
        │
        ▼
   Call ProductController.fetchProducts()
        │
        ▼
   ProductRepository.getProducts()
        │
        ▼
   ProductService.fetchFromAPI()
        │
        ▼
   API Client sends GET request
        │
        ▼
   Backend returns Products List
        │
        ▼
   Parse JSON → ProductModel objects
        │
        ▼
   Cache locally via CacheStorage
        │
        ▼
   Update Controller state (notify listeners)
        │
        ▼
   UI rebuilds with Product List
        │
        ▼
   Display GridView with products
```

### Add to Cart Flow

```
User taps "Add to Cart"
        │
        ▼
   Get product details & user ID
        │
        ▼
   Call CartController.addItem()
        │
        ▼
   CartRepository.addItem()
        │
        ▼
   CartService.addToCart()
        │
        ▼
   API call: POST /cart/items
        │
        ▼
   Backend adds item to cart
        │
        ▼
   Returns updated cart data
        │
        ▼
   Update local cart cache
        │
        ▼
   Notify listeners
        │
        ▼
   Update cart badge in AppBar
        │
        ▼
   Show success SnackBar
```

---

## 🔐 Security Architecture

### Authentication & Authorization

```
┌─────────────────────────────────────────────────┐
│          Application Layer                      │
│  User makes request from app                    │
└────────────┬──────────────────────────────────┘
             │
┌────────────▼──────────────────────────────────┐
│      TokenInterceptor                         │
│  ・Add JWT token to headers                   │
│  ・Validate token expiry                      │
│  ・Refresh token if needed                    │
└────────────┬──────────────────────────────────┘
             │
┌────────────▼──────────────────────────────────┐
│      API Request                              │
│  │Headers: {                                  │
│      Authorization: Bearer <JWT_TOKEN>        │
│  │}                                           │
└────────────┬──────────────────────────────────┘
             │
             ▼
         Backend
         │
         ├─ Validate JWT
         ├─ Check user permissions
         ├─ Verify request signature
         └─ Process request
             │
             ▼
         Response with data
```

### Token Management

```
Login Successful
        │
        ▼
Receive JWT Token
        │
        ▼
Save to Secure Storage
(flutter_secure_storage)
        │
        ▼
Add to HTTP Headers
(TokenInterceptor)
        │
        ▼
Every API Call includes Token
        │
        ├─ Token Valid? → Proceed
        │
        └─ Token Expired? 
          │
          ├─ Refresh Token → Get New Token
          │
          └─ Logout & Return to Login
```

---

## 📡 API Architecture

### REST API Endpoints

```
Base URL: https://api.eshop.com/api/v1

Authentication
├─ POST   /auth/register        (Register new user)
├─ POST   /auth/login           (User login)
├─ POST   /auth/refresh-token   (Refresh JWT)
└─ POST   /auth/logout          (Logout)

Products
├─ GET    /products             (List all products)
├─ GET    /products/search      (Search products)
├─ GET    /products/:id         (Get product detail)
├─ GET    /categories           (List categories)
└─ GET    /categories/:id       (Get category products)

Cart
├─ GET    /cart                 (Get user cart)
├─ POST   /cart/items           (Add item to cart)
├─ PUT    /cart/items/:id       (Update cart item)
└─ DELETE /cart/items/:id       (Remove from cart)

Orders
├─ POST   /orders               (Create order)
├─ GET    /orders               (Get order history)
├─ GET    /orders/:id           (Get order details)
└─ GET    /orders/:id/track     (Track order)

Users
├─ GET    /users/me             (Get my profile)
├─ PUT    /users/me             (Update profile)
├─ POST   /users/me/image       (Upload profile image)
└─ PUT    /users/me/password    (Change password)
```

### Request/Response Format

```
Request:
POST /api/v1/auth/login
Content-Type: application/json
Authorization: Bearer <token>

{
  "email": "user@example.com",
  "password": "password123"
}

Response (200 OK):
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGc...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "image": "https://..."
    }
  }
}

Response (400 Error):
{
  "success": false,
  "message": "Invalid credentials",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

---

## 🗄️ Database Schema (Backend)

```sql
Users Table
├─ id (PK)
├─ email (Unique)
├─ password (Hashed)
├─ name
├─ image
├─ phone
├─ created_at
└─ updated_at

Products Table
├─ id (PK)
├─ name
├─ description
├─ main_image
├─ lowest_price
├─ created_at
└─ updated_at

Categories Table
├─ id (PK)
├─ name
├─ description
├─ image
└─ updated_at

Cart Items Table
├─ id (PK)
├─ user_id (FK → Users)
├─ product_id (FK → Products)
├─ quantity
├─ created_at
└─ updated_at

Orders Table
├─ id (PK)
├─ user_id (FK → Users)
├─ total_price
├─ status (pending, confirmed, shipped, delivered)
├─ delivery_address
├─ created_at
└─ updated_at

Order Items Table
├─ id (PK)
├─ order_id (FK → Orders)
├─ product_id (FK → Products)
├─ quantity
├─ unit_price
└─ subtotal
```

---

## 🔌 State Management Architecture

### Provider Pattern Implementation

```dart
// Cart Controller - Example
class CartController extends ChangeNotifier {
  CartRepository _repository;
  CartModel? _cart;
  bool _isLoading = false;
  
  // Getters
  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  
  // Methods
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _cart = await _repository.getCart();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addItem(int productId, int quantity) async {
    try {
      _cart = await _repository.addItem(productId, quantity);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add item');
    }
  }
}

// Usage in Widget
Consumer<CartController>(
  builder: (context, cartController, child) {
    if (cartController.isLoading) {
      return CircularProgressIndicator();
    }
    
    return ListView(
      children: cartController.cart?.items ?? []
        .map((item) => CartItemWidget(item: item))
        .toList() ?? [],
    );
  },
)
```

---

## 🛠️ Technology Stack Details

### Frontend Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Mgmt | Provider | 6.x |
| HTTP Client | Dio | 5.x |
| Local DB | SharedPreferences | 2.x |
| Secure Storage | flutter_secure_storage | 9.x |
| JSON Parsing | json_serializable | 6.x |
| Image Loading | cached_network_image | 3.x |
| Firebase | firebase_core | latest |
| Analytics | firebase_analytics | latest |

### Backend Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 18+ |
| Framework | Express.js | 4.x |
| Language | JavaScript | ES6+ |
| Database | PostgreSQL | 14+ |
| ORM | Sequelize | 6.x |
| Auth | JWT | - |
| File Upload | Multer | 1.x |
| Validation | Joi | 17.x |
| Logging | Winston | 3.x |

---

## 🚀 Deployment Architecture

```
Development Environment
├─ Local Machine
├─ Firebase Emulator
└─ Local Database

Staging Environment
├─ Cloud Server (AWS/Heroku)
├─ Staging Database
└─ Testing APIs

Production Environment
├─ CDN (CloudFlare)
├─ Load Balancer
├─ Application Servers (Multiple)
├─ Database (Replicated)
├─ Cache Layer (Redis)
└─ Backup & Recovery
```

### CI/CD Pipeline

```
Code Push to GitHub
        │
        ▼
GitHub Actions Trigger
        │
        ├─ Build Docker Image
        ├─ Run Tests
        ├─ Code Quality Check
        ├─ Security Scan
        └─ Deploy to Staging
        
If all pass:
        │
        ▼
Manual Approval
        │
        ▼
Deploy to Production
        │
        ▼
Health Checks
        │
        ▼
Monitoring & Alerts
```

---

## 📊 Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| App Load Time | < 2s | - |
| Screen Transition | < 300ms | - |
| API Response Time | < 200ms | - |
| Database Query | < 100ms | - |
| Image Load | < 1s | - |
| App Size | < 50MB | - |
| Memory Usage | < 150MB | - |
| Battery Usage | < 5% per hour | - |

---

## 🔒 Security Measures

1. **Authentication:** JWT Token-based
2. **Encryption:** HTTPS/TLS for all communications
3. **Data Storage:** Encrypted local storage for sensitive data
4. **API Security:** Rate limiting, Input validation
5. **Code Security:** Dependency scanning, SAST tools
6. **Compliance:** GDPR, PCI-DSS ready

---

**Document Version:** 1.0  
**Last Updated:** May 8, 2026  
**Architecture Review:** Quarterly

