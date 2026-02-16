# UI Refinement & SCM Dashboard Alignment

This plan outlines the changes to streamline the dashboard lifecycle, improve user logout security with a confirmation dialog, and ensure the address management system is mobile-responsive.

## Proposed Changes

### 📱 Dashboard Customization
**File:** [dashboard_screen.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/screens/dashboard_screen.dart)

- **Lifecycle Stage Removal:** Remove "STAGE 0: Customer Onboarding" and "STAGE 1: Order Booking" from the Supply Chain Lifecycle row to focus on operational fulfillment.
- **Lifecycle Stage Visibility:** Ensure "STAGE 3: WH Assignment & Packing" and "STAGE 3.5: Quality Control (QC)" are visible for all operational roles (Admin, Sales, WH, QC) to improve context and understanding.
- **Logout Confirmation:** Enhance the logout button to trigger a standard OK/Cancel confirmation dialog to prevent accidental logouts.

### 🏠 Address Management Response
**File:** [address_management_widget.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/widgets/address_management_widget.dart)

- **Mobile Optimization:** 
    - Adjust the header `Row` to handle wrapping on small screens.
    - Refactor the `_AddressDialog` to use a vertical layout for City/State fields on mobile or a more flexible wrapping logic.
    - Improve the `_buildAddressCard` layout to ensure labels and tags don't overlap on narrow displays.

## Verification Plan

### Manual Verification
- **Dashboard:** Login as different users (Sales, Admin) and verify that "Customer Onboarding" and "Order Booking" are gone from the row, while WH and QC stages are visible.
- **Logout:** Click the logout icon and verify that a confirmation popup appears. Test both "CANCEL" and "LOGOUT" (OK) action.
- **Address:** Open the "New Customer" screen on a narrow simulation/device and test adding/editing addresses. Ensure fields are easy to tap and read.
