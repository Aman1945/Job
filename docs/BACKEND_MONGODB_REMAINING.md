# 🔧 BACKEND + MONGODB - REMAINING TASKS
**Date**: 2026-02-12  
**Estimated Time**: 2-3 hours  
**Priority**: MEDIUM-HIGH

---

## ✅ COMPLETED BACKEND TASKS (97%)

### What's Already Done:
- ✅ JWT Authentication
- ✅ Password Hashing (bcrypt)
- ✅ RBAC Middleware
- ✅ Security Middleware (Helmet, Rate Limiting, CORS)
- ✅ 18 New API Endpoints
- ✅ 4 Services (Excel, Gemini, Maps, Storage)
- ✅ WebSocket Server
- ✅ 7 Database Models

---

## ⏳ REMAINING BACKEND TASKS (3%)

### TASK 1: Password Migration Execution (15 MINS)

**What**: Run migration script to hash all existing passwords

**Steps**:
```bash
cd backend
npm run migrate-passwords
```

**Expected Output**:
```
✅ Migrated: 15 users
⏭️  Skipped (already hashed): 0 users
❌ Errors: 0 users
```

**Verification**:
```bash
# Test login with existing password
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@nexusoms.com","password":"admin123"}'

# Should return JWT token
```

---

### TASK 2: Environment Variables Setup (10 MINS)

**File**: `backend/.env`

**Add Real API Keys**:
```bash
# Current (placeholder values)
GEMINI_API_KEY=your-gemini-api-key-here
GOOGLE_MAPS_API_KEY=your-google-maps-api-key-here

# Update to real values
GEMINI_API_KEY=AIzaSyD...actual-key-here
GOOGLE_MAPS_API_KEY=AIzaSyB...actual-key-here

# Optional: Cloudflare R2 (if using)
R2_ACCOUNT_ID=your-cloudflare-account-id
R2_ACCESS_KEY_ID=your-r2-access-key-id
R2_SECRET_ACCESS_KEY=your-r2-secret-access-key
R2_BUCKET_NAME=nexusoms
R2_PUBLIC_URL=https://nexusoms.r2.dev
```

**How to Get API Keys**:

1. **Gemini API Key**:
   - Go to: https://makersuite.google.com/app/apikey
   - Click "Create API Key"
   - Copy key and paste in .env

2. **Google Maps API Key**:
   - Go to: https://console.cloud.google.com/
   - Enable "Distance Matrix API"
   - Create credentials → API Key
   - Copy key and paste in .env

3. **Cloudflare R2** (Optional):
   - Go to: https://dash.cloudflare.com/
   - R2 → Create Bucket → "nexusoms"
   - Manage R2 API Tokens → Create Token
   - Copy credentials and paste in .env

---

### TASK 3: Server Testing (30 MINS)

**3.1 Start Server**:
```bash
cd backend
npm start
```

**Expected Output**:
```
✅ Connected to MongoDB Atlas
✅ Gemini AI initialized
✅ Google Maps API initialized
✅ Cloudflare R2 storage initialized
✅ Socket.IO server initialized
🔌 WebSocket server ready for real-time connections

╔════════════════════════════════════════════════════════╗
║          🚀 NexusOMS Enterprise API v2.1.0            ║
║  Status: ✅ ONLINE (Strict Mode)                       ║
║  Port: 3000                                            ║
║  Database: ☁️  MongoDB Atlas                            ║
║  WebSocket: 🔌 ENABLED                                  ║
╚════════════════════════════════════════════════════════╝
```

**3.2 Test Endpoints with cURL**:

```bash
# 1. Test Login
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@nexusoms.com","password":"admin123"}'

# Save token from response
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 2. Test PMS
curl -X GET "http://localhost:3000/api/pms/USER-001?month=Feb'26" \
  -H "Authorization: Bearer $TOKEN"

# 3. Test Bulk Order Template Download
curl -X GET http://localhost:3000/api/orders/bulk/template \
  -H "Authorization: Bearer $TOKEN" \
  -o template.xlsx

# 4. Test AI Credit Insight
curl -X POST http://localhost:3000/api/ai/credit-insight \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"orderId":"ORD-001","customerId":"CUST-001"}'

# 5. Test Logistics Cost Calculator
curl -X POST http://localhost:3000/api/logistics/calculate-cost \
  -H "Content-Type: application/json" \
  -d '{"origin":"Mumbai","destination":"Delhi","vehicleType":"Truck"}'

# 6. Test Expiring Products
curl -X GET "http://localhost:3000/api/products/expiring?days=90" \
  -H "Authorization: Bearer $TOKEN"

# 7. Test Packaging Materials
curl -X GET http://localhost:3000/api/packaging/materials \
  -H "Authorization: Bearer $TOKEN"
```

---

### TASK 4: Create Postman Collection (20 MINS)

**File**: `backend/NexusOMS_API_Collection.json`

**Steps**:
1. Open Postman
2. Create new collection: "NexusOMS API"
3. Add folders:
   - Authentication
   - PMS
   - Clearance Orders
   - Packaging Inventory
   - Bulk Upload
   - AI Insights
   - Logistics

