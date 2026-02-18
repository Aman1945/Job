# Role-Based Step Bypass - Implementation Plan

## Problem

Currently dashboard access is **hardcoded per email/role**. For example:
- Pranav can ONLY see WH Assignment
- Dheeraj can ONLY see QC
- Lavin can ONLY see Logistics

**User wants:** Admin should assign workflow steps dynamically from the app. If Admin gives Sudip steps 1-7, Sudip can do EVERYTHING solo — no dependency on others.

---

## Current Lifecycle Steps (10 Total)

| Step | Label | Default Roles |
|:-----|:------|:-------------|
| STAGE 0 | New Customer | Sales, Admin |
| STAGE 1 | Book Order | Sales, Admin |
| STAGE 1.1 | Stock Transfer | Sales, Admin |
| STAGE 1.5 | Clearance | Sales, Admin |
| STAGE 2 | Credit Control | Credit Control, Admin |
| STAGE 2.1 | Credit Alerts | Credit Control, Admin |
| STAGE 3 | Warehouse Operations | Warehouse, WH House, WH Manager, Admin |
| STAGE 3.5 | Quality Control (QC) | QC Head, Admin |
| STAGE 4 | Logistics Costing | Logistics Lead, Logistics Team, Admin |
| STAGE 5 | Invoicing | ATL Executive, Billing, Admin |
| STAGE 6 | Fleet Loading (Hub) | Hub Lead, Admin |
| STAGE 7 | Delivery Execution | Delivery Team, Admin |

---

## Proposed Changes

### 1. Backend: Add `allowedSteps` to User Model
**File:** `backend/models/User.js`
- Add `allowedSteps: [String]` field (array of step labels)
- Admin API to update user's allowed steps

### 2. Backend: New API Endpoint
**File:** `backend/server.js`
- `PATCH /api/users/:id/allowed-steps` — Update user's allowed steps
- Returns updated user with allowedSteps

### 3. Flutter: Update User Model
**File:** `flutter/lib/models/models.dart`
- Add `List<String> allowedSteps` field
- Parse from JSON

### 4. Flutter: Update Admin Screen
**File:** `flutter/lib/screens/admin_user_management_screen.dart`
- Add new button "🔧 Assign Steps" in user card
- Show popup with all 12 step checkboxes
- Save selected steps to backend

### 5. Flutter: Update Dashboard
**File:** `flutter/lib/screens/dashboard_screen.dart`
- If user has `allowedSteps` not empty → show ONLY those steps
- If `allowedSteps` is empty → fallback to current role-based logic
- Admin always sees everything

---

## How It Works (Example)

### Before (Current):
```
Sudip (Sales) → Can ONLY see: New Customer, Book Order
Needs to wait for Credit Control, Warehouse, etc.
```

### After (New System):
```
Admin assigns Sudip these steps:
  ✅ Book Order
  ✅ Credit Control
  ✅ Warehouse Operations
  ✅ Quality Control (QC)
  ✅ Logistics Costing
  ✅ Invoicing

Result: Sudip can now do ALL these steps SOLO!
No waiting, no dependency on others.
```

---

## Files To Modify

1. `backend/models/User.js` — Add allowedSteps field
2. `backend/server.js` — Add API endpoint
3. `flutter/lib/models/models.dart` — Add allowedSteps to User model
4. `flutter/lib/screens/admin_user_management_screen.dart` — Add step assignment UI
5. `flutter/lib/screens/dashboard_screen.dart` — Use allowedSteps for filtering

---

## Verification

1. Admin assigns steps to a user from the app
2. User logs in and sees ONLY assigned steps
3. User can perform all assigned steps independently
4. Admin can change steps anytime
5. If no steps assigned → fallback to current role-based logic
