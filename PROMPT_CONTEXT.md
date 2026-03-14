# Nexus OMS - Project Context & Memory

**Objective**: Provide this document to the AI assistant (Cursor, Antigravity, etc.) when starting a new session to ensure full continuity of the project state.

---

## 🚀 Project Overview
**Nexus OMS** is a dual-platform (Mobile & Web) Order Management System built for field sales, warehouse management, and administrative control.
- **Backend**: Node.js, Express, MongoDB (Mongoose), JWT Auth.
- **Frontend**: Flutter (Mobile/Web), Provider for State Management.
- **Storage**: DigitalOcean Spaces (S3-compatible) for photos and documents.
- **Infrastructure**: CDN for assets, Role-Based Access Control (RBAC).

## 🛠️ Technical Stack
- **Database**: MongoDB with Mongoose models (`User`, `Customer`, `Order`, `Product`, `DistributorPrice`, `PerformanceRecord`, `AuditLog`, etc.).
- **Auth**: JWT-based `verifyToken` middleware.
- **Audit**: Custom `auditLogger.js` middleware tracking `CREATE`, `UPDATE`, `DELETE` with `oldData` and `newData` snapshots.
- **Excel**: `exceljs` for bulk importing Materials, Customers, and Price Lists.
- **Storage**: `multer` with S3 storage service for DigitalOcean.
- **Infrastructure**: DigitalOcean Droplet, PM2 Cluster, Nginx.

## 🔐 Credentials & Access (High Priority Context)

> [!IMPORTANT]
> Use these credentials for server access, database queries, and environment configuration throughout the project.

### 🛡️ SSH Access
- **Host**: `168.144.31.254`
- **User**: `root`
- **Password**: `aMan@29101979p`
- **Port**: `22` (Default)
- **Repo Directory**: `/root/Job`
- **Backend Path**: `/root/Job/backend`

### 💾 Database (MongoDB Atlas)
- **URI**: `mongodb+srv://doadmin:l83c0V6pR7f59S1g@db-mongodb-blr1-41071-873a3483.mongo.ondigitalocean.com/NexusOMS?replicaSet=db-mongodb-blr1-41071&tls=true&authSource=admin`
- **Main Database Name**: `NexusOMS`

### 🔑 Security & APIs
- **JWT Secret**: `NexusOMS@2024SecretKey#Production$Secure!`
- **Gemini API Key**: `AIzSyBSRHNpNsgK_lshamksmQGulHHrN9BJEA`
- **DO Spaces Key**: `DO006CT2EYGULA4MFFLY`
- **DO Spaces Secret**: `INzmeZbSNHkTXs29QzBREN1A9PeFOTlXrgfB9I8pxTo`
- **DO Spaces Region**: `sgp1`
- **DO Spaces Bucket**: `bigsams-oms-prod`
- **CDN URL**: `https://bigsams-oms-prod.sgp1.cdn.digitaloceanspaces.com`

## 📦 Core Features (A-Z)

### 1. User Management & Hierarchy
- **Roles**: Admin, NSM, RSM, ASM, Sales, Warehouse, Credit Control.
- **Hierarchy**: Managers (RSM/ASM) can view logs and performance of their subordinates.

### 2. Master Data Management
- **Customer Master**: Full profile, contact details, and document uploads (GST, PAN, Cheque).
- **Material Master (Product)**: SKU management, pricing (MRP/Billing Rate), and batch/expiry tracking.
- **Distributor Price List**: Specialized pricing by category and material.

### 3. Order Management
- **Workflow**: Create Order -> Credit Approval -> Warehouse Processing -> Delivery.
- **STN (Stock Transfer)**: Support for internal stock transfer notes.
- **Clearance Orders**: Near-expiry product clearance flow.
- **Bulk Upload**: Excel-based bulk order creation.

### 4. Audit Logging (Recent Major Enhancement)
- **Archive**: An "Order Master Archive" screen in Flutter shows a chronological list of ALL system events.
- **Entity Coverage**: Every action on Orders, Customers, Products, and Price Lists is logged.
- **Detail View**: Logs show what changed (Old vs New), who did it, and when.

### 5. Media & Photo Management
- **Structured Storage**: Photos are organized in DO Spaces using folders:
  - `Orders/CustomerName/SalespersonName_YYYY-MM-DD/`
  - `Customers/CustomerName/Docs_YYYY-MM-DD/`
- **In-App Viewing**: Fullscreen tap-to-view for order photos and customer documents.

### 6. Performance Management (PMS)
- KRA-based scoring, leaderboard, and salary/incentive calculations.

### 7. Logistics & Maps
- Google Maps integration for distance calculation and route tracking.
- Logistics hub for assigning delivery agents and vehicles.

