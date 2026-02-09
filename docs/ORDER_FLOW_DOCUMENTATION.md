# 🚀 NexusOMS - Complete Order Flow & Role-Based Access

## 📊 COMPLETE ORDER LIFECYCLE FLOW

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ORDER JOURNEY                                │
└─────────────────────────────────────────────────────────────────────┘

1️⃣  CUSTOMER ONBOARDING
    ├─ Screen: New Customer
    ├─ Role: SALES / ADMIN
    ├─ Action: Create customer profile
    └─ Next: Book Order

2️⃣  ORDER BOOKING
    ├─ Screen: Book Order
    ├─ Role: SALES / ADMIN
    ├─ Action: Create order with items
    ├─ Status: "Pending" → "Pending Credit Approval"
    └─ Next: Credit Control

3️⃣  CREDIT APPROVAL
    ├─ Screen: Credit Control
    ├─ Role: FINANCE / APPROVER / ADMIN
    ├─ Action: Approve/Reject based on credit limit
    ├─ Status: "Pending Credit Approval" → "Credit Approved" OR "Rejected"
    └─ Next: Warehouse Assignment

4️⃣  WAREHOUSE ASSIGNMENT
    ├─ Screen: WH Assignment
    ├─ Role: ADMIN / WAREHOUSE
    ├─ Action: Assign order to specific warehouse
    ├─ Status: "Credit Approved" → "Pending Packing"
    └─ Next: Warehouse Packing

5️⃣  WAREHOUSE PACKING
    ├─ Screen: Packing Queue
    ├─ Role: WAREHOUSE / ADMIN
    ├─ Action: Pack items, scan barcodes
    ├─ Status: "Pending Packing" → "Packed"
    └─ Next: Logistics Cost

6️⃣  LOGISTICS COST CALCULATION
    ├─ Screen: Logistics Cost (Coming Soon)
    ├─ Role: LOGISTICS / ADMIN
    ├─ Action: Calculate freight charges
    ├─ Status: "Packed" → "Cost Added"
    └─ Next: Invoicing

7️⃣  INVOICE GENERATION
    ├─ Screen: Invoicing (Coming Soon)
    ├─ Role: BILLING / ADMIN
    ├─ Action: Generate GST invoice, Tally XML
    ├─ Status: "Cost Added" → "Invoiced"
    └─ Next: Driver Assignment

8️⃣  DRIVER ASSIGNMENT
    ├─ Screen: Logistics Hub
    ├─ Role: LOGISTICS / ADMIN
    ├─ Action: Assign delivery driver
    ├─ Status: "Invoiced" → "Picked Up"
    └─ Next: Delivery Execution

9️⃣  DELIVERY EXECUTION
    ├─ Screen: Delivery Execution / My Deliveries
    ├─ Role: DELIVERY / ADMIN
    ├─ Actions:
    │   ├─ Start Delivery: "Picked Up" → "Out for Delivery"
    │   ├─ Complete: "Out for Delivery" → "Delivered"
    │   ├─ Partial: "Out for Delivery" → "Partially Delivered"
    │   └─ Reject: "Out for Delivery" → "Rejected"
    └─ End: Order Complete

🔟  ORDER ARCHIVE
    ├─ Screen: Order Archive
    ├─ Role: ALL (View only for most)
    ├─ Action: View history, export to Tally
    └─ End: Historical records
```

---

## 👥 ROLE-BASED ACCESS CONTROL

### 🔴 **ADMIN** (Full Access)
**Users:** `animesh.jamuar@bigsams.in`, `kunal.shah@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **Executive Pulse** (Dashboard)
   - View all orders
   - System statistics
   - Real-time analytics

2. ✅ **Live Missions** (Live Orders)
   - Track all active orders
   - Real-time status updates

3. ✅ **Order Archive**
   - View all historical orders
   - Export to Tally

4. ✅ **New Customer**
   - Create customer profiles
   - Manage customer data

5. ✅ **Book Order**
   - Create new orders
   - Add items, calculate totals

6. ✅ **Analytics**
   - Sales reports
   - Performance metrics

7. ✅ **Credit Control**
   - Approve/reject orders
   - Credit limit management

8. ✅ **WH Assignment**
   - Assign orders to warehouses
   - Manage inventory allocation

9. ✅ **Logistics Hub**
   - Assign delivery drivers
   - Fleet management

10. ✅ **Execution**
    - Monitor deliveries
    - Update delivery status

---

### 🟢 **SALES** (Order Creation & Tracking)
**Users:** `sandeep.chavan@bigsams.in`, `mithun.muddappa@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **Book Order**
   - Create new orders
   - Select products & customers

2. ✅ **New Customer**
   - Onboard new customers
   - Update customer info

3. ✅ **Order Archive**
   - View own orders
   - Track order status

4. ✅ **Analytics**
   - Personal sales performance
   - Commission tracking

#### ❌ **Restricted:**
- ❌ Cannot approve credit
- ❌ Cannot assign warehouses
- ❌ Cannot assign drivers
- ❌ Cannot mark deliveries

---

### 🟡 **FINANCE / APPROVER** (Credit Control)
**Users:** `credit.control@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **Credit Control** (PRIMARY)
   - Approve orders based on credit limit
   - Reject orders with payment issues
   - View customer OD (Overdue) data

