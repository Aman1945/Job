# 🏭 NexusOMS: SCM Enterprise Handbook (Ek Dum Detail)

This handbook details the end-to-end Supply Chain Management (SCM) lifecycle implemented in NexusOMS. Every stage is designed for industrial granularity, ensuring complete transparency from order booking to final delivery.

---

## 🛰️ 1. Mission Initiation (Order Booking)
**User Role:** Sales / Admin  
**Key Details:**
- **Tax Transparency**: Automatic **18% GST** (SGST 9%, CGST 9%) calculation.
- **Aggregate Visibility**: Sub-total and GST values are calculated in real-time.
- **Documentation**: PO/PDC upload capability for financial security.

## 💳 2. Financial Clearance (Credit Control)
**User Role:** Credit Control Specialists (Pawan, Kshama, etc.)  
**Key Details:**
- **Credit Limit Audit**: Manual verification of client outstanding.
- **Approval Protocol**: Orders must be cleared here before the Warehouse can see them.

## 🔬 3. Compliance Audit (Quality Control)
**User Role:** Dheeraj Kumar / Admin  
**Key Details:**
- **3-Point Check**:
    1. **Temperature Compliance**: Sensors/Logs verification.
    2. **Packaging Integrity**: Box seal audit.
    3. **Load Snapshot**: Photo capture of the prepared load.
- **Mission Clearance**: Audit submission is required to move to dispatch.

## 📦 4. WMS Packing Terminal
**User Role:** Pranav Manger / Warehouse Team  
**Key Details:**
- **Batch Verification**: Every SKU must be matched with its Batch No, Expiry, and Mfg Date.
- **Packaging Consumption**: Tracking of Cartons (S/L), Ice Gel Packs, and Dry Ice.
- **Bin Sync**: Items are picked from specific bin locations for inventory accuracy.

## 🚛 5. Logistics Audit (Freight Engine)
**User Role:** Lawin / Pratish Dalvi  
**Key Details:**
- **Cost Breakdown**: Segregated entry for Base Freight, Loading, and Insurance.
- **High-Cost Sentinel**: If logistics cost exceeds **15%** of order value, it triggers a **Sentinel Alert** to Admin Animesh for override.
- **Vehicle Master**: Selection from approved TATA 407 Reefers or Electric Carts.

## 🧾 6. Revenue & Invoicing
**User Role:** ATL Executives (Sandesh, Rajesh, Nitin, Dipashree)  
**Key Details:**
- **Net-Value Reconciliation**: Automatic split of Taxable vs. GST values.
- **ERP Sync**: Simulated commitment to Tally/SAP systems.
- **E-Way Bill Generation**: Preliminary validation of tax compliance.

## 🎛️ 7. Mission Control (Logistics Hub)
**User Role:** Sagar / Pratish Dalvi  
**Key Details:**
- **Regional Manifestation**: Missions are grouped into routes (Route-A, B, C).
- **Secondary Compliance**: Registry of E-Way Bill No. and Container Seal No.
- **Agent Notification**: Real-time dispatch alerts sent to Delivery Executives.

## 🏁 8. EPOD Field Execution
**User Role:** Delivery Executives  
**Key Details:**
- **OTP Handshake**: 4-digit verification code from the customer.
- **Electronic Proof**: Built-in Signature and Photo capture for proof of delivery.
- **Cash Engine**: Field entry for cash collection (COD) with reconciliation.

## 🔔 9. PROACTIVE NOTIFICATIONS (Email Sync)
**System Role:** Automated Sentinel  
**Key Trigger Points**:
1.  **High-Cost Alert**: Automatic email to Admin Animesh if logistics > 15%.
2.  **Digital Receipt**: Automated tax invoice copy sent to client upon billing.
3.  **Mission Closure**: Full EPOD statement (Proof + Cash) sent to Hub on delivery.

---

## 🛠️ Data Infrastructure
- **Models**: `Order` and `OrderItem` models extended with `batchNo`, `expiryDate`, `taxBreakdown`, and `manifestId`.
- **RBAC**: Strict role-based visibility ensures users only see their relevant terminals.

**NexusOMS | The SCM Powerhouse**