4. Add requests for all 18 endpoints
5. Set environment variables:
   - `baseUrl`: http://localhost:3000
   - `token`: {{token}} (auto-set from login response)

6. Export collection as JSON
7. Save to `backend/NexusOMS_API_Collection.json`

---

### TASK 5: API Documentation (30 MINS)

**File**: `docs/API_DOCUMENTATION.md`

**Sections to Include**:
1. Authentication
   - How to get JWT token
   - How to use token in requests
   - Token expiry handling

2. Endpoints List
   - For each endpoint:
     - Method & URL
     - Auth required
     - Request body
     - Response format
     - Example cURL command

3. Error Codes
   - 200: Success
   - 201: Created
   - 400: Bad Request
   - 401: Unauthorized (token expired/invalid)
   - 403: Forbidden (insufficient permissions)
   - 404: Not Found
   - 429: Too Many Requests (rate limit)
   - 500: Internal Server Error

4. WebSocket Events
   - How to connect
   - Available events
   - Event payloads

---

## ⏳ MONGODB REMAINING TASKS

### TASK 6: Database Indexes (15 MINS)

**What**: Add indexes for faster queries

**File**: `backend/scripts/create-indexes.js`

```javascript
const mongoose = require('mongoose');
require('dotenv').config();

async function createIndexes() {
  await mongoose.connect(process.env.MONGODB_URI);
  
  const db = mongoose.connection.db;
  
  // User indexes
  await db.collection('users').createIndex({ email: 1 });
  await db.collection('users').createIndex({ role: 1 });
  await db.collection('users').createIndex({ status: 1 });
  
  // Order indexes
  await db.collection('orders').createIndex({ customerId: 1 });
  await db.collection('orders').createIndex({ status: 1 });
  await db.collection('orders').createIndex({ salespersonId: 1 });
  await db.collection('orders').createIndex({ createdAt: -1 });
  await db.collection('orders').createIndex({ isClearance: 1 });
  
  // Product indexes
  await db.collection('products').createIndex({ skuCode: 1 });
  await db.collection('products').createIndex({ category: 1 });
  await db.collection('products').createIndex({ 'batches.expDate': 1 });
  
  // Performance indexes
  await db.collection('performancerecords').createIndex({ userId: 1, month: 1 });
  await db.collection('performancerecords').createIndex({ totalScore: -1 });
  
  // Packaging indexes
  await db.collection('packagingmaterials').createIndex({ category: 1 });
  await db.collection('packagingtransactions').createIndex({ materialId: 1 });
  await db.collection('packagingtransactions').createIndex({ date: -1 });
  
  console.log('✅ All indexes created');
  process.exit(0);
}

createIndexes();
```

**Run**:
```bash
node backend/scripts/create-indexes.js
```

---

### TASK 7: Sample Data Creation (30 MINS)

**What**: Create sample data for testing

**File**: `backend/scripts/seed-data.js`

```javascript
const mongoose = require('mongoose');
require('dotenv').config();

const User = require('../models/User');
const Customer = require('../models/Customer');
const Product = require('../models/Product');
const PerformanceRecord = require('../models/PerformanceRecord');
const PackagingMaterial = require('../models/PackagingMaterial');

async function seedData() {
  await mongoose.connect(process.env.MONGODB_URI);
  
  // Create sample users
  const users = [
    { id: 'SALES-001', name: 'Rajesh Kumar', email: 'rajesh@nexusoms.com', password: 'sales123', role: 'Sales' },
    { id: 'SALES-002', name: 'Priya Sharma', email: 'priya@nexusoms.com', password: 'sales123', role: 'Sales' },
    { id: 'CREDIT-001', name: 'Amit Patel', email: 'amit@nexusoms.com', password: 'credit123', role: 'Credit Control' },
  ];
  
  for (const userData of users) {
    const existing = await User.findOne({ id: userData.id });
    if (!existing) {
      await User.create(userData);
      console.log(`✅ Created user: ${userData.name}`);
    }
  }
  
  // Create sample customers
  const customers = [
    { id: 'CUST-001', name: 'ABC Traders', outstanding: 15000, overdue: 5000, ageingDays: 45, creditLimit: 50000 },
    { id: 'CUST-002', name: 'XYZ Enterprises', outstanding: 8000, overdue: 0, ageingDays: 15, creditLimit: 100000 },
  ];
  
  for (const custData of customers) {
    const existing = await Customer.findOne({ id: custData.id });
    if (!existing) {
      await Customer.create(custData);
      console.log(`✅ Created customer: ${custData.name}`);
    }
  }
  
  // Create sample products with batches
  const products = [
    {
      id: 'PROD-001',
      skuCode: 'SKU-001',
      name: 'Premium Basmati Rice 5kg',
      category: 'Rice',
      baseRate: 450,
      mrp: 500,
      batches: [
        { batchId: 'B001', batchNumber: 'BATCH-001', mfgDate: '2025-12-01', expDate: '2026-06-01', quantity: 100, weight: '5 KG', isActive: true },
        { batchId: 'B002', batchNumber: 'BATCH-002', mfgDate: '2026-01-01', expDate: '2026-07-01', quantity: 50, weight: '5 KG', isActive: true },
      ]
    },
  ];
  
  for (const prodData of products) {
    const existing = await Product.findOne({ id: prodData.id });
    if (!existing) {
      const product = await Product.create(prodData);
      product.calculateStock();
      await product.save();
      console.log(`✅ Created product: ${prodData.name}`);
    }
  }
  
  // Create sample performance records
  const perfRecords = [
    {
      userId: 'SALES-001',
      userName: 'Rajesh Kumar',
      month: "Feb'26",
      grossMonthlySalary: 50000,
      kras: [
        { id: 'KRA1', name: 'Sales Target', type: 'Unrestricted', target: 1000000, achieved: 1200000, weightage: 40 },
        { id: 'KRA2', name: 'Collection', type: 'Restricted', target: 500000, achieved: 450000, weightage: 30 },
      ],
      odBalances: { chennai: 300000, self: 200000, hyd: 100000 },
    },
  ];
  
  for (const perfData of perfRecords) {
    const existing = await PerformanceRecord.findOne({ userId: perfData.userId, month: perfData.month });
    if (!existing) {
      const record = await PerformanceRecord.create(perfData);
      record.calculateTotalScore();
      await record.save();
      console.log(`✅ Created performance record: ${perfData.userName}`);
    }
  }
  
  // Create sample packaging materials
  const materials = [
    { id: 'PKG-001', name: 'Poly Bags 5kg', unit: 'PCS', moq: 1000, balance: 500, category: 'Poly Pkts' },
    { id: 'PKG-002', name: 'Vacuum Pouches 1kg', unit: 'PCS', moq: 500, balance: 200, category: 'Vacuum Pouches' },
  ];
  
  for (const matData of materials) {
    const existing = await PackagingMaterial.findOne({ id: matData.id });
    if (!existing) {
      await PackagingMaterial.create(matData);
      console.log(`✅ Created packaging material: ${matData.name}`);
    }
  }
  
  console.log('\n✅ Sample data seeding complete!');
  process.exit(0);
}

seedData();
```

