# 📘 NexusOMS Enterprise SCM Role Playbook - Complete User Guide

This playbook defines the exact credentials and step-by-step usage for each stage of the **Mission Lifecycle**. All users share the default password: **`admin`**.

---

## 🏛️ 1. SALES TERMINAL (Stage 1)

**Usage:** Create orders, check customer outstanding, and track booking targets.

### 👤 Login Credentials
- **Login ID:** `abhijit.chavan@bigsams.in`
- **Login ID:** `sandeep.chavan@bigsams.in`
- **Password:** `admin`

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `abhijit.chavan@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Sales Dashboard will appear

#### STEP 2: Book New Order
1. From dashboard, tap **"Book Order"** button
2. Select customer from dropdown
3. Check customer's **Outstanding Balance** and **Credit Limit**
4. Tap **"+ Add Product"**
5. Search and select products
6. Enter quantities
7. Review order total (Sub-total + GST 18%)
8. Tap **"Submit Order"**

#### STEP 3: What Happens Next
- **If customer credit OK:** Order → `Pending WH Selection`
- **If customer over-limit:** Order → `Pending Credit Approval` (goes to Credit Control)

### 📊 Key Features
- View your sales targets and achievements
- Track all your orders
- Check customer payment status
- Create Stock Transfer Notes (STN)
- View PMS (Performance Management) score

---

## 🛡️ 2. CREDIT CONTROL TERMINAL (Stage 2)

**Usage:** Verify financial health and approve/reject high-risk orders.

### 👤 Login Credentials
- **Login ID:** `credit.control@bigsams.in`
- **Login ID:** `kshama.jaiswal@bigsams.in`
- **Login ID:** `pawan.kumar@bigsams.in` (Pawan handles Credit Control row)
- **Password:** `admin`

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `credit.control@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Credit Control Dashboard will appear

#### STEP 2: Access Pending Approvals
1. From dashboard, tap **"Credit Control Terminal"**
2. You'll see all orders with status: `Pending Credit Approval`
3. Orders are sorted by value (highest first)

#### STEP 3: Review Order Details
1. Tap on any order to review
2. Check **Credit Exposure Matrix:**
   - Current Outstanding Balance
   - Credit Limit
   - This Order Value
   - New Total Exposure
   - Available Credit
3. Review **AI Risk Assessment** (Gemini-powered):
   - AI recommendation (Approve/Review/Reject)
   - Key risk factors
   - Payment pattern analysis
4. Check **Aging Analysis:**
   - 0-30 days overdue
   - 31-60 days overdue
   - 61-90 days overdue
   - 90+ days overdue

#### STEP 4: Make Decision
1. Add **Internal Notes** (optional but recommended)
2. Choose action:
   - **Approve:** Tap **"APPROVE ORDER"** (green button)
   - **Reject:** Tap **"REJECT ORDER"** (red button) + enter reason
3. Tap **"Confirm"**

#### STEP 5: What Happens Next
- **If Approved:** Order → `Pending WH Selection` (goes to Warehouse)
- **If Rejected:** Salesperson gets notification, customer needs to clear dues

### 📊 Key Features
- AI-powered credit insights
- Real-time credit exposure monitoring
- Aging analysis reports
- Customer payment history

---

## 🏭 3. WH ASSIGNMENT & PACKING (Stage 3)

**Usage:** Select source warehouse and confirm physical packing.

### 👤 Login Credentials
- **Login ID:** `operations@bigsams.in` (WH Manager - Pranav)
- **Login ID:** `amit.sharma@bigsams.in` (Arihan Delhi WH)
- **Login ID:** `amit.dp@bigsams.in` (Kurla WH)
- **Login ID:** `roshan.bhosale@bigsams.in` (Kurla WH)
- **Login ID:** `arun@bigsams.in` (Jally Bangalore WH)
- **Password:** `admin`

