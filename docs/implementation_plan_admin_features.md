# Implementation Plan: Admin Rights & Step Bypass

This plan introduces full administrative control for the "Admin" role (intended for Animesh), allowing management of user roles and the ability to bypass any stage in the order workflow.

## Proposed Changes

### Backend

#### [MODIFY] [server.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/server.js)
- Add a route `PATCH /api/users/:id/role` restricted to `Admin` role to update a user's role.
- Modify `PATCH /api/orders/:id` to allow `Admin` users to update the `status` field to any value, bypassing the default role-based state machine logic.
- Ensure the `Auth` middleware is used to verify the `Admin` role for these sensitive operations.

### Frontend (Flutter)

#### [NEW] [AdminUserManagementScreen](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/screens/admin_user_management_screen.dart)
- A screen reachable only by `Admin` users.
- Displays a list of all users.
- Allows the Admin to select a user and change their role from a dropdown (using the `enum` from the model).

#### [MODIFY] [order_details_screen.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/screens/order_details_screen.dart)
- If the logged-in user is an `Admin`, show an "Admin Bypass" section.
- This section will contain a dropdown of all possible order statuses.
- Selecting a status and clicking "Move to This Step" will hit the backend to force-update the order status.

## Verification Plan

### Manual Verification
1. **User Role Management**:
   - Log in as `Admin`.
   - Go to the User Management screen.
   - Select a user (e.g., a Sales person) and change their role to `Credit Control`.
   - Log in as that user and verify they now see the Credit Control dashboard.
2. **Workflow Bypass**:
   - Log in as `Admin`.
   - Find an order in `Pending` status.
   - Use the "Admin Bypass" tool to move it directly to `Ready for Invoicing`.
   - Verify the order status and history have been updated correctly.
