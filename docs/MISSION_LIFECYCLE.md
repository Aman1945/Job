# 🚀 NEXUS-OMS: Mission Lifecycle & System Architecture

This document outlines the operational workflow, roles, and system controls implemented in the Nexus Operations Management System.

---

## 🏗️ 1. Mission Lifecycle (Stage 0 to 7)

The following table represents the end-to-end supply chain progression and the specific teams responsible for each action.

| Stage # | Mission Stage | Primary Responsibility | Critical System Control |
| :--- | :--- | :--- | :--- |
| **Stage 0** | **Customer Onboarding** | Sales Team (Karanjit, Mithun, etc.) | Master KYC & Customer Data entry |
| **Stage 1** | **Order Booking** | Sales Team | Stock validation & SKU selection |
| **Stage 2** | **Credit Control** | Credit Team | Limit check & Payment approval |
| **Stage 2.5**| **Warehouse Assignment** | WH Manager (Pranav) | Allocation of order to specific location |
| **Stage 3** | **Warehouse Fulfillment** | WH House (Amit, Roshan, Parsuram, Arun) | Real-time Picking, Packing & Scanning |
| **Stage 3.5**| **Quality Control (QC)** | QC Head (Dheeraj) | Final audit & Defect check |
| **Stage 4** | **Logistics Costing** | Logistics Lead (Pratish & Team) | **HIGH COST ALERT: Flagging if > 15%** |
| **Stage 5** | **Invoicing** | Billing Team (Sandesh, Nitin, Rajesh) | Tax Invoice generation & Tally Export |
| **Stage 6** | **Fleet Loading (Hub)** | Hub Lead (Sagar & Team) | Manifest creation & Vehicle Dispatch |
| **Stage 7** | **Delivery Execution** | Delivery Team (A1 to A4 Staff) | Mobile POD Upload & Final completion |

---

---

## 👥 2. Team Hierarchy & Reporting Structure

The NexusOMS team is organized into functional units with clear reporting lines to ensure accountability and speed.

### **👑 Top Management (Admins / Approvers)**
**Animesh Jamuar / Kunal Shah / Lavin Samtani**  
*Direct oversight of all departments. Final authority on High-Cost Alerts (>15%) and system-wide overrides.*

---

### **1. Sales & Onboarding (Reporting to Admin)**
*Responsible for Stage 0 & 1.*
- Karanjit Singh
- Mithun Muddappa
- Sandeep Chavan
- Sudip Das
- Rakesh Khare
- Anil Singh
- Shravan Deshawal
- Sandeep Dubey
- Saud Qureshi (Q-Com)

### **2. Warehouse & Operations (Reporting to Pranav - WH Manager)**
*Responsible for Stage 2.5 & 3.*
- **Pranav (WH Manager):** Assignment & Allocation Lead.
- **Amit (Kurla):** Kurla Warehouse Operations.
- **Roshan (DP):** DP Warehouse Operations.
- **Amit Sharma (Delhi)::** Delhi Warehouse Operations.
- **Arun (Bangalore):** BNG Store Operations.
- **Parsuram / Harendra / Pradip:** Mumbai Store/WH Operations.

### **3. Quality Control (Reporting to Dheeraj - QC Head)**
*Responsible for Stage 3.5.*
- **Dheeraj (QC Head):** Independent audit of packed orders before dispatch.

### **4. Logistics & Costing (Reporting to Pratish Dalvi)**
*Responsible for Stage 4.*
- **Pratish Dalvi (Logistics Lead):** Freight optimization.
- Animesh (Logistics Team)
- Lawin (Logistics Team)

### **5. Billing & Invoicing (Reporting to Nitin Kadam)**
*Responsible for Stage 5.*
- **Nitin Kadam (Billing Lead/Approver):** Final invoice verification.
- Sandesh Gonbare
- Rajesh Suryavanshi
- Deepashree / ATL Executive Team

### **6. Hub & Delivery (Reporting to Sagar - Hub Lead)**
*Responsible for Stage 6 & 7.*
- **Sagar (Hub Lead):** Dispatch & Manifest Lead.
- **Staff A1:** Sachin
- **Staff A2:** Mayur
- **Staff A3:** Sagar (Field)
- **Staff A4:** Amit Sharma (Field/Outstation)

---

## 📊 3. Summary Reporting Table

| Department | Head / Lead | Team Members | Stages |
| :--- | :--- | :--- | :--- |
| **Warehouse** | Pranav | Amit, Roshan, Amit S, Arun, Parsuram, Harendra, Pradip | 2.5, 3 |
| **Logistics** | Pratish | Animesh, Lawin | 4 |
| **Billing** | Nitin | Sandesh, Rajesh, ATL Team | 5 |
| **QC Auditing** | Dheeraj | - (Independent) | 3.5 |
| **Field/Delivery**| Sagar | Sachin, Mayur, Sagar, Amit S | 6, 7 |
| **Sales Force** | Admin | Karanjit, Mithun, Sandeep, Sudip, Rakesh, etc. | 0, 1 |

---

## 🛡️ 4. Security & System Controls

- **Cost Optimization:** Any order where `Logistics Cost > 15%` of `Order Total` is automatically blocked for Admin approval.
- **Data Security:** All 34+ team members use encrypted, hashed credentials (Bcrypt).
- **Master Data:** 80+ SKUs (Salmon, Cod, Lamb) fully synchronized in the Cloud database.

---

**Generated on:** 16-Feb-2026  
**System Version:** v2.1.0 (Production)
