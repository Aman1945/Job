# Hardening nexus_provider.dart & Fixing Token Failures

The goal is to resolve the "lost orders" bug and fix failing photo uploads on the production server. This involves removing all remaining local fallback logic in the provider and ensuring JWT tokens are correctly passed to all secured endpoints, specifically the photo upload service.

## Proposed Changes

### [Component] Flutter Provider Layer

#### [MODIFY] [nexus_provider.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/providers/nexus_provider.dart)
- **Fix Missing Token**: Update `createOrder` to pass the `token` argument to `uploadPhoto`.
- **Remove Local Fallbacks**: 
    - In `updateOrderStatus`, remove the `catch` block logic that updates `_orders` locally and returns `true`.
    - Change `updateOrderStatus` to throw an `Exception` on non-200 status codes or network errors, consistent with `createOrder`.
- **Harden API Calls**: Ensure all methods that interact with secured backend routes (`createCustomer`, `createProduct`, `createUser`, `fetchAuditLogs`) handle tokens and errors consistently.
- **Improved Logging**: Add better debug prints for identifying why a request fails (e.g., printing response bodies on error).

---

### [Component] Flutter Screens

#### [MODIFY] [quality_control_screen.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/screens/quality_control_screen.dart)
- **Pass Token to Upload**: Update `_approveInspection` to pass `auth.token` to `provider.uploadPhoto`.

---

## Verification Plan

### Automated Tests
- None available in current project structure.

### Manual Verification
1. **Photo Upload Test**: Create a new order with photos and verify they appear in the dashboard/archive. 
2. **QC Photo Test**: Approve an inspection in the QC terminal with a photo and verify the `qcPhoto` URL is correctly saved to the order.
3. **Error Handling Test**: Temporarily disconnect from the network or use an invalid token to verify that the app shows a real error SnackBar instead of a fake success message.
4. **Order Survival Test**: Verify that orders only disappear from "Live Missions" if they are actually updated on the server.
