# Flutter E-Commerce Payment System - Implementation Guide

**Project Date:** May 2026  
**Status:** In Development  
**Complexity:** High  
**Estimated Timeline:** 3-4 weeks

---

## 📋 PROJECT GOAL

Implement a complete production-ready payment and order management system with:

✅ Cash on Delivery (COD)  
✅ Bakong QR Payment  
✅ Order Tracking System  
✅ Payment Verification  
✅ Payment Failure Handling  
✅ Order Status Management  
✅ Order Detail Flow  
✅ Payment Polling System  
✅ Order Cancellation  

---

## 🔄 ORDER STATUS FLOW

```
┌─────────┐
│ PENDING │ ← Customer places order
└────┬────┘
     │
     ↓
┌──────────┐
│PROCESSING│ ← Shop prepares item
└────┬─────┘
     │
     ↓
┌────────┐
│ SHIPPED│ ← Delivery company picks item
└────┬───┘
     │
     ↓
┌──────────┐
│DELIVERED │ ← Customer receives item
└──────────┘

OR

┌─────────────┐
│  CANCELLED  │ ← Order cancelled
└─────────────┘
```

### Status Definitions

| Status          | Description                                | Actions Available     |
|-----------------|--------------------------------------------|-----------------------|
| **PENDING**     | Customer placed order, awaiting processing | Cancel, View Details  |
| **PROCESSING**  | Shop is preparing the order                | Track, View Details   |
| **SHIPPED**     | Item is on the way                         | Track, View Details   |
| **DELIVERED**   | Customer received item                     | Review, View Details  |
| **CANCELLED**   | Order was cancelled                        | View Details, Reorder |

---

## 💳 PAYMENT FLOW DIAGRAMS

### COD Payment Flow

```
                    ┌──────────────┐
                    │ Cart Screen  │
                    └──────┬───────┘
                           │
                           ↓
                    ┌──────────────┐
                    │   Checkout   │
                    └──────┬───────┘
                           │
                           ↓
            ┌──────────────────────────────┐
            │  Payment Method Screen       │
            │  (COD / Bakong)              │
            └──────────┬───────────────────┘
                       │
                       ↓ (Select COD)
            ┌──────────────────────────┐
            │  Create Order API (COD)  │
            │  POST /api/v1/orders/... │
            └──────────┬───────────────┘
                       │
                       ↓
            ┌──────────────────────────┐
            │ Payment Success Screen   │
            └──────────┬───────────────┘
                       │
                       ↓
            ┌──────────────────────────┐
            │ Order Detail Screen      │
            └──────────────────────────┘
```

### Bakong Payment Flow

```
                    ┌──────────────┐
                    │ Cart Screen  │
                    └──────┬───────┘
                           │
                           ↓
                    ┌──────────────┐
                    │   Checkout   │
                    └──────┬───────┘
                           │
                           ↓
            ┌──────────────────────────────┐
            │  Payment Method Screen       │
            │  (COD / Bakong)              │
            └──────────┬───────────────────┘
                       │
                       ↓ (Select Bakong)
        ┌───────────────────────────────────┐
        │ Create Bakong Order API           │
        │ POST /api/v1/orders/.../bakong    │
        └──────────┬────────────────────────┘
                   │
                   ↓
        ┌───────────────────────────────────┐
        │ Initiate Bakong Payment           │
        │ POST /api/v1/orders/{id}/initiate │
        └──────────┬────────────────────────┘
                   │
                   ↓
        ┌───────────────────────────────────┐
        │ Generate QR Image                 │
        │ POST /api/v1/bakong/get-qr-image  │
        └──────────┬────────────────────────┘
                   │
                   ↓
        ┌───────────────────────────────────┐
        │ Display QR Screen (5-min timer)   │
        │ Poll every 5 seconds              │
        └──────────┬────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ↓                     ↓
    (Success)           (Timeout/Failed)
        │                     │
        ↓                     ↓
    ┌─────────────┐   ┌──────────────┐
    │ Verify API  │   │ Failed Screen│
    └────┬────────┘   └──────────────┘
         │
         ↓
    ┌──────────────────────┐
    │ Success Screen       │
    └────┬─────────────────┘
         │
         ↓
    ┌──────────────────────┐
    │ Order Detail Screen  │
    └──────────────────────┘
```

---

## 🌐 REQUIRED API INTEGRATION

### 1. Create COD Order

```http
POST /api/v1/orders/user/{userId}/from-cart
Content-Type: application/json
Authorization: Bearer {token}

{
  "address_id": 1,
  "payment_method": "COD"
}

Response (201):
{
  "data": {
    "id": 123,
    "user_id": 1,
    "address_id": 1,
    "payment_method": "COD",
    "status": "PENDING",
    "total_price": 150.00,
    "created_at": "2026-05-16T10:00:00Z"
  }
}
```

### 2. Create Bakong Order

