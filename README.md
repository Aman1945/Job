# NexusOMS - Enterprise Order Management System

**Full-Stack Enterprise Supply Chain & Order Management Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Project Overview

**NexusOMS** is a comprehensive enterprise-grade Order Management System designed for modern supply chain operations. It features automated workflows, real-time tracking, multi-warehouse management, and seamless integration with accounting systems.

### **Key Features**

#### **📱 Mobile Application (Flutter)**
- ✅ **16 Fully Functional Screens**
  - Dashboard with real-time stats
  - Customer Management (New Customer, Customer List)
  - Order Management (Book Order, Live Orders, Order Archive, Order Details)
  - Stock Transfer (STN) with warehouse selection
  - Credit Control & Approval Workflow
  - Warehouse Operations (Inventory, Assignment)
  - Logistics (Cost Calculator, Hub Management, Tracking)
  - Invoicing & Procurement
  - Delivery Execution with POD upload
  - Analytics & Reporting
  - Master Data Management

- ✅ **Fully Responsive Design**
  - Mobile-first approach (< 768px)
  - Desktop optimized (≥ 768px)
  - No overflow errors
  - Adaptive layouts and components

- ✅ **Advanced Features**
  - Login persistence (SharedPreferences)
  - Exit confirmation dialog
  - Back button handling
  - Real-time order tracking with maps
  - File upload (POD/Documents)
  - Offline-first architecture

- ✅ **RESTful API** with complete CRUD operations
- ✅ **Security Hardened**
  - JWT Authentication (7-day expiry)
  - bcrypt Password Hashing
  - Role-Based Access Control (9 roles)
  - Helmet.js Security Headers
  - Rate Limiting (100 req/15min)
  - CORS Protection
- ✅ **Dual Storage Support**
  - MongoDB Atlas (Cloud)
  - JSON File Storage (Fallback)
- ✅ **Advanced Features**
  - WebSocket Real-time Updates
  - Bulk Order Upload (Excel)
  - AI-Powered Credit Insights (Gemini)
  - Google Maps Distance Matrix
  - Cloudflare R2 File Storage
  - Performance Management System
  - Near-Expiry Clearance Orders
  - Packaging Inventory Management
- ✅ **Comprehensive Endpoints** (40+ endpoints)
  - Authentication (`/api/login`)
  - Users Management (`/api/users`)
  - Customers (`/api/customers`)
  - Products (`/api/products`)
  - Orders (`/api/orders`)
  - Bulk Operations (`/api/orders/bulk`, `/api/orders/bulk-update`)
  - File Uploads (`/api/upload/pod`)
  - Analytics (`/api/analytics/*`)
  - PMS (`/api/pms/*`)
  - Clearance Orders (`/api/orders/clearance`)
  - Packaging (`/api/packaging/*`)
  - AI Insights (`/api/ai/credit-insight`)
  - Logistics (`/api/logistics/calculate-cost`)
  - Export/Download (`/api/analytics/export`)
  - Tally Export (`/api/tally/export/:orderId`)

- ✅ **Features**
  - Automatic order ID generation
  - Status history tracking
  - Query filtering (status, salesperson)
  - File upload with Multer
  - Download notifications with progress tracking
  - Custom notification service
  - CORS enabled
  - Error handling middleware
  - WebSocket events (order:created, order:updated)


---

## 📁 Project Structure

```
NEW JOB/
├── backend/                    # Node.js API Server
│   ├── data/                   # JSON storage (fallback)
│   │   ├── users.json
│   │   ├── customers.json
│   │   ├── products.json
│   │   └── orders.json
│   ├── models/                 # MongoDB Schemas
│   │   ├── User.js
│   │   ├── Customer.js
│   │   ├── Product.js
│   │   └── Order.js
│   ├── uploads/                # File uploads (POD)
│   ├── .env                    # Environment variables
│   ├── server.js               # Main API server
│   ├── migrate.js              # Database migration
│   └── package.json
│
├── flutter/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── models/             # Data models
│   │   ├── providers/          # State management (Provider)
│   │   ├── screens/            # 16 app screens
│   │   ├── utils/              # Theme, constants
│   │   ├── widgets/            # Reusable components
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── docs/                       # Documentation
│   ├── API.md                  # API documentation
│   ├── DEPLOYMENT.md           # Deployment guide
│   └── CREDENTIALS.md          # Login credentials
│
└── README.md                   # This file
```

---

## 🛠️ Tech Stack

### **Frontend (Mobile)**
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **UI Components**: Custom Material Design
- **Maps**: flutter_map, latlong2
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Icons**: lucide_icons
- **Dropdowns**: dropdown_button2

### **Backend (API)**
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB Atlas / JSON Files
- **ODM**: Mongoose
- **File Upload**: Multer
- **Authentication**: Custom (email/password)
- **CORS**: Enabled for all origins

---

## 🚀 Quick Start

### **Prerequisites**
- Node.js 18+ and npm
- Flutter SDK 3.0+
- MongoDB Atlas account (optional)
- Android Studio / Xcode (for mobile development)

