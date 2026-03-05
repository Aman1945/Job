# NexusOMS — Full Project Context for AI Assistant

> **Paste this entire document at the start of a new AI session (Cursor, Gemini, etc.) to continue development with full context.**

---

## 🧠 Project Overview

**NexusOMS** is a full-stack Order Management System (OMS) built for a food distribution company (Big Sam's / similar FMCG). It manages the entire sales & supply chain from order booking to delivery, including QC, warehouse operations, logistics, and invoicing.

**App Type:** Flutter mobile app (Android/iOS) + Node.js REST API backend  
**Status:** Production-deployed on DigitalOcean  
**Project Folder:** `c:\Users\Dell\Desktop\NEW JOB\`

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter (Dart) — `flutter/` directory |
| **Backend API** | Node.js + Express.js — `backend/` directory |
| **Database** | MongoDB (DigitalOcean Managed MongoDB 8) |
| **File Storage** | DigitalOcean Spaces (S3-compatible CDN) |
| **Authentication** | JWT (JSON Web Tokens) |
| **Real-time** | Socket.io |
| **AI Integration** | Google Gemini AI |
| **Maps** | Google Maps Flutter |

---

## ☁️ Infrastructure (DigitalOcean)

| Service | Details |
|---|---|
| **Server (Droplet)** | IP: `168.144.31.254` |
| **SSH** | `ssh root@168.144.31.254` |
| **MongoDB** | `db-mongodb-blr1-41071` — Bangalore region |
| **DO Spaces** | `bigsams-oms-prod` — Singapore (sgp1) region |
| **CDN URL** | `https://bigsams-oms-prod.sgp1.cdn.digitaloceanspaces.com` |

---

## 🔐 Environment Variables

### Backend Production: `backend/.env.production`
```env
PORT=3000
NODE_ENV=production

MONGODB_URI=mongodb+srv://doadmin:l83c0V6pR7f59S1g@db-mongodb-blr1-41071-873a3483.mongo.ondigitalocean.com/NexusOMS?replicaSet=db-mongodb-blr1-41071&tls=true&authSource=admin

JWT_SECRET=NexusOMS@2024SecretKey#Production$Secure!
JWT_EXPIRY=7d

DO_SPACES_KEY=DO004H8FVZFL233XMGJ7
DO_SPACES_SECRET=MLda/phchslCRL+4JMmezFzuqfWdUP26pb3M20fqZ+
DO_SPACES_REGION=sgp1
DO_SPACES_BUCKET=bigsams-oms-prod
DO_SPACES_CDN_URL=https://bigsams-oms-prod.sgp1.cdn.digitaloceanspaces.com
```

### Flutter App: `flutter/lib/config/api_config.dart`
```dart
static const String productionServer = '168.144.31.254';
static String get baseUrl => 'http://$serverAddress/api';
```

---

## 📁 Project Structure

```
NEW JOB/
├── backend/
│   ├── server.js              ← Main Express server (1835+ lines)
│   ├── models/
│   │   ├── Order.js           ← salesPhotos[], qcPhoto fields added
│   │   ├── User.js
│   │   ├── Customer.js
│   │   ├── Product.js
│   │   ├── AuditLog.js
│   │   ├── DistributorPrice.js
│   │   ├── Procurement.js
│   │   ├── PackagingMaterial.js
│   │   ├── PackagingTransaction.js
│   │   └── PerformanceRecord.js
│   ├── services/
│   │   └── storageService.js  ← DO Spaces upload/delete service
│   ├── routes/
│   │   ├── auditRoutes.js
│   │   └── newFeatures.js
│   ├── .env                   ← Local dev env
│   └── .env.production        ← Production env (DO)
├── flutter/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/api_config.dart
│   │   ├── providers/
│   │   │   ├── nexus_provider.dart   ← Main state management
│   │   │   └── auth_provider.dart
│   │   ├── models/models.dart
│   │   ├── screens/              ← 39 screens
│   │   ├── widgets/
│   │   │   ├── nexus_components.dart
│   │   │   └── row_detail_panel.dart
│   │   └── utils/theme.dart
│   └── pubspec.yaml
└── docs/
```

---

## 📱 All Screens (flutter/lib/screens/)

| Screen | Purpose |
|---|---|
| `login_screen.dart` | Login with JWT |
| `dashboard_screen.dart` | Main dashboard with KPIs |
| `book_order_screen.dart` | **Sales: Create new order + 3-photo upload** |
| `live_missions_screen.dart` | View all live orders |
| `step_assignment_screen.dart` | Assign workflow steps |
| `credit_control_screen.dart` | Credit approval |
| `quality_control_screen.dart` | **QC inspection + proof photo upload** |
| `warehouse_ops_screen.dart` | Warehouse operations |
| `warehouse_selection_screen.dart` | Select warehouse |
| `warehouse_inventory_screen.dart` | Inventory management |
| `logistics_cost_screen.dart` | Logistics cost entry |
| `logistics_hub_screen.dart` | Logistics hub dashboard |
| `logistics_ops_screen.dart` | Logistics operations |
| `delivery_execution_screen.dart` | Delivery with POD photo |
| `invoicing_screen.dart` | Invoice generation |
| `tracking_screen.dart` | Shipment tracking |
| `order_details_screen.dart` | Order detail view |
| `order_archive_screen.dart` | Archived orders |
| `reporting_screen.dart` | Analytics and reports |
| `analytics_screen.dart` | Advanced analytics |
| `sales_hub_screen.dart` | Sales team dashboard |
| `sales_org_map_screen.dart` | Heatmap / org map |
| `customer_master_screen.dart` | Customer master data + Excel import |
| `material_master_screen.dart` | Product/SKU master + Excel import |
| `master_data_screen.dart` | Combined master data screen |
| `distributor_price_screen.dart` | Distributor price list |
| `procurement_screen.dart` | Procurement entries |
| `team_hierarchy_screen.dart` | Sales org hierarchy |
| `org_member_data_sheet.dart` | Member performance data |
| `admin_user_management_screen.dart` | User CRUD (Admin) |
| `credit_risk_screen.dart` | Credit risk analysis |
| `pms_screen.dart` | Performance management |
| `executive_pulse_screen.dart` | Executive KPI pulse |
| `new_customer_screen.dart` | Add new customer |
| `add_product_screen.dart` | Add new product/SKU |
| `bulk_order_screen.dart` | Bulk order creation |
| `stock_transfer_screen.dart` | Stock Transfer Note (STN) |
| `splash_screen.dart` | Splash / auth check |

---

## 👥 User Roles (RBAC)

| Role | Access |
|---|---|
| `admin` | Full access to everything |
| `rsm` | Regional Sales Manager |
| `asm` | Area Sales Manager |
| `sales` / `salesExecutive` | Books orders, own orders only |
| `credit_controller` | Credit approval |
| `warehouse` | Warehouse ops, packing, QC |
| `logistics` | Logistics cost, dispatch |
| `delivery` | Delivery execution, POD upload |
| `accounts` | Invoicing |

---

## 🔄 Order Workflow

```
Pending Credit Approval
→ Pending WH Selection → Pending Packing → Cost Added
→ Pending Invoicing → Ready for Dispatch → Out for Delivery → Delivered
```

Special statuses: `Pending Quality Control`, `Pending Logistics Cost`, `In Transit` (STN)

---

## 🗃️ Key Backend API Endpoints (server.js)

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/login` | Login, returns JWT |
| GET | `/api/orders` | Get all orders |
| POST | `/api/orders` | Create new order |
| PATCH | `/api/orders/:id` | Update order (status, any fields) |
| GET | `/api/customers` | Get customers |
| POST | `/api/customers` | Create customer |
| GET | `/api/products` | Get products |
| GET | `/api/users` | Get users |
| **POST** | **`/api/upload-photo`** | **Upload base64 image to DO Spaces** |
| GET | `/api/analytics/sales-hub` | Sales KPIs |

---

## ✅ Completed Features (Full History)

### Phase 1 – Core OMS
- Full Flutter app, JWT auth, RBAC
- Order CRUD + status workflow engine
- Customer, Product, User master data

### Phase 2 – Advanced Features
- Sales hierarchy (RSM > ASM > Sales Executive)
- Credit control, risk analysis
- Warehouse ops, QC checklist, logistics cost
- Delivery execution with POD photo
- Invoicing, analytics, reporting, PMS screens
- Google Maps heatmap
- Excel import/export for Customer and Material Master
- `row_detail_panel.dart` stacked box UI
- Distributor price list with import/export

### Phase 3 – Infrastructure
- DigitalOcean Droplet, Managed MongoDB, Spaces configured
- `storageService.js` for DO Spaces S3-compatible uploads
- **Data fully migrated: Atlas → DigitalOcean** (11 collections, 48 users, 464 customers)

### Phase 4 – Photo Upload (LATEST — March 2026)

**What changed vs original:**
- `Order.js`: Added `salesPhotos: [String]` and `qcPhoto: String` fields (NEW)
- `server.js`: Added `/api/upload-photo` endpoint (NEW)
- `nexus_provider.dart`:
  - Added `uploadPhoto(File, {folder})` method (NEW)
  - Added `patchOrderField(orderId, Map)` method (NEW)
  - `createOrder()` now accepts `photos: List<File>` + `remarks` (MODIFIED)
- `book_order_screen.dart`: `_buildDocumentationUpload()` widget replaced with 3-slot photo picker — **rest of UI UNCHANGED**
  - Slot 1: Gallery (PO copy) | Slot 2 & 3: Camera
  - Submit shows loading spinner during upload
- `quality_control_screen.dart`: Camera capture now uploads to DO Spaces on approval (MODIFIED)
  - Shows "PHOTO READY" badge, "UPLOADING PHOTO..." spinner

**DO Spaces folders:**
```
bigsams-oms-prod/
├── sales-photos/
├── qc-photos/
├── pod/
└── uploads/
```

---

## 🖥️ Server Management Commands

> **IMPORTANT: Backend files are at `/root/Job/backend/` on the server**
> PM2 app names: `nexus-production` (main, cluster) and `nexus-uat` (UAT, fork)

### 📂 FileZilla Client — Easiest way to upload files (Drag & Drop)

**Download:** [filezilla-project.org/download.php?type=client](https://filezilla-project.org/download.php?type=client)
> ⚠️ Download **FileZilla Client** — NOT FileZilla Server

**Connect to server:**
1. Open FileZilla Client
2. Top bar mein bharo:
   - **Host:** `168.144.31.254`
   - **Username:** `root`
   - **Password:** (root ka password)
   - **Port:** `22`
3. **Quickconnect** press karo
4. "Unknown host key" popup aaye → **"Always trust this host"** tick karo → **OK**
5. Right side mein `/root/Job/backend/` pe navigate karo
6. Left side se updated file drag karo → right side pe drop → overwrite karo → ✅ Done!
7. Phir PuTTY/SSH mein: `pm2 restart nexus-production`

### 🖥️ PuTTY — SSH terminal (pm2 restart, logs etc.)

**Download:** [putty.org](https://www.putty.org)
- Host: `168.144.31.254` | Port: `22` | Connection type: SSH
- Login: `root` + password

```bash
# SSH into server
ssh root@168.144.31.254
# (Enter root password when prompted)

# Check what's running
pm2 list

# Restart production backend
pm2 restart nexus-production

# View live logs
pm2 logs nexus-production --lines 30

# Stop / Start
pm2 stop nexus-production
pm2 start nexus-production

# Find where backend is
pm2 show 1 | grep "script path"
# Result: /root/Job/backend/server.js

# Check port
netstat -tlnp | grep 3000

# System info
df -h
free -m
```

### ✅ How to Deploy Backend Updates (Correct Method — SCP)

> There is NO git on the server. Use SCP from your Windows machine to copy files directly.

**Run from Windows PowerShell:**
```powershell
# Copy specific files (one at a time, enter root password each time)
scp "c:\Users\Dell\Desktop\NEW JOB\backend\server.js" root@168.144.31.254:/root/Job/backend/server.js
scp "c:\Users\Dell\Desktop\NEW JOB\backend\models\Order.js" root@168.144.31.254:/root/Job/backend/models/Order.js

# Then restart on server (SSH in):
pm2 restart nexus-production
pm2 logs nexus-production --lines 15
```

### (Optional) Set up Git on Server for easier deployments
```bash
# SSH into server first
cd /root/Job
git init
git remote add origin https://github.com/Aman1945/Job.git
git fetch origin main
git checkout -f origin/main
pm2 restart nexus-production
```

---

## ⚠️ Important Notes

1. **UI was NOT changed** in Phase 4 — only photo-related widgets modified
2. **`image_picker ^1.2.1`** already in `pubspec.yaml`
3. **25 flutter analyze warnings** — all pre-existing `withOpacity` deprecations, zero errors from new code
4. **MongoDB Atlas** is the OLD DB — DigitalOcean is now the PRIMARY production DB
5. **Gemini API key** is still a placeholder in production config
6. **Server backend path:** `/root/Job/backend/` (NOT `/var/www/nexus-oms` — that doesn't exist)
7. **PM2 app name** is `nexus-production` (NOT `nexus-backend`)

## 🚧 Next Steps / Pending

- [x] ~~Push code to server~~ — Done via SCP (server.js + Order.js copied, pm2 restart done)
- [ ] **Restart server after SCP** — run `pm2 restart nexus-production` on server
- [ ] Show `salesPhotos` in `order_details_screen.dart`
- [ ] Show `qcPhoto` in order archive/history
- [ ] Test camera permissions on real Android device (`AndroidManifest.xml` needs `CAMERA` permission)
- [ ] Set real Gemini API key in production
- [ ] Re-restrict MongoDB Atlas network access to Droplet IP only
- [ ] (Optional) Set up git on server for easier future deployments