```http
POST /api/v1/orders/user/{userId}/from-cart/bakong
Content-Type: application/json
Authorization: Bearer {token}

{
  "address_id": 1,
  "payment_method": "BAKONG"
}

Response (201):
{
  "data": {
    "id": 124,
    "user_id": 1,
    "address_id": 1,
    "payment_method": "BAKONG",
    "status": "PENDING",
    "total_price": 150.00,
    "bakong_qr": "00020101...",
    "bakong_md5": "abc123def456",
    "created_at": "2026-05-16T10:00:00Z"
  }
}
```

### 3. Initiate Bakong Payment

```http
POST /api/v1/orders/{orderId}/bakong/initiate
Content-Type: application/json
Authorization: Bearer {token}

Response (200):
{
  "data": {
    "qr_string": "00020101...",
    "md5": "abc123def456"
  }
}
```

### 4. Generate QR Image

```http
POST /api/v1/bakong/get-qr-image
Content-Type: application/json
Authorization: Bearer {token}

{
  "qr": "00020101...",
  "md5": "abc123def456"
}

Response (200):
{
  "data": {
    "qr_image": "base64_image_string",
    "qr_url": "https://example.com/qr.png"
  }
}
```

### 5. Check Transaction

```http
POST /api/v1/bakong/check-transaction
Content-Type: application/json
Authorization: Bearer {token}

{
  "md5": "abc123def456"
}

Response (200):
{
  "data": {
    "status": "SUCCESS",
    "transaction_id": "txn_123456",
    "amount": 150.00
  }
}
```

### 6. Verify Payment

```http
POST /api/v1/orders/{orderId}/bakong/verify?transactionId={transactionId}
Content-Type: application/json
Authorization: Bearer {token}

Response (200):
{
  "data": {
    "id": 124,
    "status": "PROCESSING",
    "payment_verified": true,
    "verified_at": "2026-05-16T10:05:00Z"
  }
}
```

### 7. Get Orders List

```http
GET /api/v1/orders/user/{userId}?page=1&limit=10
Authorization: Bearer {token}

Response (200):
{
  "data": [
    {
      "id": 124,
      "status": "PROCESSING",
      "total_price": 150.00,
      "created_at": "2026-05-16T10:00:00Z",
      "items_count": 3
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 15
  }
}
```

### 8. Get Order Detail

```http
GET /api/v1/orders/{id}
Authorization: Bearer {token}

Response (200):
{
  "data": {
    "id": 124,
    "status": "PROCESSING",
    "payment_method": "BAKONG",
    "total_price": 150.00,
    "address": {
      "id": 1,
      "address_line1": "123 Main St",
      "city": "Phnom Penh",
      "country": "Cambodia",
      "zip_code": "10110"
    },
    "items": [
      {
        "id": 1,
        "product_id": 10,
        "name": "Product Name",
        "price": 50.00,
        "quantity": 3,
        "image": "https://..."
      }
    ],
    "created_at": "2026-05-16T10:00:00Z"
  }
}
```

### 9. Cancel Order

```http
POST /api/v1/orders/{id}/user/{userId}/cancel
Authorization: Bearer {token}

Response (200):
{
  "data": {
    "id": 124,
    "status": "CANCELLED",
    "cancelled_at": "2026-05-16T10:10:00Z"
  }
}
```

### 10. Update Order Status

```http
PATCH /api/v1/orders/{id}/status?status=PROCESSING
Authorization: Bearer {token}

Response (200):
{
  "data": {
    "id": 124,
    "status": "PROCESSING",
    "updated_at": "2026-05-16T10:15:00Z"
  }
}
```

---

## 📱 REQUIRED SCREENS

| Screen                        | Description                       | Status    |
|-------------------------------|-----------------------------------|-----------|
| **Payment Method Screen**     | Choose COD or Bakong              | ❌ To Do   |
| **Bakong QR Screen**          | Display QR code with timer        | ❌ To Do   |
| **Payment Processing Screen** | Loading state during verification | ❌ To Do   |
| **Payment Success Screen**    | Order created successfully        | ❌ To Do   |
| **Payment Failed Screen**     | Payment failed, retry options     | ❌ To Do   |
| **Order History Screen**      | List all user orders              | ❌ To Do   |
| **Order Detail Screen**       | View order details & items        | ❌ To Do   |

---

## 📂 PROJECT STRUCTURE

```
lib/
├── Presentation/
│   ├── screen/
│   │   ├── payment/
│   │   │   ├── payment_method_screen.dart
│   │   │   ├── bakong_qr_screen.dart
│   │   │   ├── payment_processing_screen.dart
│   │   │   ├── payment_success_screen.dart
│   │   │   └── payment_failed_screen.dart
│   │   └── orders/
│   │       ├── order_history_screen.dart
│   │       ├── order_detail_screen.dart
│   │       └── order_tracking_screen.dart
│   ├── widgets/
│   │   ├── payment/
│   │   │   ├── payment_method_tile.dart
│   │   │   ├── qr_image_widget.dart
│   │   │   ├── payment_timer_widget.dart
│   │   │   └── order_status_badge.dart
│   │   └── order/
│   │       ├── order_card.dart
│   │       ├── order_item_card.dart
│   │       └── order_status_timeline.dart
│   └── controllers/
│       ├── payment_controller.dart
│       └── order_controller.dart
├── data/
│   ├── datasources/
│   │   ├── payment_service.dart
│   │   └── order_service.dart
│   ├── models/
│   │   ├── order/
│   │   │   ├── order_model.dart
│   │   │   ├── order_item_model.dart
│   │   │   └── order_status_enum.dart
│   │   └── payment/
│   │       ├── payment_method_enum.dart
│   │       └── bakong_payment_model.dart
│   └── repositories/
│       ├── payment_repository.dart
│       └── order_repository.dart
└── core/
    ├── constants/
    │   └── payment_constants.dart
    └── utils/
        └── payment_utils.dart
```