## 📂 Recent Work History (Memory Log)
1. **Audit Logs**: Implemented `logCreate`, `logUpdate`, and `logDelete` for all major entities. Fixed frontend archive filters to handle multi-entity logs and deletions.
2. **Photo Structure**: Modified `NexusProvider.dart` to use meaningful folder paths in DO Spaces instead of a flat "uploads" directory.
3. **Archive UI**: Extracted customer/entity names from log payloads and added "Reset Filters" functionality.
4. **Bug Fixes**: Resolved empty state issues in the Archive screen and ensured `oldData` is captured for deleted items.
5. **Logistics Authorization Fix**: Resolved an issue where orders vanished from the Logistics Hub post-invoicing. Added JWT tokens (`auth.token`) to `updateOrderStatus` and `assignLogistics` in `NexusProvider`, and updated all dependent frontend screens (Invoicing, QC, Warehouse Ops, Logistics Ops, Live Missions, Credit Control, etc.) to securely pass this token, ensuring backend sync.
6. **Order Master Archive UI/UX Review**: Verified the advanced audit capabilities of the Order Master Archive, including multi-parameter filtering (Action, Role, User, Date Range) and visual evidence (Sales Photos) with color-coded chronological timelines.
7. **Logistics & Dispatch Fix**: 
   - Implemented `POST /api/logistics/bulk-assign` backend route to handle order dispatch with manifest, eway-bill, and seal details.
   - Updated `Order.js` schema to include missing logistics fields (`manifestId`, `ewayBill`, `sealNo`, `bookingDate`).
   - Verified the "Ready for Dispatch" -> "In Transit" status transition via API testing.
   - **UI Fix**: Resolved a "Bottom Overflow by 280px" on the mobile `LogisticsHubScreen` by wrapping the split Mission List and Manifest Terminal into a unified `SingleChildScrollView` with `shrinkWrap: true`.
8. **Book Order UI Refinement**:
   - Removed the "Assign Sales Team" hierarchy panel from `BookOrderScreen.dart` to simplify the mission creation flow.
   - Enhanced Sales Photos section: Replaced hardcoded sources with a selection modal (Camera/Gallery) for all three slots (PO Copy, Photo 2, Photo 3).
9. **Sales Org Map Multi-Zone Assignment Bug (Initial)**:
   - Updated the `User` model on both the backend (Node/Mongoose) and frontend (Flutter) to use an `orgPositions` array of strings instead of a single string.
   - Refactored `SalesOrgMapScreen`'s assignment logic to append new zones to a user's `orgPositions` array rather than overwriting.
   - Refactored `OrgMemberDataSheet` to include a "Remove From This Position" button, allowing safe removal of a single zone without wiping the user's other assignments.
10. **Deployment & CI/CD Setup**:
    - Created `digitalocean_deployment_guide.md` covering PM2, Nginx reverse proxy, and SSL configuration.
    - Successfully synced and pushed all recent layout, bug-fix, and backend features to the remote GitHub repository (`main` branch).
11. **`_confirmRemove` Compilation Bug Fix (5 Mar 2026)**:
    - Fixed `sales_org_map_screen.dart` line 908 — `_remove(user)` was missing the required `slotKey` argument.
    - Updated `_confirmRemove(User user)` → `_confirmRemove(User user, String slotKey)` and passed `slotKey` through all call sites.
12. **Dashboard Stage 9/10 Duplication Fix (5 Mar 2026)**:
    - In `dashboard_screen.dart`, STAGE 9 ("DA Assignment") and STAGE 10 ("Loading") both pointed to `LogisticsHubScreen`.
    - Merged them into a single `STAGE 9: Dispatch & Load`.
    - Renumbered old STAGE 11 ("Delivery Ack") → `STAGE 10`.
    - Total Supply Chain Lifecycle stages reduced from 11 → 10.
13. **Sales Org Map Atomic Endpoints Fix (5 Mar 2026)**:
    - **Root Cause**: The generic `PATCH /api/users/:id` used `$set` to replace the entire `orgPositions` array. When multiple zones were assigned/removed in parallel, race conditions caused all other zone assignments to be wiped.
    - **Backend Fix** (`server.js`): Created two new dedicated endpoints:
      - `PATCH /api/users/:id/org-add` → Uses MongoDB `$addToSet` to atomically add a single slot key without touching existing positions.
      - `PATCH /api/users/:id/org-remove` → Uses MongoDB `$pull` to atomically remove a single slot key without touching other positions.
    - **Frontend Fix** (`sales_org_map_screen.dart`): Replaced the old `_patchUser()` method (which sent the full `orgPositions` array) with:
      - `_orgAdd(userId, slotKey)` → calls `/users/:id/org-add`
      - `_orgRemove(userId, slotKey)` → calls `/users/:id/org-remove`
    - **Deployment**: Pushed to GitHub (`main` branch), SSHed into DigitalOcean Droplet, pulled changes, and restarted PM2 production cluster. Verified server online with MongoDB connected.
    - **Deployment Commands Used**:
      ```bash
      # Local → GitHub
      git add .
      git commit -m "fix: atomic org-add/org-remove for Sales Org Map"
      git push origin main

      # DigitalOcean Droplet
      ssh root@<DROPLET_IP>
      cd /root/Job
      git stash                    # Stash local server changes
      git pull origin main         # Pull latest from GitHub
      pm2 restart nexus-production # Restart both cluster instances
      pm2 logs nexus-production --lines 10  # Verify startup
      ```
    - **Server Info**: DigitalOcean Droplet `ubuntu-s-1vcpu-2gb-70gb-intel-blr1-01`, PM2 processes: `nexus-production` (cluster, ID 0 & 1), `nexus-uat` (fork, ID 2). Backend path: `/root/Job/backend/`.

