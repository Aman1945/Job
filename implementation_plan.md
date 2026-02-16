# SCM Architecture Alignment & Model Synchronization

We need to align our project with the professional standards found in the reference directory. This includes upgrading our data models and refining the Mission Lifecycle stages.

## Proposed Changes

### [Backend] Data Models
#### [MODIFY] [User.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/models/User.js)
- Add fields: `location`, `department1`, `department2`, `channel`, `whatsappNumber`, `grossMonthlySalary`.

#### [MODIFY] [Customer.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/models/Customer.js)
- Sync fields from reference: `securityChqStatus`, `distributionChannel`, `customerClass`, `location`, `constitution`.

#### [MODIFY] [Product.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/models/Product.js)
- Ensure all fields like `specie`, `productWeight`, `mrp`, `hsnCode`, `gst` are fully supported.

---

### [Flutter] Models & UI
#### [MODIFY] [models.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/models/models.dart)
- Update Dart classes to match backend changes.
- Update `UserRole` enum if necessary.

#### [MODIFY] [dashboard_screen.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/screens/dashboard_screen.dart)
- Update Stage 3.5 to its own `QualityControlScreen` instead of `LiveOrdersScreen`.
- Refine Stage 4 cost alert logic.

---

## Verification Plan

### Automated Tests
- Run `node migrate.js` to ensure the new schema doesn't break data seeding.
- Run `flutter analyze` to ensure no model mismatches.

### Manual Verification
1. Login as a user with `location: North` and verify the dashboard filters accordingly.
2. Create a test order with logistics cost > 15% and verify the "High Cost Alert".
