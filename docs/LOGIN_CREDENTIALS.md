# 🔐 NexusOMS - Complete Login Credentials & Roles

## 📋 ALL USER CREDENTIALS

---

## 🔴 **ADMIN** (Full System Access)

### **User 1: Animesh Jamuar**
- **Email:** `animesh.jamuar@bigsams.in`
- **Password:** `admin123`
- **Role:** Admin
- **Access:** All 14 screens (Complete system control)

### **User 2: Kunal Shah**
- **Email:** `kunal.shah@bigsams.in`
- **Password:** `admin123`
- **Role:** Admin
- **Access:** All 14 screens (Complete system control)

#### ✅ **Admin Can Access:**
1. ✅ Dashboard (Executive Pulse)
2. ✅ Live Orders (Live Missions)
3. ✅ Order Archive
4. ✅ New Customer
5. ✅ Book Order
6. ✅ Analytics
7. ✅ Credit Control
8. ✅ WH Assignment
9. ✅ Logistics Hub
10. ✅ Delivery Execution
11. ✅ Invoicing
12. ✅ Procurement
13. ✅ Master Data
14. ✅ Tracking

---

## 🟢 **SALES** (Order Creation & Customer Management)

### **User 3: Sandeep Chavan**
- **Email:** `sandeep.chavan@bigsams.in`
- **Password:** `sales123`
- **Role:** Sales
- **Access:** 4 screens

### **User 4: Mithun Muddappa**
- **Email:** `mithun.muddappa@bigsams.in`
- **Password:** `sales123`
- **Role:** Sales
- **Access:** 4 screens

#### ✅ **Sales Can Access:**
1. ✅ Book Order (Create new orders)
2. ✅ New Customer (Onboard customers)
3. ✅ Order Archive (View own orders)
4. ✅ Analytics (Own performance)

#### ❌ **Sales CANNOT:**
- ❌ Approve credit
- ❌ Assign warehouses
- ❌ Assign drivers
- ❌ Manage deliveries
- ❌ Generate invoices

---

## 🟡 **FINANCE / APPROVER** (Credit Control)

### **User 5: Credit Control**
- **Email:** `credit.control@bigsams.in`
- **Password:** `finance123`
- **Role:** Finance/Approver
- **Access:** 3 screens

#### ✅ **Finance Can Access:**
1. ✅ Credit Control (PRIMARY - Approve/Reject orders)
2. ✅ Dashboard (View pending approvals)
3. ✅ Order Archive (View all orders)

#### ❌ **Finance CANNOT:**
- ❌ Create orders
- ❌ Assign warehouses
- ❌ Assign drivers
- ❌ Manage deliveries

---

## 🔵 **WAREHOUSE** (Packing & Fulfillment)

### **User 6: Production Team**
- **Email:** `production@bigsams.in`
- **Password:** `warehouse123`
- **Role:** Warehouse
- **Access:** 3 screens

#### ✅ **Warehouse Can Access:**
1. ✅ WH Assignment (PRIMARY - Accept assignments)
2. ✅ Packing Queue (Pack orders)
3. ✅ Order Archive (View packing history)

#### ❌ **Warehouse CANNOT:**
- ❌ Create orders
- ❌ Approve credit
- ❌ Assign drivers
- ❌ Manage deliveries

---

## 🟣 **LOGISTICS** (Fleet Management)

### **User 7: Logistics Team**
- **Email:** `logistics@bigsams.in`
- **Password:** `logistics123`
- **Role:** Logistics
- **Access:** 3 screens

#### ✅ **Logistics Can Access:**
1. ✅ Logistics Hub (PRIMARY - Assign drivers)
2. ✅ Fleet Tracking (Monitor deliveries)
3. ✅ Order Archive (View logistics history)

#### ❌ **Logistics CANNOT:**
- ❌ Create orders
- ❌ Approve credit
- ❌ Pack orders
- ❌ Mark deliveries (only drivers can)

---

## 🟠 **DELIVERY** (Drivers - Field Execution)

### **User 8: Driver Rahul**
- **Email:** `driver.rahul@bigsams.in`
- **Password:** `driver123`
- **Role:** Delivery
- **Access:** 1 screen (ONLY assigned orders)

### **User 9: Driver Vicky**
- **Email:** `driver.vicky@bigsams.in`
- **Password:** `driver123`
- **Role:** Delivery
- **Access:** 1 screen (ONLY assigned orders)

### **User 10: Driver Akash**
- **Email:** `driver.akash@bigsams.in`
- **Password:** `driver123`
- **Role:** Delivery
- **Access:** 1 screen (ONLY assigned orders)