---

## ✅ TASK BREAKDOWN (15 Tasks)

### PHASE 1: Setup & Data Models

#### TASK 1: Setup Project Structure ⏱️ 1 day

**Objective:** Create folder structure and organize files

**Deliverables:**
- [ ] Create all required directories
- [ ] Create barrel files for exports
- [ ] Setup constants file

**Acceptance Criteria:**
- Folder structure follows Clean Architecture
- All imports work correctly
- No unused files

---

#### TASK 2: Create Order & Payment Models ⏱️ 1 day — IMPLEMENTED

Objective: implement production-ready, null-safe models for orders and payments and provide conversion helpers used by API services and UI.

Files created/updated in this workspace (paths under `lib/`):
- `data/models/order/order_status_enum.dart` — OrderStatus enum + helpers
- `data/models/order/order_model.dart` — OrderModel with items, status and JSON (fromJson/toJson)
- `data/models/order/order_item_model.dart` — OrderItemModel with JSON helpers
- `data/models/payment/payment_method_enum.dart` — PaymentMethod enum + helpers
- `data/models/payment/bakong_payment_model.dart` — BakongPaymentModel (QR/md5/urls)

Implementation details:
- All models are null-safe and defensive when parsing API responses.
- Enums expose conversion helpers to map API strings (e.g. `"PROCESSING"`) to enum values and back.
- `OrderModel` parses nested `items` arrays into `OrderItemModel` objects and includes `toJson()` for request payloads.

Code examples (usage):

1) Converting status string from API to enum:

```dart
final status = OrderStatusExtension.fromString(apiJson['status']);
// status is OrderStatus.processing, etc.
```

2) Parsing an order payload returned from `GET /api/v1/orders/{id}`:

```dart
final order = OrderModel.fromJson(responseData['data']);
print(order.totalPrice);
print(order.items.length);
```

3) Creating a Bakong payload from model:

```dart
final bakong = BakongPaymentModel(qrString: qr, md5: md5);
final body = bakong.toJson();
```

Acceptance Criteria (completed):
- Models include `fromJson()` and `toJson()` methods and handle missing fields safely.
- Enums support string conversion (API ↔ enum) via helper functions.
- Files created live in `lib/data/models/...` and are ready for repository/service integration.

Next steps (TASK 3): implement API services using Dio (`payment_service.dart`, `order_service.dart`) and wire these models into repository implementations.

---

#### TASK 3: Create API Services ⏱️ 1 day — IMPLEMENTED

**Objective:** Implement production-ready API service layer using Dio with proper error handling and null safety.

**Files created/updated in this workspace (paths under `lib/`):
- `data/datasources/payment_service.dart` — Bakong payment API calls
- `data/datasources/order_service.dart` — Order creation, retrieval, cancellation, status updates

**Installation Required:**
Before using these services, run:
```bash
flutter pub get
```
This will install `dio: ^5.3.0` (added to pubspec.yaml).

**PaymentService Methods (4 total):**

1. `initiateBakongPayment()` — POST /api/v1/orders/{orderId}/bakong/initiate
   - Returns: qr_string, md5
   
2. `generateQRImage()` — POST /api/v1/bakong/get-qr-image
   - Params: qr, md5
   - Returns: qr_image (base64), qr_url
   
3. `checkTransaction()` — POST /api/v1/bakong/check-transaction
   - Params: md5
   - Returns: status, transaction_id, amount
   
4. `verifyPayment()` — POST /api/v1/orders/{orderId}/bakong/verify
   - Params: transactionId
   - Returns: id, status, payment_verified, verified_at

**OrderService Methods (6 total):**

1. `createCODOrder()` — POST /api/v1/orders/user/{userId}/from-cart
   - Params: userId, addressId
   - Returns: Order object (COD)
   
2. `createBakongOrder()` — POST /api/v1/orders/user/{userId}/from-cart/bakong
   - Params: userId, addressId
   - Returns: Order object (Bakong with QR)
   
3. `getOrders()` — GET /api/v1/orders/user/{userId}
   - Params: userId, page, limit
   - Returns: { data: [...], pagination: {...} }
   
4. `getOrderDetail()` — GET /api/v1/orders/{id}
   - Params: orderId
   - Returns: Full order with items, address, payment info
   