14. **Order Survival & Architecture Hardening (6 Mar 2026)**:
    - **Back-to-Back Backend Hardening**: Audited `nexus_provider.dart` and added mandatory JWT token passing to all remaining endpoints (Analytics, Procurement, Logistics, Categories, Fleet Intelligence). 
    - **Removed Local Fallbacks**: Eliminated the buggy local fallback logic in `updateOrderStatus`, `createProcurementEntry`, and `assignLogistics` that was masking server errors as offline successes.
    - **Security & User Attribution**: Secured photo uploads and order fetches with `verifyToken` on the backend. Strictly enforced `userId` extraction from JWT for data integrity.

15. **Gemini AI Credit Insights Refinement (6 Mar 2026)**:
    - **Sophisticated Prompts**: Re-engineered `geminiService.js` to provide high-level risk assessments.
    - **Deep Data Injection**: The AI now ingests full **aging buckets** (0-30, 31-90, 90+ days), itemized order breakdowns (SKU, Qty, Rate), and complex ratios (Exposure Ratio, Overdue vs. Outstanding %).
    - **Output Structure**: Enforced a 4-part analytical structure: RISK SCORE, CORE ANALYSIS, DECISION, and JUSTIFICATION.

16. **Order Archive Mission Timeline (6 Mar 2026)**:
    - **Sequential Process Flow**: Integrated a "Mission Timeline" in `OrderArchiveScreen.dart`.
    - **Detail Dialog**: Clicking an order log now opens a dialog showing the sequential history of all actions performed on that order by different users with precise timestamps.

17. **Photo Integration & UI/UX (6 Mar 2026)**:
    - **Visual Evidence**: Integrated `salesPhotos` and `qcPhoto` display into both `OrderDetailsScreen` and `OrderArchiveScreen` for cross-role transparency (Admin/RSM/ASM).

18. **UAT Connection Debugging & Documentation**:
    - **MongoDB Encoding**: Identified that the UAT connection failure was caused by an un-encoded '@' symbol in the MongoDB password.
    - **Fix documented**: Update `.env` with encoded values (`sam@2025` -> `sam%402025`).

19. **Excel Export Refinements & Fixes (Mar 2026)**:
    - **Token Authentication**: Implemented robust Token Passing via `master_actions.dart` & `nexus_provider.dart` for all GET requests and Excel Imports. Fixed 401 Unauthorized errors affecting data load.
    - **Customer & OD Master**: Restructured the Export functionalilty in `CustomerMasterScreen`. Now creates a multi-sheet Excel file with **Customer Master** (format matching backend bulk import template) and **OD Master** (aging buckets, OD limits, diffs).
    - **Material Master (SKU)**: Replaced empty template download with dynamic Data Export. Maps `Product` model to legacy SKU Master column headers (`ProductCode`, `Specie`, `Packing`, `MRP`, `GST%`).
    - **Bug Fix**: Addressed undefined getter `isActive` on `Customer` model during export by replacing it with the `status` string field.

