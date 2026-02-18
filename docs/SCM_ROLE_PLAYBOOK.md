# 📘 NexusOMS Enterprise SCM Role Playbook (Email Sync)

This playbook defines the exact credentials and usage for each stage of the **Mission Lifecycle**. All users share the default password: **`admin`**.

---

## 🏛️ 1. SALES TERMINAL (Stage 1)
**Usage:** Create orders, check customer outstanding, and track booking targets.
- **Login ID:** `abhijit.chavan@bigsams.in`
- **Login ID:** `sandeep.chavan@bigsams.in`
- **Email Status:** 🚫 **NO AUTOMATED EMAILS** (Sales team acts as initiators only).
- **Key Action:** Go to **"Book Order"**.

## 🛡️ 2. CREDIT CONTROL TERMINAL (Stage 2)
**Usage:** Verify financial health and approve/reject high-risk orders.
- **Login ID:** `credit.control@bigsams.in`
- **Login ID:** `kshama.jaiswal@bigsams.in`
- **Login ID:** `pawan.kumar@bigsams.in`
- **Email Status:** 🚫 **NO AUTOMATED EMAILS** (Internal audit only).
- **Key Action:** Access the **"Credit Control Terminal"**.

## 🏭 3. WH ASSIGNMENT & PACKING (Stage 3)
**Usage:** Select source warehouse and confirm physical packing.
- **Login ID:** `operations@bigsams.in` (WH Manager)
- **Login ID:** `amit.sharma@bigsams.in` (WH House - North)
- **Personnel:** Pranav, Amit DP, Roshan Bhosale, Arun.
- **Email Status:** 🚫 **NO AUTOMATED EMAILS** (Job execution only).
- **Key Action:** Use the **"Warehouse Fulfillment"** screen.

## 🔍 4. QUALITY CONTROL (Stage 3.5)
**Usage:** Post-packing verification (Shipment Integrity Protocol).
- **Login ID:** `quality@bigsams.in` (QC Head)
- **Login ID:** `dhiraj.kumar@bigsams.in`
- **Email Status:** 🚫 **NO AUTOMATED EMAILS**.
- **Key Action:** Go to **"Mission Control"** and filter for `Packed`.

## 💰 5. INVOICING TERMINAL (Stage 5)
**Usage:** Generate final commercial invoices and tax documents.
- **Login ID:** `sandesh.gonbare@bigsams.in`
- **Login ID:** `rajesh.suryavanshi@bigsams.in`
- **Login ID:** `nitin.kadam@bigsams.in`
- **Login ID:** `dipashree.gawde@bigsams.in`
- **Email Status:** 🚫 **NO PERSONAL EMAILS** (System sends invoice copy to **Customer** ONLY).
- **Key Action:** Access the **"Invoicing Terminal"**.

## 🚚 6. LOGISTICS HUB (Stage 6)
**Usage:** Consolidate invoices into Trip Manifests and assign vehicles.
- **Login ID:** `logistics.hub@bigsams.in` (Generic)
- **Personnel:** Sagar (Delivery), Pratish Dalvi.
- **Email Status:** ✅ **ACTIVE: HUB STATEMENT** (Receives completion EPOD report for records).
- **Key Action:** Create a manifest grouping invoices.

## 📉 7. LOGISTICS COST APPROVAL (Stage 6.5)
**Usage:** Oversee logistics expenses and approve high-cost shipments (>15%).
- **Login ID:** `animesh.jamuar@bigsams.in` (Admin/Approver)
- **Login ID:** `lavin.samtani@bigsams.in` (CEO)
- **Email Status:** ✅ **ACTIVE: SENTINEL ALERT** (Alert sent to **Animesh** for costs >15%).
- **Key Action:** Monitor the **"Logistics Cost Screen"**.

---

## 🕹️ Operational Summary Table

| Stage | Department | Status Transition | Primary Login | Email Notification |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Sales | `Draft` -> `Pending Credit` | `abhijit.chavan@bigsams.in` | 🚫 None |
| **2** | Credit | `Pending Credit` -> `Approved` | `credit.control@bigsams.in` | 🚫 None |
| **3** | WH | `Approved` -> `Packed` | `operations@bigsams.in` | 🚫 None |
| **3.5**| QC | `Packed` -> `Verified` | `quality@bigsams.in` | 🚫 None |
| **5** | Billing | `Verified` -> `Invoiced` | `nitin.kadam@bigsams.in` | 📧 **Customer** |
| **6** | Logistics| `Invoiced` -> `In Transit` | `logistics.hub@bigsams.in` | 📧 **Hub Statement** |
| **7** | Delivery | `In Transit` -> `Delivered` | `delivery1@bigsams.in` | 🏁 **EPOD Report** |
| **Alert** | Admin | **High Cost Sentinel** | `animesh.jamuar@bigsams.in` | 🚨 **Admin Alert** |