5. `cancelOrder()` — POST /api/v1/orders/{id}/user/{userId}/cancel
   - Params: orderId, userId
   - Returns: Cancelled order object
   
6. `updateOrderStatus()` — PATCH /api/v1/orders/{id}/status
   - Params: orderId, status (PENDING|PROCESSING|SHIPPED|DELIVERED|CANCELLED)
   - Returns: Updated order object

**Implementation Details:**
- Both services use Dio HttpClient initialized in constructor (can be injected for testing).
- All methods require bearer token authentication passed as parameter.
- Error handling wraps DioExceptions and timeouts with meaningful user-friendly messages.
- Null safety strictly enforced: `required` parameters, optional query params handled safely.
- baseUrl set to `https://e-shop-1-m034.onrender.com/api/v1`.
- All responses validated for 200/201 status before parsing data.
- Debug logging via `debugPrint()` shows method entry, success, and errors.

**Code Examples:**

1) Create a COD order:
```dart
final service = OrderService();
final order = await service.createCODOrder(
  userId: 1,
  addressId: 5,
  token: 'Bearer token...',
);
print('Order created: ${order['id']}');
```

2) Initiate and poll Bakong payment:
```dart
final paymentService = PaymentService();
final qrData = await paymentService.initiateBakongPayment(
  orderId: 123,
  token: 'Bearer token...',
);
// qrData contains: { qr_string, md5 }

// Poll every 5 seconds
Timer.periodic(Duration(seconds: 5), (timer) async {
  final transaction = await paymentService.checkTransaction(
    md5: qrData['md5'],
    token: 'Bearer token...',
  );
  if (transaction['status'] == 'SUCCESS') {
    timer.cancel();
    await paymentService.verifyPayment(
      orderId: 123,
      transactionId: transaction['transaction_id'],
      token: 'Bearer token...',
    );
  }
});
```

3) Fetch and cancel an order:
```dart
final service = OrderService();
final order = await service.getOrderDetail(
  orderId: 123,
  token: 'Bearer token...',
);

if (order['status'] == 'PENDING') {
  await service.cancelOrder(
    orderId: 123,
    userId: 1,
    token: 'Bearer token...',
  );
}
```

**Acceptance Criteria (completed):**
- All 10 API methods implemented and documented.
- Services use Dio for HTTP calls.
- Proper error handling with timeout detection.
- Null safety enforced throughout.
- Dio added to pubspec.yaml.
- Ready to be wrapped by repositories in Task 4.

**Next Steps (TASK 4):** Create `PaymentRepository` and `OrderRepository` wrappers that handle business logic (retry, caching, state management) and are injected into controllers/providers.

---

#### TASK 4: Create Repositories ⏱️ 1 day — IMPLEMENTED

**Objective:** Implement repository layer that wraps services with business logic, error handling, retries, and state management for dependency injection into controllers/providers.

**Files created/updated in this workspace (paths under `lib/`):
- `data/repositories/payment_repository.dart` — Payment business logic layer
- `data/repositories/order_repository.dart` — Order business logic layer

**PaymentRepository Methods (5 total):**

1. `initiateBakongPayment()` — POST /api/v1/orders/{orderId}/bakong/initiate
   - Params: orderId, token, retries (default 3 with exponential backoff)
   - Returns: BakongPaymentModel with qr_string, md5
   - Feature: **Automatic retries with exponential backoff (2s, 4s, 6s)**
   
2. `generateQRImage()` — POST /api/v1/bakong/get-qr-image
   - Params: qr, md5, token
   - Returns: BakongPaymentModel with qr_image (base64), qr_url
   - Feature: Response parsing, error logging
   
3. `checkTransaction()` — POST /api/v1/bakong/check-transaction
   - Params: md5, token
   - Returns: Map<String, dynamic> with status, transaction_id, amount
   - Feature: Status parsing and logging
   
4. `verifyPayment()` — POST /api/v1/orders/{orderId}/bakong/verify
   - Params: orderId, transactionId, token
   - Returns: Map<String, dynamic> with verified order data
   - Feature: Payment verification with logging
   
5. `checkTransactionWithRetry()` ⭐ **NEW** — Polling helper
   - Params: md5, token, maxRetries (default 12), initialDelay (default 5s)
   - Returns: Map when status == 'SUCCESS'
   - Feature: **Linear retry polling with delays (5s, 10s, 15s... up to 12 attempts)**
   - Use case: Wait for payment confirmation with automatic retries

**OrderRepository Methods (6 total):**

1. `createCODOrder()` — POST /api/v1/orders/user/{userId}/from-cart
   - Params: userId, addressId, token
   - Returns: OrderModel (COD order)
   - Feature: Error logging, response parsing
   
2. `createBakongOrder()` — POST /api/v1/orders/user/{userId}/from-cart/bakong
   - Params: userId, addressId, token
   - Returns: OrderModel (Bakong order with QR)
   - Feature: Error logging, response parsing
   