#### ✅ **Delivery Can Access:**
1. ✅ My Deliveries (Delivery Execution)
   - View ONLY assigned orders
   - Start delivery
   - Mark as delivered
   - Upload POD (Proof of Delivery)
   - Mark partial/rejected

#### ❌ **Delivery CANNOT:**
- ❌ See other drivers' orders
- ❌ Create orders
- ❌ Approve anything
- ❌ Assign warehouses
- ❌ View analytics

---

## 🟤 **BILLING** (Invoice Generation)

### **User 11: Billing Team**
- **Email:** `billing@bigsams.in`
- **Password:** `billing123`
- **Role:** Billing
- **Access:** 3 screens

#### ✅ **Billing Can Access:**
1. ✅ Invoicing (PRIMARY - Generate invoices)
2. ✅ Order Archive (View billing history)
3. ✅ Analytics (Financial reports)

---

## ⚫ **PROCUREMENT** (Purchase Orders)

### **User 12: Procurement Team**
- **Email:** `procurement@bigsams.in`
- **Password:** `procurement123`
- **Role:** Procurement
- **Access:** 2 screens

#### ✅ **Procurement Can Access:**
1. ✅ Procurement (PRIMARY - Create POs)
2. ✅ Master Data (View products)

---

## 🔵 **VIEWER** (Read-Only Access)

### **User 13: Viewer**
- **Email:** `viewer@bigsams.in`
- **Password:** `viewer123`
- **Role:** Viewer
- **Access:** 2 screens (Read-only)

#### ✅ **Viewer Can Access:**
1. ✅ Dashboard (View only)
2. ✅ Order Archive (View only)

#### ❌ **Viewer CANNOT:**
- ❌ Create anything
- ❌ Edit anything
- ❌ Delete anything
- ❌ Approve anything

---

## 📊 ROLE COMPARISON TABLE

| Role | Screens | Create Orders | Approve Credit | Assign WH | Assign Driver | Deliver | Invoice |
|------|---------|---------------|----------------|-----------|---------------|---------|---------|
| **Admin** | 14 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Sales** | 4 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Finance** | 3 | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Warehouse** | 3 | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Logistics** | 3 | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| **Delivery** | 1 | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Billing** | 3 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Procurement** | 2 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Viewer** | 2 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 🎯 QUICK LOGIN GUIDE

### **For Demo (Use Admin):**
```
Email: animesh.jamuar@bigsams.in
Password: admin123
```

### **Test Sales Flow:**
```
Email: sandeep.chavan@bigsams.in
Password: sales123
```

### **Test Credit Approval:**
```
Email: credit.control@bigsams.in
Password: finance123
```

### **Test Delivery:**
```
Email: driver.rahul@bigsams.in
Password: driver123
```

---

## 🔄 TYPICAL WORKFLOW BY ROLE

### **1. Sales Person (Sandeep)**
```
Login → Book Order → Add Items → Submit
(Order status: "Pending Credit Approval")
```

### **2. Finance (Credit Control)**
```
Login → Credit Control → Approve/Reject
(Order status: "Credit Approved" or "Rejected")
```

### **3. Admin/Warehouse (Production)**
```
Login → WH Assignment → Select Warehouse
(Order status: "Pending Packing")
```

### **4. Warehouse (Production)**
```
Login → Packing Queue → Pack Items
(Order status: "Packed" → "Invoiced")
```

### **5. Logistics (Logistics Team)**
```
Login → Logistics Hub → Assign Driver
(Order status: "Picked Up")
```

### **6. Driver (Rahul)**
```
Login → My Deliveries → Start Delivery → Deliver
(Order status: "Out for Delivery" → "Delivered")
```

---

## 🔐 PASSWORD POLICY

**Current:** Simple passwords for demo  
**Production:** Should implement:
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers
- Special characters
- Password expiry (90 days)
- 2FA (Two-Factor Authentication)

---

## 📱 HOW TO LOGIN (Flutter App)

1. Open NexusOMS app
2. Enter email (e.g., `animesh.jamuar@bigsams.in`)
3. Enter password (e.g., `admin123`)
4. Click "LOGIN"
5. App will show screens based on your role

---

## 🚨 IMPORTANT NOTES

1. **Admin has FULL access** - Use for demo
2. **Each role sees ONLY their screens** - Security enforced
3. **Drivers see ONLY assigned orders** - Privacy maintained
4. **All passwords are demo passwords** - Change in production
5. **MongoDB stores all data** - Cloud-based

---

## 📞 SUPPORT

**Forgot Password?** Contact admin  
**Access Issues?** Check role assignment  
**Login Failed?** Verify email/password spelling

---

**Generated:** 2026-02-09 23:12 IST  
**Total Users:** 13  
**Total Roles:** 8  
**Status:** 🟢 ACTIVE