### **Backend Setup**

1. **Navigate to backend folder**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your MongoDB URI (optional)
   ```

4. **Run migration (optional - for MongoDB)**
   ```bash
   node migrate.js
   ```

5. **Start server**
   ```bash
   npm start
   ```
   Server runs on `http://localhost:3000`

### **Flutter App Setup**

1. **Navigate to flutter folder**
   ```bash
   cd flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API endpoint** (if needed)
   Edit `lib/providers/nexus_provider.dart`:
   ```dart
   final baseUrl = 'YOUR_BACKEND_URL/api';
   ```

4. **Run app**
   ```bash
   flutter run
   ```

---

## 📱 App Screens

### **Dashboard**
- Real-time stats (Live Missions, Pending Ops, SCM Score, Revenue)
- 11 Action Cards (Supply Chain Lifecycle)
- 4 Utility Terminals (Procurement, Analytics, Archive, Master Data)
- Exit & Logout buttons

### **Order Management**
1. **Book Order** - Create new customer orders
2. **Stock Transfer (STN)** - Inter-warehouse transfers
3. **Live Orders** - View active orders with tracking
4. **Order Archive** - Historical orders
5. **Order Details** - Detailed order view

### **Customer & Warehouse**
6. **New Customer** - Add new customers
7. **Warehouse Selection** - Assign warehouses
8. **Warehouse Inventory** - Stock management

### **Logistics & Execution**
9. **Credit Control** - Approve/reject orders
10. **Logistics Cost** - Freight calculation
11. **Logistics Hub** - Route management
12. **Delivery Execution** - POD upload
13. **Tracking** - Real-time GPS tracking

### **Analytics & Admin**
14. **Invoicing** - Generate invoices
15. **Procurement** - Purchase orders
16. **Analytics** - Business intelligence
17. **Master Data** - System configuration

---

## 🔐 Default Credentials

**Admin User:**
- Email: `admin@nexus.com`
- Password: `admin123`

**Sales User:**
- Email: `sales@nexus.com`
- Password: `sales123`

---

## 🌐 API Endpoints

### **Authentication**
- `POST /api/login` - User login

### **Users**
- `GET /api/users` - Get all users
- `POST /api/users` - Create user
- `PATCH /api/users/:id` - Update user

### **Customers**
- `GET /api/customers` - Get all customers
- `POST /api/customers` - Create customer
- `PATCH /api/customers/:id` - Update customer

### **Products**
- `GET /api/products` - Get all products
- `POST /api/products` - Create product
- `PATCH /api/products/:id` - Update product

### **Orders**
- `GET /api/orders` - Get orders (with filters)
- `GET /api/orders/:id` - Get single order
- `POST /api/orders` - Create order
- `PATCH /api/orders/:id` - Update order
- `DELETE /api/orders/:id` - Delete order
- `POST /api/orders/bulk-update` - Bulk update orders

### **File Upload**
- `POST /api/upload/pod` - Upload POD file

### **Analytics**
- `GET /api/analytics/dashboard` - Dashboard stats
- `GET /api/analytics/sales` - Sales analytics
- `GET /api/analytics/sales-hub` - Sales hub data
- `GET /api/analytics/reports` - Report data
- `GET /api/analytics/pms` - Performance management
- `GET /api/analytics/export` - Export reports (PDF/Excel/CSV)

### **Tally Integration**
- `GET /api/tally/export/:orderId` - Export to Tally XML

---

## 🚢 Deployment

### **Backend Deployment (Render/Heroku)**

1. **Create new Web Service**
2. **Connect GitHub repository**
3. **Set build command**: `npm install`
4. **Set start command**: `node server.js`
5. **Add environment variables**:
   - `MONGODB_URI` (optional)
   - `PORT` (auto-set by platform)

### **Flutter App Deployment**

**Android:**
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```bash
flutter build ios --release
# Follow Xcode signing and upload to App Store
```

---

## 📊 Features Highlights

### **Responsive Design**
- ✅ Mobile-optimized layouts (< 768px)
- ✅ Desktop-friendly views (≥ 768px)
- ✅ Adaptive padding, fonts, and spacing
- ✅ No overflow errors on any screen

### **State Management**
- ✅ Provider pattern for global state
- ✅ Login persistence across app restarts
- ✅ Real-time data updates

### **User Experience**
- ✅ Exit confirmation dialog
- ✅ Back button handling
- ✅ Loading indicators
- ✅ Error handling
- ✅ Success/failure messages

### **Backend Features**
- ✅ Automatic ID generation
- ✅ Status history tracking
- ✅ Query filtering
- ✅ Bulk operations
- ✅ File uploads
- ✅ Tally XML export

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**Aman**
- GitHub: [@Aman1945](https://github.com/Aman1945)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB for cloud database
- Express.js community
- All open-source contributors

---

**Built with ❤️ for Enterprise Supply Chain Management**