3. `getOrders()` — GET /api/v1/orders/user/{userId}
   - Params: userId, token, page (default 1), limit (default 10)
   - Returns: Record with (orders: List<OrderModel>, pagination: Map)
   - Feature: Pagination parsing, type-safe return tuple
   
4. `getOrderDetail()` — GET /api/v1/orders/{id}
   - Params: orderId, token
   - Returns: OrderModel with full details (items, address, payment info)
   - Feature: Nested object parsing, item count logging
   
5. `cancelOrder()` — POST /api/v1/orders/{id}/user/{userId}/cancel
   - Params: orderId, userId, token
   - Returns: OrderModel (cancelled)
   - Feature: **Pre-check that order is PENDING before attempting cancel**
   - Throws: Exception if order status != PENDING
   
6. `updateOrderStatus()` — PATCH /api/v1/orders/{id}/status
   - Params: orderId, status, token
   - Returns: OrderModel (updated)
   - Feature: **Status validation** (only allows: PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
   - Throws: Exception if invalid status

**Bonus Method in OrderRepository:**

7. `loadAllOrders()` ⭐ **NEW** — Infinite loader
   - Params: userId, token
   - Returns: List<OrderModel> with ALL user orders (auto-pagination)
   - Feature: **Automatic pagination handling** (loads all pages sequentially)
   - Use case: Load complete order history without manual page management

**Implementation Details:**
- Both repositories accept optional injected services in constructor (for testing/mocking).
- All methods use debug logging to track execution flow.
- Null safety strictly enforced: defensive parsing with `??` on all API responses.
- Error handling: All exceptions logged and re-thrown (no silent failures).
- PaymentRepository includes retry logic with exponential backoff for network resilience.
- OrderRepository includes business logic validation (status checks, enum comparison).
- Both repositories use the models created in Task 2 (OrderModel, BakongPaymentModel).

**Code Examples:**

1) Create and immediately verify COD order:
```dart
final repo = OrderRepository();
final order = await repo.createCODOrder(
  userId: 1,
  addressId: 5,
  token: 'Bearer token...',
);
print('Order #${order.id} created: ${order.totalPrice}');
```

2) Initiate Bakong with automatic polling:
```dart
final paymentRepo = PaymentRepository();
final qrData = await paymentRepo.initiateBakongPayment(
  orderId: 123,
  token: 'Bearer token...',
);

// Auto-poll every 5s for up to 60s with retries
final transaction = await paymentRepo.checkTransactionWithRetry(
  md5: qrData.md5,
  token: 'Bearer token...',
  maxRetries: 12,
  initialDelay: 5,
);

if (transaction['status'] == 'SUCCESS') {
  await paymentRepo.verifyPayment(
    orderId: 123,
    transactionId: transaction['transaction_id'],
    token: 'Bearer token...',
  );
}
```

3) Load orders with pagination:
```dart
final repo = OrderRepository();
final result = await repo.getOrders(
  userId: 1,
  token: 'Bearer token...',
  page: 1,
  limit: 10,
);
print('Orders: ${result.orders.length}');
print('Total: ${result.pagination['total']}');

// Or load ALL orders automatically:
final allOrders = await repo.loadAllOrders(
  userId: 1,
  token: 'Bearer token...',
);
print('Total orders: ${allOrders.length}');
```

4) Cancel order with validation:
```dart
try {
  final repo = OrderRepository();
  final cancelled = await repo.cancelOrder(
    orderId: 123,
    userId: 1,
    token: 'Bearer token...',
  );
  print('Order cancelled: #${cancelled.id}');
} catch (e) {
  // Will throw if order is not PENDING
  print('Cannot cancel: $e');
}
```

**Acceptance Criteria (completed):**
- Two repository files created: payment_repository.dart, order_repository.dart
- All 11 methods (5 payment + 6 order) implemented with full documentation.
- Services wrapped with business logic, error handling, and retry mechanisms.
- All methods are async with proper null safety.
- Debug logging throughout for troubleshooting.
- Repositories ready to be injected into controllers/providers in Task 5.
- No compile errors; type-safe with strict null checking.

**Next Steps (TASK 5):** Create reusable widgets (payment_method_tile, order_status_badge, etc.) for UI components used in payment and order screens.

---

### PHASE 2: UI & Screens

#### TASK 5: Create Reusable Widgets ⏱️ 2 days

**Objective:** Build reusable payment and order widgets

**Widgets to Create:**

1. **payment_method_tile.dart** - Choose payment method
   ```dart
   - Display icon, title, description
   - Show selected state
   - Tap to select
   ```

2. **order_status_badge.dart** - Show order status
   ```dart
   - Color-coded status display
   - Status text
   - Supports all statuses
   ```

3. **qr_image_widget.dart** - Display QR code
   ```dart
   - Show QR image
   - Download button
   - Share button
   ```

4. **payment_timer_widget.dart** - Countdown timer
   ```dart
   - Show remaining time
   - Color changes on warning
   - Auto-cancel on timeout
   ```

5. **order_card.dart** - List order item
   ```dart
   - Order ID
   - Status badge
   - Total price
   - Date
   - Tap to view detail
   ```

