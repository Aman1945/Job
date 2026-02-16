# 📘 NexusOMS Enterprise SCM Role Playbook

This playbook defines the exact credentials and usage for each stage of the **Mission Lifecycle**. All users share the default password: **`admin`**.

---

## 🏛️ 1. SALES TERMINAL (Stage 1)
**Usage:** Create orders, check customer outstanding, and track booking targets.
- **Login ID:** `abhijit.chavan@bigsams.in`
- **Login ID:** `sandeep.chavan@bigsams.in`
- **Key Action:** Go to **"Book Order"**. Choose a customer, add products, and submit. If the customer's credit is over-limit, the mission status will become `Pending Credit Approval`.

## 🛡️ 2. CREDIT CONTROL TERMINAL (Stage 2)
**Usage:** Verify financial health and approve/reject high-risk orders.
- **Login ID:** `credit.control@bigsams.in`
- **Login ID:** `kshama.jaiswal@bigsams.in`
- **Key Action:** Access the **"Credit Control Terminal"**. Review the `Credit Exposure Matrix` and **AI Risk Assessment**. Approve to move the mission to Warehouse.

## 🏭 3. WH ASSIGNMENT & PACKING (Stage 3)
**Usage:** Select source warehouse and confirm physical packing.
- **Login ID:** `operations@bigsams.in` (WH Manager)
- **Login ID:** `amit.sharma@bigsams.in` (WH House - North)
- **Key Action:** Use the **"Warehouse Fulfillment"** screen. Select the best warehouse for stock availability. Once packed, update status to `Packed`.

## 🔍 4. QUALITY CONTROL (Stage 3.5)
**Usage:** Post-packing verification (Shipment Integrity Protocol).
- **Login ID:** `quality@bigsams.in` (QC Head)
- **Login ID:** `dhiraj.kumar@bigsams.in`
- **Key Action:** Go to **"Mission Control"** and filter for `Packed`. Verify the shipment against the checklist (Labels, Temp, Qty). Move to Invoicing after verification.

## 💰 5. INVOICING TERMINAL (Stage 5)
**Usage:** Generate final commercial invoices and tax documents.
- **Login ID:** `nitin.kadam@bigsams.in`
- **Login ID:** `pradip.patil@bigsams.in`
- **Key Action:** Access the **"Invoicing Terminal"**. Review checked missions and "Generate Invoice". This triggers the mission to move to the Logistics Hub.

## 🚚 6. LOGISTICS HUB (Stage 6)
**Usage:** Consolidate invoices into Trip Manifests and assign vehicles.
- **Login ID:** `logistics@bigsams.in`
- **Key Action:** Go to **"Logistics Hub Screen"**. Create a manifest by grouping multiple invoices for a specific route (e.g., North Mumbai). Assign a vehicle and Delivery Team.

## 📉 7. LOGISTICS COST APPROVAL (Stage 6.5)
**Usage:** Oversee logistics expenses and approve high-cost shipments (>15%).
- **Login ID:** `animesh.jamuar@bigsams.in` (Admin/Approver)
- **Login ID:** `lavin.samtani@bigsams.in` (CEO)
- **Key Action:** Monitor the **"Logistics Cost Screen"**. If Dry Ice + Packaging costs exceed 15% of order value, a "High-Cost Alert" is triggered. Admins must override or optimize before dispatch.

---

## 🕹️ Operational Summary Table

| Stage | Department | Status Transition | Primary Login |
| :--- | :--- | :--- | :--- |
| **1** | Sales | `Draft` -> `Pending Credit` | `abhijit.chavan@bigsams.in` |
| **2** | Credit | `Pending Credit` -> `Approved` | `credit.control@bigsams.in` |
| **3** | WH | `Approved` -> `Packed` | `operations@bigsams.in` |
| **3.5**| QC | `Packed` -> `Verified` | `quality@bigsams.in` |
| **5** | Billing | `Verified` -> `Invoiced` | `nitin.kadam@bigsams.in` |
| **6** | Logistics| `Invoiced` -> `In Transit` | `logistics@bigsams.in` |
| **7** | Delivery | `In Transit` -> `Delivered` | `delivery1@bigsams.in` |
