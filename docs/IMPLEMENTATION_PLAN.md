# 🚀 NexusOMS - Complete Implementation Plan
**Date**: 2026-02-12  
**Status**: IN PROGRESS (LOCAL ONLY - NO PUSH)

---

## 📋 Implementation Checklist

### ✅ Phase 1: Security & Authentication (CRITICAL)
- [ ] 1.1 JWT Authentication Middleware
- [ ] 1.2 Password Hashing (bcrypt)
- [ ] 1.3 Role-Based Authorization Middleware
- [ ] 1.4 Environment Variables Setup
- [ ] 1.5 Remove all_creds.txt from git history
- [ ] 1.6 Rate Limiting
- [ ] 1.7 Helmet.js Security Headers
- [ ] 1.8 CORS Configuration

### ✅ Phase 2: Backend API Development
- [ ] 2.1 Procurement Gate APIs
- [ ] 2.2 Near Expiry Clearance APIs (Batch Tracking)
- [ ] 2.3 Performance Management System (PMS) APIs
- [ ] 2.4 Logistics Cost Calculator APIs
- [ ] 2.5 Bulk Order Upload APIs
- [ ] 2.6 WebSocket Setup (Real-time Updates)
- [ ] 2.7 AI Credit Insights (Gemini Integration)
- [ ] 2.8 Packaging Inventory APIs

### ✅ Phase 3: Flutter Integration
- [ ] 3.1 Auth Provider Update (JWT Token Storage)
- [ ] 3.2 Role-Based Screen Access
- [ ] 3.3 Route Guards
- [ ] 3.4 API Service Update (Token Headers)
- [ ] 3.5 Auto Logout on 401

### ✅ Phase 4: Database Schema Updates
- [ ] 4.1 User Schema (role, isApprover)
- [ ] 4.2 Procurement Items Collection
- [ ] 4.3 Products Collection (batches array)
- [ ] 4.4 Performance Records Collection
- [ ] 4.5 Packaging Materials Collection
- [ ] 4.6 Packaging Transactions Collection

### ✅ Phase 5: Production Hardening
- [ ] 5.1 Database Indexes
- [ ] 5.2 Error Handling (No Stack Traces)
- [ ] 5.3 File Upload Security
- [ ] 5.4 Remove console.log statements
- [ ] 5.5 PM2 Configuration
- [ ] 5.6 Backup Strategy Documentation

---

## 🔐 Phase 1: Security Implementation

### 1.1 JWT Authentication
**Files**: `backend/middleware/auth.js`, `backend/server.js`

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'Access denied. No token provided.' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token.' });
  }
};

module.exports = { verifyToken };
```

### 1.2 Password Hashing
**Files**: `backend/models/User.js`

```javascript
const bcrypt = require('bcryptjs');

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};
```

### 1.3 Role-Based Authorization
**Files**: `backend/middleware/rbac.js`

```javascript
const allowRoles = (roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Access denied. Insufficient permissions.' });
    }
    next();
  };
};

module.exports = { allowRoles };
```

---

## 📦 Phase 2: Backend APIs

### 2.1 Procurement Gate
**Endpoints**:
- `GET /api/procurement` - Fetch all items
- `GET /api/procurement/:id` - Single item
- `POST /api/procurement` - Create new entry
- `PUT /api/procurement/:id` - Update item
- `DELETE /api/procurement/:id` - Delete item (Admin only)

**Business Rules**:
- Submit to Head: All checks + attachment required
- Final Approval: Only Procurement Head/Admin
- Checks locked after submission

### 2.2 Near Expiry Clearance
**Endpoints**:
- `GET /api/products/expiring?days=90` - Expiring batches
- `POST /api/orders/clearance` - Create clearance order
- `GET /api/orders/clearance/history` - Past clearance orders

**Schema Update**:
```javascript
batches: [{
  batchId: String,
  batchNumber: String,
  mfgDate: String,
  expDate: String,
  quantity: Number,
  weight: String,
  isActive: Boolean
}]
```

### 2.3 Performance Management System
**Endpoints**:
- `GET /api/pms/:userId?month=Feb'26` - User performance
- `GET /api/pms/leaderboard?period=month` - Rankings
- `POST /api/pms/kra/update` - Update KRA
- `POST /api/pms/od-balance/update` - Update OD balance

**Calculation Logic**:
- Unrestricted: (achieved/target) * weightage
- Restricted: min((achieved/target) * weightage, weightage)
- OD Slabs: Based on balance ranges

### 2.4 Logistics Cost Calculator
**Endpoints**:
- `POST /api/logistics/calculate-cost` - Calculate trip cost
- `GET /api/logistics/cost-history` - Past calculations

**Formula**:
```
Total = (Distance × Fuel Rate) + Driver Allowance + Toll + Misc
```

### 2.5 Bulk Order Upload
**Endpoints**:
- `GET /api/orders/bulk/template` - Download Excel template
- `POST /api/orders/bulk` - Upload bulk orders

**Validation**:
- Customer exists
- Product exists
- Quantity > 0