**Run**:
```bash
node backend/scripts/seed-data.js
```

---

### TASK 8: Database Backup Strategy (10 MINS)

**What**: Document backup and recovery process

**File**: `docs/DATABASE_BACKUP.md`

**Content**:
```markdown
# MongoDB Backup Strategy

## Automatic Backups (MongoDB Atlas)
- **Frequency**: Daily at 2:00 AM IST
- **Retention**: 7 days
- **Location**: MongoDB Atlas Cloud Backup

## Manual Backup
```bash
# Export entire database
mongodump --uri="mongodb+srv://username:password@cluster.mongodb.net/NexusOMS" --out=./backup

# Export specific collection
mongodump --uri="mongodb+srv://..." --collection=orders --out=./backup

# Restore from backup
mongorestore --uri="mongodb+srv://..." --dir=./backup
```

## Recovery Time Objective (RTO)
- **Target**: 4 hours
- **Actual**: 1-2 hours (with MongoDB Atlas)

## Recovery Point Objective (RPO)
- **Target**: 1 hour
- **Actual**: 24 hours (daily backups)
```

---

## 📊 SUMMARY - BACKEND + MONGODB REMAINING

| Task | Time | Priority | Status |
|------|------|----------|--------|
| 1. Password Migration | 15 mins | HIGH | ⏳ Pending |
| 2. Environment Variables | 10 mins | HIGH | ⏳ Pending |
| 3. Server Testing | 30 mins | HIGH | ⏳ Pending |
| 4. Postman Collection | 20 mins | MEDIUM | ⏳ Pending |
| 5. API Documentation | 30 mins | MEDIUM | ⏳ Pending |
| 6. Database Indexes | 15 mins | MEDIUM | ⏳ Pending |
| 7. Sample Data | 30 mins | LOW | ⏳ Pending |
| 8. Backup Strategy | 10 mins | LOW | ⏳ Pending |
| **TOTAL** | **2.5 hours** | - | **0% Done** |

---

## 🎯 RECOMMENDED EXECUTION ORDER

1. **Environment Variables** (10 mins) - Required for testing
2. **Password Migration** (15 mins) - Required for login
3. **Server Testing** (30 mins) - Verify everything works
4. **Database Indexes** (15 mins) - Performance optimization
5. **Postman Collection** (20 mins) - Testing tool
6. **API Documentation** (30 mins) - For team reference
7. **Sample Data** (30 mins) - For demo/testing
8. **Backup Strategy** (10 mins) - Documentation only

---

## ✅ COMPLETION CHECKLIST

- [ ] All environment variables set with real API keys
- [ ] Password migration script executed successfully
- [ ] Server starts without errors
- [ ] All 18 API endpoints tested and working
- [ ] WebSocket connection successful
- [ ] Database indexes created
- [ ] Postman collection created and exported
- [ ] API documentation complete
- [ ] Sample data created for testing
- [ ] Backup strategy documented

---

**Last Updated**: 2026-02-12 13:15 IST  
**Estimated Completion**: 2-3 hours
