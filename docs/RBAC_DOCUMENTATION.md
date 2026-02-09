# NexusOMS - Complete Role-Based Access Control (RBAC) Documentation

## 📊 System Overview
NexusOMS has **8 user roles** with specific access permissions across **20+ modules**.

---

## 👥 User Roles & Their Access

### 1. **ADMIN** (Full System Access)
**Login:** `animesh.jamuar@bigsams.in` / `kunal.shah@bigsams.in`

#### ✅ Access to ALL Modules:
**Control Center:**
- ✅ Executive Pulse (Dashboard)
- ✅ Live Missions (Real-time orders)
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ✅ 0. New Customer
- ✅ 1. Book Order
- ✅ 1.1 Stock Transfer (STN)
- ✅ 2. Credit Control
- ✅ 2.5 WH Assignment
- ✅ 3. Warehouse/Packing
- ✅ 4. Logistics Cost
- ✅ 5. Invoicing
- ✅ 6. Logistics Hub
- ✅ 7. Execution (Delivery)

**System Intelligence:**
- ✅ Organization (Master Data)
- ✅ Analytics (Reports)
- ✅ Procurement Inbound
- ✅ Incentive Terminal (PMS)

---

### 2. **SALES** (Order Creation & Tracking)
**Login:** `sandeep.chavan@bigsams.in` / `mithun.muddappa@bigsams.in`

#### ✅ Access:
**Control Center:**
- ✅ Sales Hub (Personalized dashboard)
- ✅ Live Missions
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ✅ 0. New Customer
- ✅ 1. Book Order
- ❌ 1.1 Stock Transfer (Admin only)
- ❌ 2. Credit Control (View only)
- ❌ 2.5 WH Assignment (No access)
- ❌ 3. Warehouse (No access)
- ❌ 4. Logistics Cost (No access)
- ❌ 5. Invoicing (No access)
- ❌ 6. Logistics Hub (No access)
- ❌ 7. Execution (No access)

**System Intelligence:**
- ❌ Organization (No access)
- ❌ Analytics (No access)
- ❌ Procurement (No access)
- ✅ Incentive Terminal (PMS - Own performance only)

**Special Features:**
- Monthly targets tracking
- Commission calculation
- Customer relationship management

---

### 3. **CREDIT CONTROL / FINANCE** (Approval Authority)
**Login:** `credit.control@bigsams.in`

#### ✅ Access:
**Control Center:**
- ✅ Executive Pulse (Dashboard)
- ✅ Live Missions
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ❌ 0. New Customer (No access)
- ❌ 1. Book Order (No access)
- ❌ 1.1 Stock Transfer (No access)
- ✅ 2. Credit Control (PRIMARY - Approve/Reject)
- ❌ 2.5 WH Assignment (No access)
- ❌ 3. Warehouse (No access)
- ❌ 4. Logistics Cost (No access)
- ❌ 5. Invoicing (View only)
- ❌ 6. Logistics Hub (No access)
- ❌ 7. Execution (No access)

**System Intelligence:**
- ❌ Organization (No access)
- ✅ Analytics (Financial reports only)
- ❌ Procurement (No access)
- ❌ Incentive Terminal (No access)

**Special Permissions:**
- Can approve/reject orders based on credit limit
- Can view OD Master (Overdue data)
- Can hold orders for payment

---

### 4. **WAREHOUSE / PACKING**
**Login:** `production@bigsams.in`

#### ✅ Access:
**Control Center:**
- ❌ Executive Pulse (No access)
- ✅ Live Missions
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ❌ 0. New Customer (No access)
- ❌ 1. Book Order (No access)
- ❌ 1.1 Stock Transfer (View only)
- ❌ 2. Credit Control (No access)
- ✅ 2.5 WH Assignment (View assigned orders)
- ✅ 3. Warehouse (PRIMARY - Pack orders)
- ❌ 4. Logistics Cost (No access)
- ❌ 5. Invoicing (No access)
- ❌ 6. Logistics Hub (No access)
- ❌ 7. Execution (No access)

