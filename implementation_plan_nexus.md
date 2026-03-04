# Implementation Plan - Order Archive Enhancements

Enhance the Order Archive screen to support filtering by user hierarchy (NSM, RSM, ASM, Sales) and by date range using a calendar.

## Proposed Changes

### Backend (Already Done)
- Updated `/api/audit/logs` to support `role` filter and multiple `userIds`.
- Linked `User` model to audit logs query for role-based discovery.

### Flutter (Already Done)
- Updated `NexusProvider.fetchAuditLogs` to support `fromDate`, `toDate`, and `role`.

### Flutter (To Do)
- **UI Enhancements in `OrderArchiveScreen`**:
    - Add **Date Range Picker** (Calendar icon).
    - Add **RBAC/Hierarchy Picker** (Role & User selection).
    - Update fetching logic to respect filters.
    - Aesthetic improvements: emerald/slate theme, glassmorphism cards.

## Verification
- Manual testing of each filter combination.