20. **Material Master Upload Fix & Excel Templates (13 Mar 2026)**:
    - **Robust Backend Parsing**: Rewrote `/api/products/bulk-import` in `server.js` with flexible header matching (trimmed lowercase) and a guaranteed **positional fallback** for all 16 columns. Handles `ProductCode`, `Product Name`, `ProductShortName`, `DistributionChannel`, `Specie`, `Weight Packing`, `Weight`, `Packing`, `MRP`, `GST%`, `HSNCODE`, `COUNTRY OF ORIGIN`, `Shelf Life in days`, `REMARKS`, `YC70`, `Processing Charges`.
    - **Seed File Generated**: Created `seed_material_master.xlsx` (520 rows) from user's raw tab-separated data using `exceljs`. Placed in `C:\Users\AIA\Desktop\BIGSAMS\`.
    - **Standardized Import Templates**: Generated 3 ready-to-use `.xlsx` template files with headers and sample data:
      - `Template_Material_Master.xlsx` (16 columns)
      - `Template_Distributor_Price.xlsx` (11 columns: Code, Name, Material, Material Number, MRP, in Kg, % GST, Retailer Margin On MRP, Dist Margin On Cost, Dist Margin On MRP, Billing Rate)
      - `Template_Customer_OD_Master.xlsx` (22 columns: CustomerID through >180 aging buckets)
    - All templates stored in project root `C:\Users\AIA\Desktop\BIGSAMS\`.

21. **User Master & Delivery Person UI/UX Overhaul (13 Mar 2026)**:
    - **New Screen: `user_master_screen.dart`**: Created a dedicated premium screen for User management, matching the `CustomerMasterScreen` aesthetic. Features:
      - Metric cards (Total Users, Admins, Sales Team).
      - Frozen "User Name" column with synced horizontal/vertical scroll.
      - Role filter chips (ALL, Admin, Sales, RSM, ASM, Sales Executive, Warehouse, Delivery Team).
      - Search by User ID, Name, Zone.
      - Expandable `RowDetailPanel` showing full user profile (ID, Role, Zone, Location, Dept, Channel, WhatsApp, Manager).
      - Role badges with color coding (Admin=red, Warehouse=green, others=indigo).
    - **New Screen: `delivery_master_screen.dart`**: Specialized view filtered to `UserRole.deliveryTeam` members only. Features:
      - Metric cards (Total Drivers, On Duty, Regions).
      - Frozen "Person Name" column.
      - Table columns: Staff ID, Zone/Region, Location, WhatsApp, Status.
      - Detail panel with delivery-specific fields.
    - **Route Registration**: Added `/user-master` and `/delivery-master` routes in `main.dart`.
    - **Master Terminal Integration**: Updated `master_data_screen.dart` to navigate to the new dedicated screens when tapping "USER MASTER" and "DELIVERY PERSON" tabs.
    - **Bug Fix**: Fixed `RangeError` crash caused by empty `_selectedTab` default. Changed default to `''` (empty) and added safety check in title formatting to display "Master Terminal" when no tab is selected.

## 📊 Enterprise Core Gap Analysis (Mission Lifecycle)

Based on the audit of the **Animesh-OMS Enterprise Core** scope, the following functional gaps are identified for implementation in this branch:

### 🏗️ Pillar Gaps
- **Commercial**: Automated **Horeca vs. Retail** price list engine and **STN (Stock Transfer)** flows.
- **Finance**: **Automatic Credit Locking** for overdue clients and aging penalty logic.
- **Fulfillment**: **BOM (Bill of Materials)** for production and **Packaging Inventory** (Boxes/Ice) tracking.
- **Logistics**: **AI Route Optimization** for mission clustering and **Driver GPS/Map** integration.

### 🔄 10-Stage Mission Gaps
- **Stage 1 (Demand)**: WhatsApp confirmation triggers.
- **Stage 3 (WH Assignment)**: Proximity-based auto-warehouse selection.
- **Stage 7 (Routing)**: AI clustering of orders into vehicle loads.
- **Stage 9 (Reconciliation)**: **RTV (Return to Vendor)** flow and damaged/usable inventory sorting.
- **Stage 10 (Analytics)**: **Order-to-Cash (O2C)** cycle time dashboards.

## 🏁 Next Steps / Remaining Tasks
- [x] Implement Bulk Dispatch API for Logistics Hub.
- [x] Refactor Book Order UI (Hierarchy removal + Photo slot enhancements).
- [x] Resolve "Missing Orders" by removing local fallbacks and fixing Auth headers.
- [x] Harden Backend security and implement strict user attribution.
- [x] Refine Gemini AI Credit Insights with full aging buckets and items.
- [x] Integrate Mission Timeline into Order Archive.
- [x] Material Master Upload Fix (robust header parsing + positional fallback).
- [x] Excel Import Templates for all Master Data (Material, Customer/OD, Distributor Price).
- [x] User Master & Delivery Person premium UI/UX screens.
- [ ] Implement **Customer Edit/Update** functionality (specifically for updating Email Id like `testing@bigsams.in`).
- [ ] Expansion of the Logistics Cost Calculator for remote areas.
- [ ] Verify UAT restoration using the encoded MongoDB password.
- [ ] Git push latest changes and deploy to VPS (User Master, Delivery Master, Templates, Material Master upload fix).

---

**Current Status**: All Master Data screens now have premium UI/UX parity (Customer, Material, OD, Distributor Price, User, Delivery Person). Material Master bulk import is hardened with robust header detection and positional fallback. Standardized Excel templates are available for all import types. Pending: Git push & VPS deployment of latest changes.
