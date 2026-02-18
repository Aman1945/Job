# 🚀 NexusOMS - Complete End-to-End Application Guide

## 📋 Table of Contents
1. [System Architecture](#system-architecture)
2. [Backend Setup & Testing](#backend-setup--testing)
3. [Flutter App Setup & Testing](#flutter-app-setup--testing)
4. [Complete User Journey](#complete-user-journey)
5. [Screen-by-Screen Testing](#screen-by-screen-testing)
6. [Backend API Testing](#backend-api-testing)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     NEXUSOMS ECOSYSTEM                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   FLUTTER    │◄───────►│   BACKEND    │                 │
│  │   MOBILE APP │  HTTP   │   NODE.JS    │                 │
│  │              │  REST   │   EXPRESS    │                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                          │
│                          ┌────────▼────────┐                │
│                          │   DATA LAYER    │                │
│                          ├─────────────────┤                │
│                          │  MongoDB Atlas  │                │
│                          │       OR        │                │
│                          │  JSON Storage   │                │
│                          └─────────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Backend Setup & Testing

### **Step 1: Install Dependencies**

```bash
cd backend
npm install
```

**Expected Output:**
```
added 150 packages, and audited 151 packages in 15s
```

### **Step 2: Configure Environment**

Create `.env` file:
```bash
PORT=3000
MONGODB_URI=mongodb+srv://your_username:your_password@cluster.mongodb.net/nexusoms
```

**Note:** If MongoDB URI is not configured, backend will automatically use JSON file storage.

### **Step 3: Start Backend Server**

```bash
npm start
# OR
node server.js
```

**Expected Output:**
```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          🚀 NexusOMS Enterprise API v2.0.0            ║
║                                                        ║
║  Status: ✅ ONLINE                                     ║
║  Port: 3000                                            ║
║  Database: 📁 JSON Storage                            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

### **Step 4: Test Backend API**

Open browser and visit: `http://localhost:3000`

**Expected:** You should see a green welcome page with "NexusOMS Enterprise API" and "System Terminal is ONLINE"

---

## 📱 Flutter App Setup & Testing

### **Step 1: Install Flutter Dependencies**

```bash
cd flutter
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in flutter...
Resolving dependencies...
Got dependencies!
```

### **Step 2: Configure API Endpoint**

Edit `lib/providers/nexus_provider.dart`:

**For Local Testing:**
```dart
final baseUrl = 'http://localhost:3000/api';
```

**For Production (Render/Heroku):**
```dart
final baseUrl = 'https://nexus-oms-backend.onrender.com/api';
```

**For Android Emulator:**
```dart
final baseUrl = 'http://10.0.2.2:3000/api';
```

**For Physical Device (same WiFi):**
```dart
final baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
// Example: 'http://192.168.1.100:3000/api'
```

### **Step 3: Run Flutter App**

**List Available Devices:**
```bash
flutter devices
```

**Run on Connected Device:**
```bash
flutter run
```

**Run on Specific Device:**
```bash
flutter run -d DEVICE_ID
```

**Expected Output:**
```
Launching lib\main.dart on RMX3031 in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Syncing files to device RMX3031...

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on RMX3031 is available at: http://127.0.0.1:xxxxx
The Flutter DevTools debugger and profiler on RMX3031 is available at: http://127.0.0.1:xxxxx
```

---

## 🎯 Complete User Journey

#### **High-Fidelity SCM Flow (Ek Dum Detail):**

1.  **Stage 1 (Booking)**: Sales records mission with 18% GST.
2.  **Stage 2 (Finance)**: Credit Control clears financial risk.
3.  **Stage 3 (QC Audit)**: Dheeraj performs Temperature & Packaging integrity check.
4.  **Stage 4 (WMS Packing)**: Pranav verifies Batch Numbers and Packaging consumption.
5.  **Stage 5 (Logistics Audit)**: Lawin calculates Freight; Sentinel checks for High-Cost alerts (>15%).
6.  **Stage 6 (Invoicing)**: ATL Team generates Revenue lines with ERP Sync.
7.  **Stage 7 (Hub)**: Sagar manifests missions into Regional Routes.
8.  **Stage 8 (Execution)**: Field team captures EPOD (Signature/OTP/Photo).

---

## 📊 Screen-by-Screen Testing

### **Dashboard Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch all orders for stats
- **Test:**
  1. Login to app
  2. Verify stats cards show correct numbers
  3. Verify all 11 action cards are visible
  4. Verify all 7 utility cards are visible
  5. Click each card to ensure navigation works

### **New Customer Screen** ✅
- **Backend APIs Used:**
  - `POST /api/customers` - Create new customer
- **Test:**
  1. Click "0. NEW CUSTOMER"
  2. Fill all fields (Name, Email, Phone, Address, City, State, PIN)
  3. Click "CREATE CUSTOMER"
  4. Verify success message
  5. Check `backend/data/customers.json` for new entry

### **Book Order Screen** ✅
- **Backend APIs Used:**
  - `GET /api/customers` - Load customers
  - `GET /api/products` - Load products
  - `POST /api/orders` - Create order
- **Test:**
  1. Click "1. BOOK ORDER"
  2. Select customer from dropdown
  3. Add products with quantities
  4. Fill delivery details
  5. Upload documents (optional)
  6. Click "SUBMIT ORDER"
  7. Verify order created in `backend/data/orders.json`

### **Stock Transfer Screen (STN)** ✅
- **Backend APIs Used:**
  - `GET /api/products` - Load products
  - `POST /api/orders` - Create STN order
- **Test:**
  1. Click "1.1 STOCK TRANSFER"
  2. Select source and destination warehouses
  3. Add products to transfer
  4. Click "CREATE STN"
  5. Verify STN order created with `isSTN: true`

### **Live Orders Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch active orders
- **Test:**
  1. Click "1.5 LIVE ORDERS"
  2. Verify all non-delivered orders are shown
  3. Click "TRACK MISSION LIVE" on any order
  4. Verify navigation to Tracking Screen

### **Tracking Screen** ✅
- **Backend APIs Used:**
  - None (uses order data passed from Live Orders)
- **Test:**
  1. Access via Live Orders
  2. Verify map loads with markers
  3. Verify order details shown
  4. Verify route visualization

### **Credit Control Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders?status=Pending` - Fetch pending orders
  - `PATCH /api/orders/:id` - Approve/Reject order
- **Test:**
  1. Click "2. CREDIT CONTROL"
  2. Verify pending orders shown
  3. Click "APPROVE" on an order
  4. Verify status updated to "Credit Approved"
  5. Click "REJECT" on an order
  6. Verify status updated to "Rejected"

### **Warehouse Selection Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch approved orders
  - `PATCH /api/orders/:id` - Assign warehouse
- **Test:**
  1. Click "2.5 WH ASSIGN"
  2. Select warehouse from dropdown
  3. Click "ASSIGN WAREHOUSE"
  4. Verify warehouse assigned in order

### **Warehouse Inventory Screen** ✅
- **Backend APIs Used:**
  - `GET /api/products` - Fetch products
  - `PATCH /api/products/:id` - Update stock
- **Test:**
  1. Click "3. WAREHOUSE"
  2. Verify all products shown with stock levels
  3. Update stock for a product
  4. Verify stock updated in `backend/data/products.json`

### **Logistics Cost Screen** ✅
- **Backend APIs Used:**
  - `PATCH /api/orders/:id` - Save logistics cost
- **Test:**
  1. Click "4. LOGISTICS COST"
  2. Enter shipment details (weight, distance, mode)
  3. Verify freight cost calculated
  4. Save logistics info

### **Invoicing Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch orders ready for invoice
  - `PATCH /api/orders/:id` - Mark as invoiced
- **Test:**
  1. Click "5. INVOICING"
  2. Verify orders ready for invoicing
  3. Generate invoice
  4. Verify invoice details

### **Logistics Hub Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch invoiced orders
  - `PATCH /api/orders/:id` - Assign driver/route
- **Test:**
  1. Click "6. LOGISTICS HUB"
  2. Verify orders ready for dispatch
  3. Assign driver and route
  4. Verify assignment saved

### **Delivery Execution Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch in-transit orders
  - `POST /api/upload/pod` - Upload POD
  - `PATCH /api/orders/:id` - Mark delivered
- **Test:**
  1. Click "7. EXECUTION"
  2. Verify in-transit orders
  3. Upload POD image
  4. Mark as delivered
  5. Verify POD saved in `backend/uploads/pod/`

### **Procurement Screen** ✅
- **Backend APIs Used:**
  - `GET /api/products` - Fetch products
  - `POST /api/orders` - Create purchase order
- **Test:**
  1. Click "Procurement" from utilities
  2. Create purchase order
  3. Verify PO created

### **Analytics Screen** ✅
- **Backend APIs Used:**
  - `GET /api/analytics/dashboard` - Fetch analytics
- **Test:**
  1. Click "Intelligence" from utilities
  2. Verify charts and metrics load
  3. Verify data accuracy

### **Order Archive Screen** ✅
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch all orders
- **Test:**
  1. Click "Order Archive" from utilities
  2. Verify all orders shown
  3. Filter by status
  4. Search orders

### **Master Data Screen** ✅
- **Backend APIs Used:**
  - `GET /api/users` - Fetch users
  - `GET /api/customers` - Fetch customers
  - `GET /api/products` - Fetch products
- **Test:**
  1. Click "Master Data" from utilities
  2. View users, customers, products
  3. Add/Edit entries

### **Sales Hub Screen** ✅ (NEW)
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch orders for sales metrics
- **Test:**
  1. Click "Sales Hub" from utilities
  2. Verify sales metrics (Total Sales, Completed, Pending, Avg Order)
  3. Verify sales pipeline visualization
  4. Verify top customers list
  5. Verify recent activity feed

### **Reporting Screen** ✅ (NEW)
- **Backend APIs Used:**
  - `GET /api/orders` - For sales report
  - `GET /api/products` - For inventory report
  - `GET /api/customers` - For customer report
- **Test:**
  1. Click "Reporting" from utilities
  2. Select "Sales Report" - verify sales summary
  3. Select "Inventory Report" - verify product list
  4. Select "Customer Report" - verify customer list
  5. Select "Financial Report" - verify revenue/pending
  6. Select "Performance Report" - verify metrics
  7. Click export button - verify export options (PDF, Excel, CSV)

### **PMS Screen** ✅ (NEW)
- **Backend APIs Used:**
  - `GET /api/orders` - Fetch orders for performance metrics
- **Test:**
  1. Click "PMS" from utilities
  2. Verify user performance card with score, rank, growth
  3. Verify KPI dashboard (Orders Completed, Response Time, etc.)
  4. Verify sales targets with progress bar
  5. Verify performance metrics with trends
  6. Verify team leaderboard

---

## 🔌 Backend API Testing

### **Using Postman/Thunder Client:**

#### **1. Login**
```http
POST http://localhost:3000/api/login
Content-Type: application/json

{
  "email": "admin@nexus.com",
  "password": "admin123"
}
```

**Expected Response:**
```json
{
  "id": "admin@nexus.com",
  "name": "Admin User",
  "role": "Admin",
  "status": "Active"
}
```

#### **2. Get All Orders**
```http
GET http://localhost:3000/api/orders
```

**Expected Response:**
```json
[
  {
    "id": "ORD-123456",
    "customerName": "ABC Corp",
    "total": 50000,
    "status": "Pending",
    "createdAt": "2026-02-10T10:00:00.000Z"
  }
]
```

#### **3. Create Order**
```http
POST http://localhost:3000/api/orders
Content-Type: application/json

{
  "customerName": "Test Customer",
  "customerPhone": "9876543210",
  "items": [
    {
      "productName": "Product A",
      "quantity": 10,
      "price": 100
    }
  ],
  "total": 1000,
  "status": "Pending"
}
```

#### **4. Update Order**
```http
PATCH http://localhost:3000/api/orders/ORD-123456
Content-Type: application/json

{
  "status": "Credit Approved"
}
```

#### **5. Upload POD**
```http
POST http://localhost:3000/api/upload/pod
Content-Type: multipart/form-data

pod: [SELECT FILE]
```

---

## 🐛 Troubleshooting

### **Backend Issues:**

**Problem:** Backend not starting
```
Solution:
1. Check if port 3000 is already in use
2. Run: netstat -ano | findstr :3000
3. Kill process or change PORT in .env
```

**Problem:** MongoDB connection error
```
Solution:
1. Check MONGODB_URI in .env
2. Verify MongoDB Atlas credentials
3. Backend will fallback to JSON storage automatically
```

**Problem:** CORS error in Flutter app
```
Solution:
Backend already has CORS enabled. Check if:
1. Backend is running
2. API URL is correct in nexus_provider.dart
3. Device can reach backend (same network for local)
```

### **Flutter Issues:**

**Problem:** App not connecting to backend
```
Solution:
1. For Android Emulator: Use http://10.0.2.2:3000/api
2. For Physical Device: Use http://YOUR_IP:3000/api
3. Check firewall settings
4. Verify backend is running
```

**Problem:** Login not persisting
```
Solution:
1. Check SharedPreferences implementation
2. Clear app data and reinstall
3. Verify login API response
```

**Problem:** Hot reload not working
```
Solution:
1. Press 'R' for hot restart
2. Stop and restart flutter run
3. Clear build cache: flutter clean
```

---

## ✅ Complete Testing Checklist

### **Backend:**
- [ ] Server starts without errors
- [ ] Home page loads at http://localhost:3000
- [ ] Login API works
- [ ] Orders CRUD operations work
- [ ] Customers CRUD operations work
- [ ] Products CRUD operations work
- [ ] File upload works
- [ ] Analytics API works

### **Flutter App:**
- [ ] App installs successfully
- [ ] Login screen works
- [ ] Login persists after app restart
- [ ] Dashboard loads with correct stats
- [ ] All 11 action cards navigate correctly
- [ ] All 7 utility cards navigate correctly
- [ ] New customer creation works
- [ ] Order booking works
- [ ] Stock transfer works
- [ ] Live orders display correctly
- [ ] Tracking screen shows map
- [ ] Credit control approve/reject works
- [ ] Warehouse assignment works
- [ ] Warehouse inventory updates
- [ ] Logistics cost calculation works
- [ ] Invoicing works
- [ ] Logistics hub assignment works
- [ ] Delivery execution with POD upload works
- [ ] Order archive shows all orders
- [ ] Analytics screen loads
- [ ] Master data management works
- [ ] Sales Hub shows metrics
- [ ] Reporting generates reports
- [ ] PMS shows performance data
- [ ] Exit button shows confirmation
- [ ] Logout works
- [ ] App is responsive on mobile and tablet

---

## 🎉 Success Criteria

Your NexusOMS application is working perfectly if:

1. ✅ Backend server starts and shows green status page
2. ✅ Flutter app connects to backend successfully
3. ✅ Login works and persists
4. ✅ Dashboard shows real-time data
5. ✅ Complete order lifecycle works (Create → Approve → Assign → Invoice → Deliver)
6. ✅ All 22 screens are accessible and functional
7. ✅ Data persists in MongoDB or JSON files
8. ✅ File uploads work (POD, documents)
9. ✅ No errors in console or app
10. ✅ App is responsive and looks good

---

## 📞 Support

If you encounter any issues:
1. Check console logs (Backend: Terminal, Flutter: Debug Console)
2. Verify API endpoints in nexus_provider.dart
3. Check network connectivity
4. Review this guide's troubleshooting section
5. Check backend/data/*.json files for data

---

**Built with ❤️ for Enterprise Supply Chain Management**

**Version:** 2.0.0  
**Last Updated:** February 10, 2026
