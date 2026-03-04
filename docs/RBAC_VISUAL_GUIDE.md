# 🛡️ NexusOMS - RBAC & Hierarchy Visual Guide

Yeh guide system ke roles, permissions aur hierarchy ko diagrams ke through samjhati hai.

---

## 🏗️ 1. Organizational Hierarchy (Sales Org Map)
System mein reporting structure niche diye gaye diagram ke according hai:

```mermaid
graph TD
    CH[👑 CHAIRMAN / OWNER] --> CEO[🚀 CEO / DIR]
    CEO --> NSM[🌏 NSM - National Sales Manager]
    
    subgraph "Regional Management"
        NSM --> RSM_N[📍 RSM - NORTH]
        NSM --> RSM_S[📍 RSM - SOUTH]
        NSM --> RSM_W[📍 RSM - WEST / MUMBAI]
        NSM --> RSM_E[📍 RSM - EAST]
    end

    subgraph "Area Management"
        RSM_N --> ASM_N[🏙️ ASM]
        RSM_S --> ASM_S[🏙️ ASM]
        RSM_W --> ASM_W[🏙️ ASM]
        RSM_E --> ASM_E[🏙️ ASM]
    end

    subgraph "Ground Force"
        ASM_N --> SE_N[🏃 Sales Executive]
        ASM_S --> SE_S[🏃 Sales Executive]
        ASM_W --> SE_W[🏃 Sales Executive]
        ASM_E --> SE_E[🏃 Sales Executive]
    end

    style CH fill:#FFD700,stroke:#B8860B,stroke-width:2px,color:#000
    style CEO fill:#1ABFA1,stroke:#128C76,stroke-width:2px,color:#fff
    style NSM fill:#3B82F6,stroke:#1D4ED8,stroke-width:2px,color:#fff
```

---

## 🔄 2. Mission Lifecycle Stages (RBAC Flow)
Order creation se delivery tak, kaunsa role kis stage pe kaam karta hai:

```mermaid
sequenceDiagram
    participant S as Sales / RSM / ASM
    participant C as Credit Control
    participant W as Warehouse Team
    participant Q as QC Head
    participant L as Logistics / Hub
    participant B as Billing / ATL
    participant D as Delivery Team

    Note over S: Stage 1: Customer Creation
    Note over S: Stage 2: Order Booking
    S->>C: Order Sent for Approval
    Note over C: Stage 3: Credit Approval
    C->>W: Sent to Warehouse
    Note over W: Stage 4-5: Packing & Sorting
    W->>Q: Sent for QC
    Note over Q: Stage 6: Quality Check
    Q->>L: Update Logistics Cost
    Note over L: Stage 7: Cost Intelligence
    L->>B: Sent for Invoicing
    Note over B: Stage 8-9: Invoice & DA Assign
    B->>L: Ready for Dispatch
    Note over L: Stage 10: Loading at Hub
    L->>D: Out for Delivery
    Note over D: Stage 11: Delivery Ack (POD)
```

---

## 🛠️ 3. Dashboard Utilities Access
Roles ke access levels system hub mein:

| Role | Core Utilities Access |
| :--- | :--- |
| **Admin** | **EVERYTHING** (User Mgmt, Org Map, Master Data, etc.) |
| **Sales/RSM/ASM** | Live Missions, Executive Pulse, SKU Master, Team Hierarchy |
| **Credit Control** | Credit Alerts, Intelligence, Analytics |
| **Logistics/Hub** | Order Archive, Live Missions, Team Hierarchy |
| **Warehouse** | Live Missions, SKU Master |
| **Billing** | Live Missions, Order Archive |

---

### 🗝️ Key Points:
1.  **Hierarchy Logic:** RSM sirf apne niche waale ASMs aur Sales Executives ka data dekh sakta hai.
2.  **Zone Filtering:** North ka manager sirf North ka data dekhega (unless he is Admin).
3.  **Bypass System:** Agar koi position vacant (khali) hai, toh system automatically senior manager ko data forward kar deta hai.

---
**Generated for:** Animesh Jamuar (Admin)  
**System Version:** NexusOMS v12.5