### 🏢 Warehouse Locations
- **Kurla:** Amit DP, Roshan Bhosale
- **Arihan Delhi:** Amit Sharma
- **Jally Bangalore:** Arun

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `operations@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Warehouse Dashboard will appear

#### STEP 2: Assign Warehouse
1. From dashboard, tap **"Warehouse Fulfillment"**
2. You'll see orders with status: `Pending WH Selection`
3. Tap on order to assign
4. Check **Stock Availability** for each warehouse:
   - Kurla WH: Shows available stock
   - Delhi WH: Shows available stock
   - Bangalore WH: Shows available stock
5. Select best warehouse based on:
   - Stock availability
   - Customer location (nearest)
   - Delivery time
6. Tap **"Select Warehouse"** dropdown
7. Choose warehouse (e.g., "Kurla WH")
8. Tap **"Assign Warehouse"**

#### STEP 3: Pack the Order
1. From dashboard, tap **"Orders to Pack"**
2. You'll see orders assigned to your warehouse
3. Tap on order to pack
4. Tap **"Start Packing"**
5. Verify each product:
   - Check SKU code
   - Verify quantity
   - Pick from inventory
   - Scan barcode (if available)
6. Complete **Packing Checklist:**
   - [ ] All products picked correctly
   - [ ] Quantities verified
   - [ ] Proper packaging material used
   - [ ] Temperature-controlled packaging (for frozen items)
   - [ ] Dry ice added (if needed)
   - [ ] Labels printed and attached
   - [ ] Invoice copy included
   - [ ] Box sealed properly
7. Enter packing details:
   - Number of boxes
   - Total weight
   - Packaging cost
   - Dry ice quantity
8. Tap **"Mark as Packed"**

#### STEP 4: What Happens Next
- Order → `Packed` (goes to Quality Control)
- QC team gets notification

### 📊 Key Features
- Multi-warehouse stock visibility
- Real-time inventory tracking
- Packing time tracking
- Stock Transfer Notes (STN) creation

---

## 🔍 4. QUALITY CONTROL (Stage 3.5)

**Usage:** Post-packing verification (Shipment Integrity Protocol).

### 👤 Login Credentials
- **Login ID:** `quality@bigsams.in` (QC Head)
- **Login ID:** `dhiraj.kumar@bigsams.in`
- **Password:** `admin`

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `quality@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ QC Dashboard will appear

#### STEP 2: Access Packed Orders
1. From dashboard, tap **"Quality Check"**
2. OR tap **"Mission Control"** → Filter: `Packed`
3. You'll see all packed orders waiting for QC

#### STEP 3: Perform Quality Check
1. Tap on order to inspect
2. Tap **"Start QC"**
3. Complete **Shipment Integrity Protocol Checklist:**

**✅ Product Verification**
- [ ] All products as per order list
- [ ] Correct quantities
- [ ] No damaged items
- [ ] Expiry dates checked (if applicable)

**✅ Packaging Quality**
- [ ] Proper packaging material used
- [ ] No leaks or damages
- [ ] Temperature-controlled packaging (for frozen items)
- [ ] Dry ice quantity adequate

**✅ Labeling**
- [ ] Customer name and address correct
- [ ] Order ID printed
- [ ] "Fragile" / "Keep Frozen" labels (if needed)
- [ ] Barcode/QR code readable

**✅ Documentation**
- [ ] Invoice copy included
- [ ] Delivery challan attached
- [ ] Product list matches

**✅ Temperature Check**
- [ ] Temperature maintained (for cold chain)
- [ ] Thermometer reading recorded
- [ ] Packaging sealed properly

#### STEP 4: Make Decision
1. If all checks pass:
   - Tap **"Approve for Invoicing"** (green button)
   - Add QC notes (optional)
   - Tap **"Confirm"**
2. If any check fails:
   - Tap **"Reject"** (red button)
   - Select rejection reason
   - Take photos
   - Add detailed notes
   - Tap **"Send Back to Warehouse"**

#### STEP 5: What Happens Next
- **If Approved:** Order → `Pending Invoicing` (goes to Invoicing team)
- **If Rejected:** Order → Back to `Warehouse` for re-packing

### 📊 Key Features
- Digital QC checklist
- Photo documentation
- Temperature tracking
- Rejection tracking and analytics

---

## 💰 5. INVOICING TERMINAL (Stage 5)

**Usage:** Generate final commercial invoices and tax documents.

### 👤 Login Credentials
- **Login ID:** `nitin.kadam@bigsams.in`
- **Login ID:** `pradip.patil@bigsams.in`
- **Login ID:** `sanesh@bigsams.in`
- **Login ID:** `rajesh@bigsams.in`
- **Login ID:** `deepashree@bigsams.in`
- **Password:** `admin`