**System Intelligence:**
- ❌ Organization (No access)
- ❌ Analytics (No access)
- ❌ Procurement (No access)
- ❌ Incentive Terminal (No access)

**Special Features:**
- Scan barcodes
- Update packed quantities
- Mark boxes ready for dispatch

---

### 5. **LOGISTICS TEAM**
**Login:** `logistics@bigsams.in`

#### ✅ Access:
**Control Center:**
- ❌ Executive Pulse (No access)
- ✅ Live Missions
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ❌ 0. New Customer (No access)
- ❌ 1. Book Order (No access)
- ❌ 1.1 Stock Transfer (No access)
- ❌ 2. Credit Control (No access)
- ❌ 2.5 WH Assignment (No access)
- ❌ 3. Warehouse (No access)
- ✅ 4. Logistics Cost (Calculate freight)
- ✅ 5. Invoicing (View only)
- ✅ 6. Logistics Hub (PRIMARY - Assign drivers)
- ❌ 7. Execution (Monitor only)

**System Intelligence:**
- ❌ Organization (No access)
- ✅ Analytics (Logistics reports only)
- ❌ Procurement (No access)
- ❌ Incentive Terminal (No access)

**Special Features:**
- Assign delivery agents
- Calculate transportation costs
- Track fleet in real-time

---

### 6. **DELIVERY TEAM** (Drivers)
**Login:** `driver.rahul@bigsams.in` / `driver.vicky@bigsams.in` / `driver.akash@bigsams.in`

#### ✅ Access:
**Control Center:**
- ❌ Executive Pulse (No access)
- ❌ Live Missions (No access)
- ❌ Order Archive (No access)

**Supply Chain Lifecycle:**
- ❌ ALL SUPPLY CHAIN MODULES (No access)
- ✅ 7. Execution (PRIMARY - Only assigned deliveries)

**System Intelligence:**
- ❌ ALL SYSTEM INTELLIGENCE (No access)

**Special Features:**
- View only assigned orders
- Pickup confirmation
- Delivery status update (Delivered/Partial/Rejected)
- POD (Proof of Delivery) photo upload
- GPS tracking integration

**Workflow:**
1. **Invoiced** → Confirm pickup
2. **Loaded** → Start delivery
3. **Transit** → Mark fulfillment
4. **Delivered** → Upload POD

---

### 7. **BILLING TEAM**
**Login:** `nitin.kadam@bigsams.in`

#### ✅ Access:
**Control Center:**
- ❌ Executive Pulse (No access)
- ✅ Live Missions
- ✅ Order Archive

**Supply Chain Lifecycle:**
- ❌ 0. New Customer (No access)
- ❌ 1. Book Order (No access)
- ❌ 1.1 Stock Transfer (No access)
- ❌ 2. Credit Control (No access)
- ❌ 2.5 WH Assignment (No access)
- ❌ 3. Warehouse (No access)
- ❌ 4. Logistics Cost (View only)
- ✅ 5. Invoicing (PRIMARY - Generate invoices)
- ❌ 6. Logistics Hub (No access)
- ❌ 7. Execution (No access)

**System Intelligence:**
- ❌ Organization (No access)
- ✅ Analytics (Billing reports only)
- ❌ Procurement (No access)
- ❌ Incentive Terminal (No access)

**Special Features:**
- Generate GST invoices
- Export to Tally XML
- Print delivery challans

---

### 8. **PROCUREMENT TEAM**
**Login:** `procurement@bigsams.in` (Executive) / `procurement.head@bigsams.in` (Head)

#### ✅ Access:
**Control Center:**
- ❌ Executive Pulse (No access)
- ✅ Live Missions (View only)
- ❌ Order Archive (No access)

**Supply Chain Lifecycle:**
- ❌ ALL SUPPLY CHAIN MODULES (No access)

