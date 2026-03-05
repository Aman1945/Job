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
7. **Logistics & Dispatch Fix (Today)**: 
   - Implemented `POST /api/logistics/bulk-assign` backend route to handle order dispatch with manifest, eway-bill, and seal details.
   - Updated `Order.js` schema to include missing logistics fields (`manifestId`, `ewayBill`, `sealNo`, `bookingDate`).
   - Verified the "Ready for Dispatch" -> "In Transit" status transition via API testing.
8. **Book Order UI Refinement**:
   - Removed the "Assign Sales Team" hierarchy panel from `BookOrderScreen.dart` to simplify the mission creation flow.
   - Enhanced Sales Photos section: Replaced hardcoded sources with a selection modal (Camera/Gallery) for all three slots (PO Copy, Photo 2, Photo 3).

## 🏁 Next Steps / Remaining Tasks
- [x] Implement Bulk Dispatch API for Logistics Hub.
- [x] Refactor Book Order UI (Hierarchy removal + Photo slot enhancements).
- [ ] Refinement of the AI-powered Credit Insights (Gemini integration).
- [ ] Expansion of the Logistics Cost Calculator for remote areas.

---

**Current Status**: Backend is fully instrumented for logging and logistics. Frontend `BookOrderScreen` and `LogisticsHub` are optimized and verified. Project folder `NEW JOB` contains both `/backend` and `/flutter` codebases.
