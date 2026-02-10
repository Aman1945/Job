# NexusOMS Development & Operations Guide

Welcome to the **NexusOMS Mobile Terminal**. This guide explains the core features, design philosophy, and operational flow of the application developed so far.

## 1. Core Objectives
NexusOMS is a high-performance **Order Management System** designed for speed, precision, and visual excellence. It mimics high-tech command center terminals to provide a premium user experience for SCM (Supply Chain Management).

## 2. Operational Workflows

### A. Sales & Order Lifecycle
1. **Executive Pulse (0):** Real-time monitoring of system health (Coming Soon).
2. **Book Order (1):** Sales team creates new missions by selecting customers and adding SKUs.
3. **Credit Control (2):** Finance team reviews booking value vs. credit limits. Missions can be **Approved**, **On Hold**, or **Rejected**.
4. **WH Assign (2.5):** Logistics team selects the optimal warehouse for fulfillment.

### B. Fulfillment & Logistics
5. **Warehouse (3):** Inventory oversight and stock management.
6. **Logistics Cost (4):** Calculating transit exposures and freight costs.
7. **Invoicing (5):** Finalizing financial documents and generating invoice numbers.
8. **Logistics Hub (6):** Assigning fleet providers (Internal/Porter), drivers, and vehicles to missions.
9. **Execution (7):** Final delivery tracking and mission closure.

### C. Specialized Terminals
* **Live Missions Terminal:** A high-tech "command center" view of all active missions with real-time status updates and workflow traces.
* **Procurement Gate:** Managing inbound supplies from vendors with verification protocols.
* **Master Registry Hub:** Archival terminal for reviewing historical missions with 99.8% integrity tracking.

## 3. Key Features & UI/UX
* **Premium Dark Aesthetics:** Inspired by aerospace and fintech terminals using Slate 950/900 and Emerald/Indigo accents.
* **Actionable Hero Sections:** Every screen features high-impact metrics (e.g., Archival Standing, Supply Inbound Standing).
* **Search & Analytics:** Integrated search triggers across all terminals for "Tracing" missions by ID or Client.
* **Decision Engine:** Smart status transitions (e.g., "Invoiced" automatically triggers "Ready for Dispatch").

## 4. Technical Stack
* **Frontend:** Flutter (Dart) with a custom design system (`NexusTheme`).
* **Backend:** Node.js / Express with a centralized REST API.
* **Database:** Cloud-hosted PostgreSQL (via Render).

---
*Created by Antigravity AI for the Nexus Development Team.*