**System Intelligence:**
- ❌ Organization (No access)
- ❌ Analytics (No access)
- ✅ Procurement Inbound (PRIMARY)
- ❌ Incentive Terminal (No access)

**Special Features:**
- Create purchase orders
- Track inbound shipments
- Vendor management
- Inventory replenishment

**Procurement Head Additional Access:**
- Approve purchase orders
- Vendor negotiations
- Budget management

---

## 🔐 Access Control Matrix

| Module | Admin | Sales | Finance | Warehouse | Logistics | Delivery | Billing | Procurement |
|--------|-------|-------|---------|-----------|-----------|----------|---------|-------------|
| **Executive Pulse** | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Sales Hub** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Live Missions** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | 👁️ |
| **Order Archive** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| **New Customer** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Book Order** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Stock Transfer** | ✅ | ❌ | ❌ | 👁️ | ❌ | ❌ | ❌ | ❌ |
| **Credit Control** | ✅ | 👁️ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **WH Assignment** | ✅ | ❌ | ❌ | 👁️ | ❌ | ❌ | ❌ | ❌ |
| **Warehouse** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Logistics Cost** | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | 👁️ | ❌ |
| **Invoicing** | ✅ | ❌ | 👁️ | ❌ | 👁️ | ❌ | ✅ | ❌ |
| **Logistics Hub** | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Execution** | ✅ | ❌ | ❌ | ❌ | 👁️ | ✅ | ❌ | ❌ |
| **Organization** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Analytics** | ✅ | ❌ | 📊 | ❌ | 📊 | ❌ | 📊 | ❌ |
| **Procurement** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Incentive Terminal** | ✅ | 📊 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**Legend:**
- ✅ Full Access
- 👁️ View Only
- 📊 Limited/Filtered Access
- ❌ No Access

---

## 📋 Order Status Flow

```
1. PENDING (Sales creates)
   ↓
2. PENDING_CREDIT_APPROVAL (Finance reviews)
   ↓
3. CREDIT_APPROVED (Finance approves)
   ↓
4. PENDING_WH_SELECTION (Admin assigns warehouse)
   ↓
5. PENDING_PACKING (Warehouse packs)
   ↓
6. PACKED (Warehouse completes)
   ↓
7. PENDING_LOGISTICS_COST (Logistics calculates freight)
   ↓
8. COST_ADDED (Logistics completes)
   ↓
9. PENDING_INVOICING (Billing generates invoice)
   ↓
10. INVOICED (Billing completes)
    ↓
11. READY_FOR_DISPATCH (Logistics assigns driver)
    ↓
12. PICKED_UP (Driver confirms pickup)
    ↓
13. OUT_FOR_DELIVERY (Driver starts delivery)
    ↓
14. DELIVERED / PART_ACCEPTED / REJECTED (Driver completes)
```

---

## 🎯 Key Features by Role

### Admin:
- Full system control
- User management
- Master data management
- System configuration

### Sales:
- Customer onboarding
- Order booking
- Performance tracking
- Commission reports

### Finance:
- Credit limit enforcement
- Payment tracking
- Overdue management
- Financial approvals

### Warehouse:
- Inventory management
- Order packing
- Barcode scanning
- Stock movements

### Logistics:
- Fleet management
- Route optimization
- Cost calculation
- Driver assignment

### Delivery:
- Pickup confirmation
- Delivery execution
- POD capture
- GPS tracking

### Billing:
- Invoice generation
- Tally integration
- Tax calculation
- Document printing

### Procurement:
- Purchase orders
- Vendor management
- Inbound tracking
- Inventory planning

---

## 🔒 Security Features

1. **Role-based authentication**
2. **Session management**
3. **Action logging**
4. **Data encryption**
5. **Approval workflows**
6. **Audit trails**

---

**Generated:** 2026-02-09  
**System:** NexusOMS Enterprise v12  
**Total Users:** 14  
**Total Roles:** 8  
**Total Modules:** 20+