6. **order_item_card.dart** - Individual order item
   ```dart
   - Product image
   - Name & price
   - Quantity
   ```

7. **order_status_timeline.dart** - Visual status progress
   ```dart
   - Timeline of statuses
   - Current status highlighted
   - Completed steps marked
   ```

**Acceptance Criteria:**
- All widgets are reusable
- Proper null safety
- Consistent styling
- Support state changes

---

#### TASK 6: Payment Method Screen ⏱️ 1.5 days

**File:** `payment_method_screen.dart`

**Features:**
- Display payment method options
- Select COD or Bakong
- Address display
- Order total summary
- Continue button with validation

**UI Elements:**
```
┌────────────────────────────┐
│ Payment Method             │
├────────────────────────────┤
│                            │
│ ○ Cash on Delivery (COD)   │
│   Pay when item arrives    │
│                            │
│ ○ Bakong QR               │
│   Scan and pay instantly   │
│                            │
├────────────────────────────┤
│ Order Summary              │
│ Total: $150.00             │
├────────────────────────────┤
│    [Continue Button]       │
└────────────────────────────┘
```

**Logic:**
- [ ] Load address data
- [ ] Show order total
- [ ] Validate selection
- [ ] Navigate to appropriate flow

**Acceptance Criteria:**
- Selection works smoothly
- Data persists correctly
- Validation prevents empty submit

---

#### TASK 7: COD Payment Flow ⏱️ 1 day

**File:** `payment_processing_screen.dart` (shared with Bakong)

**Features:**
- Call createCODOrder API
- Show loading state
- Handle success/error
- Navigate to success screen

**Code Structure:**
```dart
1. Get addressId from previous screen
2. Call PaymentRepository.createCODOrder()
3. Show loading spinner
4. On success → NavigateTo(PaymentSuccessScreen)
5. On error → Show error dialog with retry
```

**Acceptance Criteria:**
- API call successful
- Loading state shows
- Success navigation works
- Error handling implemented

---

#### TASK 8: Bakong QR Display Screen ⏱️ 2 days

**File:** `bakong_qr_screen.dart`

**Features:**
- Display QR image
- Show countdown timer (5 minutes)
- Poll payment status every 5 seconds
- Show payment waiting UI
- Cancel button

**UI Elements:**
```
┌────────────────────────────┐
│ Scan QR Code              │
│ ⏱ 4:59 remaining          │
├────────────────────────────┤
│                            │
│         ┌──────────┐       │
│         │ QR Image │       │
│         │ Display  │       │
│         └──────────┘       │
│                            │
│  "Waiting for payment..."  │
│                            │
├────────────────────────────┤
│      [Cancel Order]        │
└────────────────────────────┘
```

**Logic:**
```dart
1. Start 5-minute timer
2. Start polling every 5 seconds
3. Call checkTransaction() API
4. If success → Verify payment
5. If timeout → Show failed screen
6. If cancelled → Delete order
```

**Polling Logic:**
```dart
Timer.periodic(Duration(seconds: 5), (timer) async {
  final result = await checkTransaction();
  if (result.status == 'SUCCESS') {
    timer.cancel();
    await verifyPayment();
    navigateToSuccess();
  }
});
```

**Acceptance Criteria:**
- Timer counts down correctly
- Polling works every 5 seconds
- Success detected and handled
- Timeout handled properly
- Cancel order works

---

#### TASK 9: Payment Success Screen ⏱️ 1 day

**File:** `payment_success_screen.dart`

**Features:**
- Show success animation
- Display order details
- Order number, date, total
- View Order button
- Back to Home button

**UI Elements:**
```
┌────────────────────────────┐
│        ✓ Successful        │
│                            │
│  Order #12345 Created      │
│  Date: May 16, 2026        │
│  Total: $150.00            │
│                            │
│  Payment Method: BAKONG    │
│  Status: PROCESSING        │
├────────────────────────────┤
│   [View Order Details]     │
│   [Back to Home]           │
└────────────────────────────┘
```

**Logic:**
- [ ] Display order from API
- [ ] Show success animation
- [ ] Handle permissions

**Acceptance Criteria:**
- Order details display correctly
- Navigation buttons work
- Animation plays once

---

#### TASK 10: Payment Failed Screen ⏱️ 1 day

**File:** `payment_failed_screen.dart`

**Features:**
- Show failure message
- Display reason
- Retry payment button
- Cancel order button
- Back to cart button

**UI Elements:**
```
┌────────────────────────────┐
│        ✗ Payment Failed    │
│                            │
│  Transaction Timed Out     │
│  Please try again          │
│                            │
├────────────────────────────┤
│  [Retry Payment]           │
│  [Cancel Order]            │
│  [Back to Cart]            │
└────────────────────────────┘
```

**Logic:**
- [ ] Retry payment (initiate new payment)
- [ ] Cancel order (call API)
- [ ] Clear cart on cancel

**Acceptance Criteria:**
- Retry initiates new payment
- Cancel deletes order
- Navigation works correctly