2. ✅ **Executive Pulse**
   - View pending approvals
   - Financial dashboard

3. ✅ **Order Archive**
   - View all orders
   - Financial reports

#### ❌ **Restricted:**
- ❌ Cannot create orders
- ❌ Cannot assign warehouses
- ❌ Cannot assign drivers
- ❌ Cannot manage deliveries

---

### 🔵 **WAREHOUSE** (Packing & Fulfillment)
**Users:** `production@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **WH Assignment** (PRIMARY)
   - View assigned orders
   - Accept warehouse assignments

2. ✅ **Packing Queue**
   - Pack orders
   - Scan barcodes
   - Update packed quantities

3. ✅ **Order Archive**
   - View packing history

#### ❌ **Restricted:**
- ❌ Cannot create orders
- ❌ Cannot approve credit
- ❌ Cannot assign drivers
- ❌ Cannot manage deliveries

---

### 🟣 **LOGISTICS** (Fleet Management)
**Users:** `logistics@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **Logistics Hub** (PRIMARY)
   - Assign delivery drivers
   - Manage fleet
   - Calculate transportation costs

2. ✅ **Fleet Tracking**
   - Monitor active deliveries
   - Real-time GPS tracking

3. ✅ **Order Archive**
   - View delivery history
   - Logistics reports

#### ❌ **Restricted:**
- ❌ Cannot create orders
- ❌ Cannot approve credit
- ❌ Cannot pack orders
- ❌ Cannot mark deliveries (only drivers can)

---

### 🟠 **DELIVERY** (Drivers)
**Users:** `driver.rahul@bigsams.in`, `driver.vicky@bigsams.in`, `driver.akash@bigsams.in`

#### ✅ **Screens Available:**
1. ✅ **My Deliveries** (PRIMARY - Delivery Execution)
   - View assigned deliveries ONLY
   - Start delivery
   - Mark as delivered/rejected/partial
   - Upload POD (Proof of Delivery)

#### ❌ **Restricted:**
- ❌ Cannot see other drivers' orders
- ❌ Cannot create orders
- ❌ Cannot approve anything
- ❌ Cannot assign warehouses
- ❌ Cannot view analytics

**Workflow:**
```
1. Pickup Confirmation: "Picked Up" → "Out for Delivery"
2. Delivery Actions:
   ├─ Delivered: Upload POD photo
   ├─ Partial: Mark items delivered/rejected
   └─ Rejected: Add rejection reason
```

---

## 📱 FLUTTER APP - CURRENT STATUS

### ✅ **Implemented Screens:**
1. ✅ Dashboard (Executive Pulse)
2. ✅ Live Orders (Live Missions)
3. ✅ Order Archive
4. ✅ Book Order
5. ✅ New Customer
6. ✅ Analytics
7. ✅ Tracking (Live GPS)
8. ✅ **Credit Control** (NEW)
9. ✅ **WH Assignment** (NEW)
10. ✅ **Logistics Hub** (NEW)
11. ✅ **Delivery Execution** (NEW)

### 🚧 **Coming Soon:**
12. 🚧 Logistics Cost
13. 🚧 Invoicing
14. 🚧 Procurement
15. 🚧 Master Data
16. 🚧 PMS/Incentive Terminal

---

## 🔐 LOGIN CREDENTIALS

### Admin:
- `animesh.jamuar@bigsams.in` / `admin123`
- `kunal.shah@bigsams.in` / `admin123`

### Sales:
- `sandeep.chavan@bigsams.in` / `sales123`
- `mithun.muddappa@bigsams.in` / `sales123`

### Finance:
- `credit.control@bigsams.in` / `finance123`

### Warehouse:
- `production@bigsams.in` / `warehouse123`

### Logistics:
- `logistics@bigsams.in` / `logistics123`

### Delivery:
- `driver.rahul@bigsams.in` / `driver123`
- `driver.vicky@bigsams.in` / `driver123`
- `driver.akash@bigsams.in` / `driver123`

---

## 🎯 ORDER STATUS PROGRESSION

```
Pending
  ↓
Pending Credit Approval
  ↓
Credit Approved (or Rejected)
  ↓
Pending WH Selection
  ↓
Pending Packing
  ↓
Packed
  ↓
Pending Logistics Cost
  ↓
Cost Added
  ↓
Pending Invoicing
  ↓
Invoiced
  ↓
Ready for Dispatch
  ↓
Picked Up
  ↓
Out for Delivery / In Transit
  ↓
Delivered / Partially Delivered / Rejected
```

---

## 🔥 KEY FEATURES

### For CEO Demo:
1. ✅ **Role-Based Access** - Each user sees only relevant screens
2. ✅ **Real-Time Tracking** - Live order status updates
3. ✅ **MongoDB Cloud** - Enterprise-grade database
4. ✅ **Tally Integration** - Export orders to Tally XML
5. ✅ **Mobile-First** - Flutter app for on-the-go access
6. ✅ **Complete Workflow** - End-to-end order management
7. ✅ **Multi-User Support** - 8 different roles
8. ✅ **Approval Workflows** - Credit control, warehouse assignment

---

**Generated:** 2026-02-09  
**System:** NexusOMS Enterprise v2.0.0  
**Backend:** Node.js + MongoDB Atlas  
**Frontend:** Flutter (Android/iOS)  
**Status:** 🟢 Production Ready