### 👥 Group
**ATL Executives** (Sanesh/Sandesh, Rajesh, Nitin, Deepashree). Only the Invoicing row is visible to them.

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `nitin.kadam@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Invoicing Dashboard will appear

#### STEP 2: Access Invoicing Terminal
1. From dashboard, tap **"Invoicing Terminal"**
2. You'll see orders with status: `Pending Invoicing`
3. These are QC-approved orders ready for invoicing

#### STEP 3: Review Order Details
1. Tap on order to invoice
2. Verify:
   - Customer name and GSTIN
   - Billing address
   - Products and quantities
   - Prices
   - Sub-total
   - GST amount (18%)
   - **Grand Total**

#### STEP 4: Generate Invoice
1. Tap **"Generate Invoice"** button
2. Invoice will be auto-generated with:
   - Unique invoice number (e.g., INV-2024-001)
   - Date and time
   - All tax calculations (CGST 9% + SGST 9%)
   - Company details
   - Terms and conditions
3. Preview invoice PDF
4. Tap **"Confirm & Save"**
5. ✅ Success: "Invoice generated!"

#### STEP 5: What Happens Next
- Order → `Invoiced` (goes to Logistics Hub)
- Invoice PDF saved
- Customer gets invoice copy via email
- Logistics team gets notification

### 📊 Key Features
- Auto-invoice generation
- GST compliance
- Invoice PDF download
- Email to customer
- Invoice cancellation (if needed)

---

## 🚚 6. LOGISTICS HUB (Stage 6)

**Usage:** Consolidate invoices into Trip Manifests and assign vehicles.

### 👤 Login Credentials
- **Login ID:** `logistics@bigsams.in`
- **Login ID:** `pratish.dalvi@bigsams.in` (sees both Logistics Cost and Logistics Hub rows)
- **Login ID:** `sagar@bigsams.in` (Delivery)
- **Password:** `admin`

### 👥 Personnel
- **Sagar:** Delivery Executive
- **Pratish Dalvi:** Logistics Lead (has access to both Logistics Cost and Logistics Hub)

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `logistics@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Logistics Hub Dashboard will appear

#### STEP 2: Access Logistics Hub Screen
1. From dashboard, tap **"Logistics Hub"**
2. You'll see all invoiced orders ready for dispatch
3. Orders grouped by city/region

#### STEP 3: Create Trip Manifest
1. Tap **"Create Manifest"** button
2. Select orders going to same region:
   - Example: All orders for "North Mumbai"
   - Tap checkboxes to select orders (5-20 orders per manifest)
3. Selection criteria:
   - Same city/region
   - Same delivery date
   - Total weight < vehicle capacity

#### STEP 4: Assign Vehicle
1. Tap **"Select Vehicle"** dropdown
2. Choose vehicle type:
   - Small Van (up to 500 kg)
   - Medium Truck (500-2000 kg)
   - Large Truck (2000+ kg)
3. Enter vehicle number (e.g., MH-01-AB-1234)
4. Select vehicle type:
   - Refrigerated (for frozen items)
   - Non-refrigerated

#### STEP 5: Assign Delivery Team
1. Tap **"Select Driver"** dropdown
2. Choose driver from list
3. Tap **"Select Helper"** (optional)
4. Enter contact numbers

#### STEP 6: Add Route Details
1. Enter starting point (warehouse)
2. Add delivery stops in sequence
3. Estimated distance
4. Estimated time

#### STEP 7: Calculate Logistics Cost
App will auto-calculate:
- Fuel cost
- Driver charges
- Vehicle rental
- Toll charges
- Dry ice cost
- Packaging cost
- **Total logistics cost**
- **Cost percentage** (Total cost / Order value × 100)

**⚠️ Alert:** If cost > 15% of order value → Requires approval from Admin/CEO

#### STEP 8: Create Manifest
1. Review all details
2. Tap **"Create Manifest"** button
3. Manifest generated with:
   - Manifest ID (e.g., MAN-2024-001)
   - All order IDs
   - Vehicle details
   - Route map
   - Delivery sequence
4. ✅ Success: "Manifest created!"

#### STEP 9: Dispatch Manifest
1. When vehicle is loaded and ready
2. Tap on manifest
3. Tap **"Start Dispatch"** button
4. Enter:
   - Dispatch time
   - Odometer reading
   - Special instructions
5. Tap **"Confirm Dispatch"**

#### STEP 10: What Happens Next
- All orders in manifest → `In Transit`
- Customers get SMS notification
- Live tracking enabled
- Delivery team can start trip