---

### PHASE 3: Order Management

#### TASK 11: Order History Screen ⏱️ 1.5 days

**File:** `order_history_screen.dart`

**Features:**
- Display paginated order list
- Order status badge
- Order total
- Order date
- Tap to view detail
- Pull to refresh
- Loading pagination

**UI Elements:**
```
┌────────────────────────────┐
│ Order History              │
├────────────────────────────┤
│ ┌────────────────────────┐ │
│ │ Order #12345           │ │
│ │ [PROCESSING] 25 May    │ │
│ │ Total: $150.00         │ │
│ │ 3 items → →            │ │
│ └────────────────────────┘ │
│                            │
│ ┌────────────────────────┐ │
│ │ Order #12344           │ │
│ │ [DELIVERED] 20 May     │ │
│ │ Total: $85.50          │ │
│ │ 2 items → →            │ │
│ └────────────────────────┘ │
│                            │
│   [Load More Orders...]    │
└────────────────────────────┘
```

**Logic:**
- [ ] Load first 10 orders
- [ ] Show pagination button
- [ ] Load more on demand
- [ ] Pull to refresh

**Acceptance Criteria:**
- Orders load correctly
- Pagination works
- Status badges display
- Refresh updates list

---

#### TASK 12: Order Detail Screen ⏱️ 1.5 days

**File:** `order_detail_screen.dart`

**Features:**
- Display order information
- Product list with images
- Delivery address
- Payment method
- Order status timeline
- Order actions (cancel, track)

**UI Elements:**
```
┌────────────────────────────┐
│ Order #12345               │
├────────────────────────────┤
│ Status Timeline:           │
│ ✓ PENDING → PROCESSING →   │
│ ○ SHIPPED → DELIVERED      │
├────────────────────────────┤
│ Items (3):                 │
│ [Img] Product 1 x2 $50.00  │
│ [Img] Product 2 x1 $85.50  │
│ [Img] Product 3 x1 $15.00  │
├────────────────────────────┤
│ Shipping Address:          │
│ 123 Main St                │
│ Phnom Penh 10110           │
│ Cambodia                   │
├────────────────────────────┤
│ Payment:                   │
│ Method: BAKONG QR          │
│ Date: 25 May 2026          │
│ Total: $150.00             │
├────────────────────────────┤
│    [Cancel Order]          │
│    [Track Shipment]        │
└────────────────────────────┘
```

**Logic:**
- [ ] Fetch order details
- [ ] Display all items
- [ ] Show address
- [ ] Display status timeline
- [ ] Enable cancel if PENDING
- [ ] Track shipment integration

**Acceptance Criteria:**
- All data displays correctly
- Cancel button works only for PENDING
- Timeline shows progression
- Navigation works

---

#### TASK 13: Order Cancellation ⏱️ 1 day

**Implementation Points:**
- Can only cancel PENDING orders
- Confirmation dialog required
- Call cancel API
- Update UI
- Show confirmation

**Code:**
```dart
Future<void> cancelOrder(int orderId) async {
  // 1. Show confirmation dialog
  // 2. Call OrderRepository.cancelOrder()
  // 3. Update order status
  // 4. Show success message
  // 5. Navigate back
}
```

**Acceptance Criteria:**
- Dialog confirms action
- API call executes
- UI updates immediately
- Error handling implemented

---

### PHASE 4: Integration & Enhancements

#### TASK 14: Create Payment Controllers ⏱️ 1.5 days

**Files:**
- `payment_controller.dart` (Provider)
- `order_controller.dart` (Provider)

**PaymentController State:**
```dart
- selectedPaymentMethod
- isLoading
- error
- orderId

Methods:
- selectPaymentMethod()
- initiateBakongPayment()
- verifyPayment()
- resetState()
```

**OrderController State:**
```dart
- orders
- selectedOrder
- isLoading
- error
- currentPage

Methods:
- fetchOrders()
- fetchOrderDetail()
- cancelOrder()
- loadMore()
```

**Acceptance Criteria:**
- Controllers manage state properly
- Errors are caught
- Loading states work
- Reset works

---

#### TASK 15: UX Enhancements & Testing ⏱️ 2 days

**Enhancements:**

1. **Prevent Double Click**
   ```dart
   bool _isProcessing = false;
   
   onPressed: _isProcessing ? null : () async {
     if (_isProcessing) return;
     _isProcessing = true;
     // API call
     _isProcessing = false;
   }
   ```

2. **Timeout Handling**
   ```dart
   Future<T> withTimeout<T>(
     Future<T> future,
     Duration timeout,
   ) {
     return future.timeout(timeout);
   }
   ```

3. **Error Recovery**
   ```dart
   - Show error dialog
   - Provide retry button
   - Log error details
   - Clear sensitive data on logout
   ```

4. **Loading States**
   ```dart
   - Skeleton loading
   - Progress indicators
   - Shimmer effects
   - Disable user interaction
   ```

5. **Animations**
   ```dart
   - Success animation
   - Error shake animation
   - Transition animations
   - Status change animations
   ```

