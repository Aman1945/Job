# 🏁 NexusOMS End-to-End Operational Guide

This guide explains how to use and verify the new Enterprise SCM features.

## 1. 📂 Master Data Management (Setup)
Before processing orders, ensure Master Data is enriched:
- **Users:** Go to `Master Data` -> `User Master`. Select a user (e.g., Animesh) and ensure their **Location** (e.g., North) and **Department** (e.g., HQ) are set.
- **Customers:** In `Customer Master`, verify fields like `GST`, `PAN`, `Customer Class`, and `Distribution Channel`.
- **Products:** In `Material Master`, ensure `HSN Code`, `GST %`, and `MRP` are correctly entered.

## 2. 🛡️ Credit Control Workflow (Verification)
1. Login as a **Sales** user (e.g., `abhijit.chavan@bigsams.in`).
2. Create an order that exceeds the credit limit.
3. Logout and Login as **Admin** or **Credit Control** (`credit.control@bigsams.in`).
4. Enter Password: `admin`.
5. Go to `Dashboards` -> `Credit Control Terminal`. 
6. You will see the order pending with a **Credit Exposure Matrix** (Outstanding vs Limit).
7. Use the **AI Risk Assessment** (powered by Gemini) to decide on approval.

## 3. 🏭 Warehouse & QC (Stage 3 & 3.5)
1. Once Credit is approved, login as **WH Manager** (`operations@bigsams.in`).
2. Go to `Live Missions`. You will see orders ready for "Warehouse Fulfillment".
3. After packing, the order moves to **Quality Control** (Stage 3.5). Login as **QC Head** (`quality@bigsams.in`) to verify the shipment.

## 4. 🚚 Logistics Hub & Delivery (Stage 6 & 7)
1. Login as **Logistics Team** (`logistics@bigsams.in`).
2. Assign a vehicle and delivery agent.
3. The order will appear in the **Delivery Execution Screen** for the assigned agent (e.g., `delivery1@bigsams.in`).
4. The agent can then mark the order as "Delivered" and upload POD (Proof of Delivery).

## 📊 Analytics & Reporting
- Check the `Executive Pulse` screen for real-time field activity and sales trends.
- Use the `PMS Screen` (Performance Management System) to see top-performing sales reps and warehouse efficiency scores.

---
**Technical Note:** All data is live on MongoDB Atlas. Any update in Flutter is synced real-time to the Backend.
