# UI Refinement & SCM Dashboard Alignment

This plan outlines the changes to streamline the dashboard lifecycle, improve user logout security with a confirmation dialog, and ensure the address management system is mobile-responsive.
# implementation_plan.md

# SCM Role & Workflow Refinement

This plan outlines the implementation of enhanced role-based access control (RBAC) and specific workflow logic for the NexusOMS project.

## User Review Required

> [!IMPORTANT]
> - New roles like **ATL Executive** and **Logistics Hub** will be added.
> - Warehouse views will be restricted based on the assigned Operation Head.
> - The 15% logistics cost alert will trigger a specific notification to Admin Animesh.
> - **Invoicing Row Only:** ATL Executives (Sanesh, Rajesh, Nitin, Deepashree) will see ONLY the Invoicing row in the lifecycle section.

## Proposed Changes

### Documentation
- [MODIFY] [SCM_ROLE_PLAYBOOK.md](file:///c:/Users/Dell/Desktop/NEW%20JOB/SCM_ROLE_PLAYBOOK.md): Updated with new workflow stages and personnel.
- [MODIFY] [USER_DIRECTORY.md](file:///c:/Users/Dell/Desktop/NEW%20JOB/USER_DIRECTORY.md): Added new users: Pratish Dalvi, Sanesh, Rajesh, Deepashree, Sagar, Lawin.

### Flutter (Frontend)
- [MODIFY] `flutter/lib/screens/dashboard_screen.dart`: 
    - Implement conditional row visibility based on `user.id` (email) and `user.role`.
    - Specific logic for:
        - **Sales Team:** New "Clearance" stage visibility.
        - **Credit Control:** Restricted to Pawan and Credit Control team.
        - **WH Assignment:** Restricted to Pranav (WH Manager) vs Operation Heads.
        - **QC:** Restricted to Dheeraj.
        - **Logistics Cost:** Restricted to Pratish, Animesh, Lawin.
        - **Invoicing:** Exclusive view for ATL Executives.
        - **Logistics Hub:** Restricted to Sagar and Pratish.
- [MODIFY] `flutter/lib/providers/nexus_provider.dart`: 
    - Add state handling for the "High Cost Alert" (>15%).
- [MODIFY] `flutter/lib/models/models.dart`:
    - Add `atlExecutive` to `UserRole` enum.

## Verification Plan

### Manual Verification
- **Login as ATL Executive:** Verify only "Invoicing" row is visible in Lifecycle.
- **Login as Dheeraj:** Verify only "Quality Control" is visible in Lifecycle.
- **Login as Sales:** Verify "Clearance" and "Book Order" (Utility) are visible.
- **Login as Pratish Dalvi:** Verify "Logistics Cost" and "Logistics Hub" are visible.
- **Check Alert:** Simulate a logistics cost > 15% and verify notification for Admin Animesh.
- **Logout:** Click the logout icon and verify that a confirmation popup appears. Test both "CANCEL" and "LOGOUT" (OK) action.
- **Address:** Open the "New Customer" screen on a narrow simulation/device and test adding/editing addresses. Ensure fields are easy to tap and read.