### 📊 Key Features
- Multi-order manifest creation
- Route optimization
- Vehicle assignment
- Cost calculation
- Live tracking

---

## 📉 7. LOGISTICS COST APPROVAL (Stage 6.5)

**Usage:** Oversee logistics expenses and approve high-cost shipments (>15%).

### 👤 Login Credentials
- **Login ID:** `animesh.jamuar@bigsams.in` (Admin/Approver)
- **Login ID:** `lavin.samtani@bigsams.in` (CEO)
- **Login ID:** `pratish.dalvi@bigsams.in` (Logistics Lead - sees both rows)
- **Password:** `admin`

### 👥 Personnel
- **Pratish Dalvi:** Lead (has access to both Logistics Cost and Logistics Hub)
- **Animesh Jamuar:** Admin (receives high-cost alerts)
- **Lavin Samtani:** CEO (final approver)

### 🚨 Alert Trigger
If Dry Ice + Packaging costs exceed **15%** of order value → "High-Cost Alert" notification goes to Admin Animesh

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app
2. Enter email: `animesh.jamuar@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Admin Dashboard will appear

#### STEP 2: Monitor Logistics Costs
1. From dashboard, tap **"Logistics Cost Screen"**
2. You'll see all manifests with cost breakdown
3. **🚨 Red Alert** shown for manifests with cost > 15%

#### STEP 3: Review High-Cost Manifest
1. Tap on manifest with red alert
2. Review **Cost Breakdown:**
   - Order Value: ₹XX,XXX
   - Fuel: ₹X,XXX
   - Driver: ₹X,XXX
   - Vehicle: ₹X,XXX
   - Dry Ice: ₹X,XXX ⚠️
   - Packaging: ₹X,XXX
   - **Total: ₹XX,XXX**
   - **Cost %: XX%** 🚨

#### STEP 4: Analyze Why Cost is High
Common reasons:
- Long distance delivery
- Refrigerated vehicle needed
- Excessive dry ice usage
- Small order value
- Remote location

#### STEP 5: Make Decision
**✅ APPROVE if:**
- Cost justified (remote location)
- Customer is premium
- Urgent delivery needed
- No alternative available

**❌ REJECT if:**
- Cost too high
- Can be optimized
- Can club with other orders
- Can delay delivery

#### STEP 6: Approve/Reject
**To Approve:**
1. Tap **"Approve High Cost"** button
2. Add approval notes
3. Tap **"Confirm"**

**To Reject:**
1. Tap **"Reject"** button
2. Add reason and suggestions
3. Tap **"Send Back to Logistics"**

#### STEP 7: What Happens Next
- **If Approved:** Manifest can be dispatched
- **If Rejected:** Logistics team must optimize and resubmit

### 📊 Key Features
- Real-time cost monitoring
- High-cost alerts (>15%)
- Cost breakdown analysis
- Approval workflow
- Cost optimization suggestions

---

## 🚛 8. DELIVERY TERMINAL (Stage 7)

**Usage:** Deliver orders to customers and collect Proof of Delivery.

### 👤 Login Credentials
- **Login ID:** `delivery1@bigsams.in`
- **Login ID:** `delivery2@bigsams.in`
- **Login ID:** `sagar@bigsams.in`
- **Password:** `admin`

### 📱 Step-by-Step Instructions

#### STEP 1: Login to App
1. Open Nexus OMS app on your phone
2. Enter email: `delivery1@bigsams.in`
3. Enter password: `admin`
4. Tap **"LOGIN"**
5. ✅ Delivery Dashboard will appear

#### STEP 2: View Your Delivery Manifest
1. From dashboard, tap **"My Deliveries"**
2. You'll see your assigned manifest with:
   - Manifest ID
   - Number of orders
   - Total stops
   - Route map
   - Estimated time

#### STEP 3: Start Delivery Trip
1. Before starting, verify:
   - [ ] Vehicle loaded with all orders
   - [ ] Manifest printout taken
   - [ ] Phone charged
   - [ ] GPS enabled
   - [ ] Fuel sufficient
2. Tap **"Start Trip"** button
3. Enter:
   - Start time
   - Odometer reading
   - Starting location
4. Tap **"Begin Delivery"**
5. ✅ Live tracking starts

#### STEP 4: Deliver Each Order
**At Customer Location:**
1. Tap on delivery stop
2. Tap **"Navigate"** → Google Maps opens
3. Drive to customer location
4. Call customer: "I'm outside with your order"
5. Unload the order
6. Verify customer identity
7. Hand over the order

#### STEP 5: Collect Proof of Delivery (POD)
1. Tap **"Mark as Delivered"** button
2. Collect:
   - [ ] Customer signature (on phone screen)
   - [ ] Customer name (typed)
   - [ ] Photo of delivered order
   - [ ] Any special notes
3. Tap **"Confirm Delivery"**
4. ✅ Success: "Order delivered!"

#### STEP 6: Handle Delivery Issues
**If customer not available:**
1. Tap **"Customer Not Available"**
2. Call customer
3. Options:
   - Wait 15 minutes
   - Reschedule delivery
   - Return to warehouse

**If customer refuses order:**
1. Tap **"Delivery Refused"**
2. Enter reason
3. Take photo
4. Return order to warehouse

**If address wrong:**
1. Tap **"Address Issue"**
2. Call customer for correct address
3. Update in app
4. Navigate to new address

#### STEP 7: Complete Trip
1. After all deliveries, tap **"End Trip"**
2. Enter:
   - End time
   - Odometer reading
   - Total distance covered
3. Review summary:
   - Total deliveries
   - Successful
   - Failed
   - Distance
   - Time
4. Tap **"Submit Trip Report"**
5. ✅ Trip completed!

#### STEP 8: What Happens Next
- All delivered orders → `Delivered` ✅
- Customers get confirmation SMS
- Invoices marked as delivered
- Trip report sent to logistics team

### 📊 Key Features
- GPS navigation
- Live tracking
- Digital POD collection
- Photo documentation
- Delivery issue handling
- Trip summary reports

---

## 🕹️ Operational Summary Table

| Stage | Department | Status Transition | Primary Login | Key Screen |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Sales | `Draft` → `Pending Credit` | `abhijit.chavan@bigsams.in` | Book Order |
| **2** | Credit | `Pending Credit` → `Approved` | `credit.control@bigsams.in` | Credit Control Terminal |
| **3** | WH | `Approved` → `Packed` | `operations@bigsams.in` | Warehouse Fulfillment |
| **3.5**| QC | `Packed` → `Verified` | `quality@bigsams.in` | Quality Check |
| **5** | Billing | `Verified` → `Invoiced` | `nitin.kadam@bigsams.in` | Invoicing Terminal |
| **6** | Logistics| `Invoiced` → `In Transit` | `logistics@bigsams.in` | Logistics Hub |
| **6.5**| Cost Approval | High-Cost Alert | `animesh.jamuar@bigsams.in` | Logistics Cost Screen |
| **7** | Delivery | `In Transit` → `Delivered` | `delivery1@bigsams.in` | My Deliveries |

---

## 📊 Quick Reference: Who Sees What

| User | Visible Screens/Rows |
| :--- | :--- |
| **Sales** | Book Order, My Orders, Customers, Products, PMS |
| **Credit Control** | Credit Control Terminal, Credit Reports, Customer Credit |
| **Warehouse** | Warehouse Fulfillment, Orders to Pack, Inventory, STN |
| **QC** | Quality Check, Mission Control (Packed filter) |
| **ATL/Invoicing** | Invoicing Terminal only |
| **Logistics Hub** | Logistics Hub, Create Manifest, Dispatch |
| **Pratish Dalvi** | Both Logistics Hub + Logistics Cost rows |
| **Admin/CEO** | All screens, Analytics, Reports, Master Data |
| **Delivery** | My Deliveries, Trip Management, POD Collection |

---

## 🔐 Security & Access Control

- **Role-Based Access:** Each user sees only their relevant screens
- **Password:** All users use `admin` (change in production)
- **Data Isolation:** Users can only modify orders in their stage
- **Audit Trail:** All actions logged with timestamp and user ID

---

## 📞 Support & Escalation

| Issue | Contact |
| :--- | :--- |
| Order stuck in Credit | `credit.control@bigsams.in` |
| Warehouse issues | `operations@bigsams.in` |
| Invoice problems | `nitin.kadam@bigsams.in` |
| Delivery issues | `logistics@bigsams.in` |
| System/App issues | `admin@bigsams.in` |
| High-cost approval | `animesh.jamuar@bigsams.in` |

---

**Last Updated:** February 17, 2026  
**Version:** 2.0 - Complete Step-by-Step Guide  
**Nexus OMS Development Team**