### 2.6 WebSocket (Real-time)
**Events**:
- `order:created` - New order notification
- `order:updated` - Status change notification

**Setup**:
```javascript
const io = require('socket.io')(server, {
  cors: { origin: '*' }
});

io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // Verify JWT
  next();
});
```

### 2.7 AI Credit Insights
**Endpoint**:
- `POST /api/ai/credit-insight` - Get AI recommendation

**Integration**:
```javascript
const { GoogleGenAI } = require('@google/genai');
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
```

### 2.8 Packaging Inventory
**Endpoints**:
- `GET /api/packaging/materials` - All materials
- `GET /api/packaging/transactions` - Transaction history
- `POST /api/packaging/inward` - Receive stock
- `POST /api/packaging/outward` - Consumption log
- `GET /api/packaging/low-stock` - Low stock alerts

---

## 📱 Phase 3: Flutter Integration

### 3.1 Auth Provider Update
**File**: `flutter/lib/providers/nexus_provider.dart`

```dart
Future<void> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/login'),
    body: json.encode({'email': email, 'password': password}),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final token = data['token'];
    await _storage.write(key: 'jwt_token', value: token);
    _token = token;
  }
}
```

### 3.2 Role-Based Screen Access
**File**: `flutter/lib/main.dart`

```dart
Widget _buildNavigationDrawer() {
  final user = Provider.of<NexusProvider>(context).currentUser;
  
  return Drawer(
    child: ListView(
      children: [
        if (user.role != 'Delivery') ...[
          ListTile(title: Text('Dashboard')),
        ],
        if (user.role == 'Admin' || user.role == 'Sales') ...[
          ListTile(title: Text('Order Booking')),
        ],
        // ... role-based menu items
      ],
    ),
  );
}
```

### 3.3 API Service Update
**File**: `flutter/lib/services/api_service.dart`

```dart
Future<http.Response> _makeRequest(String method, String endpoint, {Map<String, dynamic>? body}) async {
  final token = await _storage.read(key: 'jwt_token');
  
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  final response = await http.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: headers,
    body: json.encode(body),
  );
  
  if (response.statusCode == 401) {
    // Auto logout
    await _logout();
  }
  
  return response;
}
```

---

## 🗄️ Phase 4: Database Schema Updates

### 4.1 User Schema
```javascript
{
  role: {
    type: String,
    enum: ['Admin', 'Sales', 'Credit Control', 'Logistics', 'Warehouse', 
           'Procurement', 'Procurement Head', 'Billing', 'Delivery'],
    required: true
  },
  isApprover: {
    type: Boolean,
    default: false
  }
}
```

### 4.2 Procurement Items
```javascript
{
  id: String,
  supplierName: String,
  skuName: String,
  skuCode: String,
  sipChecked: Boolean,
  labelsChecked: Boolean,
  docsChecked: Boolean,
  attachment: String,
  status: { type: String, enum: ['Pending', 'Awaiting Head Approval', 'Approved'] },
  clearedBy: String,
  approvedBy: String
}
```

---

## 🔒 Phase 5: Production Hardening

### 5.1 Environment Variables
```env
PORT=5000
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your-super-secret-key-32-chars-minimum
GEMINI_API_KEY=your-gemini-api-key
NODE_ENV=production
```

### 5.2 Security Checklist
- [x] Passwords hashed with bcrypt
- [x] JWT tokens with 7-day expiry
- [x] Rate limiting on /api/login (5 attempts/15 min)
- [x] Helmet.js for security headers
- [x] CORS restricted to Flutter app URL
- [x] File upload validation (type + size)
- [x] No stack traces in production
- [x] Database indexes on critical fields

### 5.3 Database Indexes
```javascript
// Add to models
customerSchema.index({ id: 1, email: 1 });
orderSchema.index({ id: 1, status: 1, createdAt: -1 });
productSchema.index({ skuCode: 1 });
```

---

## 📊 Progress Tracking

| Phase | Status | Progress | ETA |
|-------|--------|----------|-----|
| Phase 1: Security | 🔄 In Progress | 0% | 2 hours |
| Phase 2: Backend APIs | ⏳ Pending | 0% | 4 hours |
| Phase 3: Flutter Integration | ⏳ Pending | 0% | 2 hours |
| Phase 4: Database Updates | ⏳ Pending | 0% | 1 hour |
| Phase 5: Production Hardening | ⏳ Pending | 0% | 1 hour |

**Total Estimated Time**: 10 hours  
**Start Time**: 2026-02-12 12:37 IST  
**Expected Completion**: 2026-02-12 22:37 IST

---

## 🚨 Critical Notes

1. **NO GIT PUSH** - All changes are LOCAL ONLY
2. **all_creds.txt** - Will be removed from git history using BFG
3. **Mock Data** - Will be replaced with real DB queries
4. **Testing** - Each feature will be tested locally before marking complete
5. **Documentation** - All APIs will be documented in Postman format

---

**Last Updated**: 2026-02-12 12:37 IST  
**Next Review**: After Phase 1 completion