**Acceptance Criteria:**
- All error cases handled
- UX is smooth
- No dead states
- Performance optimized

---

## 🏗️ TECHNICAL REQUIREMENTS

### Architecture
- ✅ Clean Architecture layers
- ✅ Repository Pattern
- ✅ Dependency Injection
- ✅ Separation of concerns

### Technology Stack
- Framework: Flutter (latest stable)
- State Management: Provider / Riverpod
- HTTP Client: Dio
- Local Storage: shared_preferences / hive

### Code Quality
- ✅ Null Safety enforced
- ✅ Linting rules applied
- ✅ No dead code
- ✅ Consistent naming conventions

### Error Handling
- ✅ Try-catch all API calls
- ✅ User-friendly error messages
- ✅ Logging for debugging
- ✅ Fallback UI states

### Performance
- ✅ Lazy loading
- ✅ Image caching
- ✅ API response caching
- ✅ Efficient state updates

---

## 🎯 EXPECTED FINAL FLOW

```
User Journey:
┌─────────────┐
│ Cart Screen │
└──────┬──────┘
       │ "Proceed to Checkout"
       ↓
┌──────────────────────┐
│ Checkout Screen      │
│ - Review items       │
│ - Select address     │
└──────┬───────────────┘
       │ "Continue to Payment"
       ↓
┌──────────────────────┐
│ Payment Method       │
│ - Choose COD/Bakong  │
└──────┬───────────────┘
       │
       ├─── COD Path ──────┐
       │                   │
       ↓                   ↓
  (Create Order)    ┌──────────────┐
   (Load State)     │ Processing   │
                    │ Screen       │
                    └──────┬───────┘
                           │
                    ┌─────────────────────┐
                    │ Success Screen      │
                    │ Show Order Details  │
                    └─────────┬───────────┘
                              │
                    ┌─────────────────────┐
                    │ Order Details       │
                    │ - Status timeline   │
                    │ - Products          │
                    │ - Address           │
                    │ - Actions           │
                    └─────────────────────┘
       │
       ├─── Bakong Path ──┐
       │                  │
       ↓                  ↓
  (Create Order)   ┌──────────────────┐
  (Get QR)         │ QR Code Screen   │
  (Start Poll)     │ - Timer 5 min    │
  (Check Trans)    │ - Poll every 5s  │
  (On Success:)    │ - Cancel option  │
  - Verify API     └──────┬───────────┘
  - Navigate               │
                    ┌─────────────────┐
                    │ Success Screen  │
                    └────────┬────────┘
                             │
                    ┌────────────────────┐
                    │ Order Details      │
                    └────────────────────┘

Post-Order:
┌──────────────────────┐
│ Order History Access │
├──────────────────────┤
│ - View all orders    │
│ - Paginated list     │
│ - Track status       │
│ - Cancel if PENDING  │
│ - Pull to refresh    │
└──────────────────────┘
```

---

## 📊 TIMELINE ESTIMATE

| Phase                    | Duration      | Tasks        |
|--------------------------|---------------|--------------|
| **Phase 1: Setup**       | 4 days        | Tasks 1-4    |
| **Phase 2: UI & Flows**  | 9 days        | Tasks 5-10   |
| **Phase 3: Orders**      | 4 days        | Tasks 11-13  |
| **Phase 4: Integration** | 3.5 days      | Tasks 14-15  |
| **Total**                | **3-4 weeks** | **15 Tasks** |

---

## 🚀 DEPLOYMENT CHECKLIST

Before deploying to production:

- [ ] All APIs tested with real backend
- [ ] Payment flows tested (COD & Bakong)
- [ ] Error handling verified
- [ ] Loading states completed
- [ ] Animations smooth
- [ ] Performance optimized
- [ ] Code reviewed
- [ ] Unit tests written
- [ ] Integration tests passed
- [ ] Security audit completed
- [ ] Analytics integrated
- [ ] Documentation updated

---

## 📝 NOTES

### Important Considerations

1. **Payment Security**
   - Never store sensitive payment data locally
   - Always use HTTPS
   - Validate on backend
   - Implement rate limiting

2. **User Experience**
   - Show clear loading states
   - Provide retry mechanisms
   - Handle edge cases gracefully
   - Confirm destructive actions (cancel)

3. **Testing**
   - Test with real payment processor
   - Test slow network conditions
   - Test timeout scenarios
   - Test payment failures

4. **Monitoring**
   - Log payment events
   - Track user abandonment
   - Monitor API performance
   - Alert on payment failures

---

## 📞 Support & Debugging

### Common Issues

**QR Code Not Displaying:**
- Check image format
- Verify API response
- Check network connectivity

**Payment Polling Timeout:**
- Extend timeout duration
- Check API response time
- Verify transaction status API

**Order Not Created:**
- Verify address_id exists
- Check user authentication
- Verify cart has items

---

**Last Updated:** May 16, 2026  
**Status:** Ready for Development  
**Next Step:** Start TASK 1 - Setup Project Structure

