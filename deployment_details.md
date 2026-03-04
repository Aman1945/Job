# NexuSOMS Production Architecture - DigitalOcean (High Load)

This setup is optimized for your team of **40 concurrent users** and **400+ daily photo uploads**.

## 🏗️ The 3-Tier Architecture

| Component | Technology | Purpose |
|-----------|------------|---------|
| **1. Application Server** | **Droplet (Premium Intel)** | **4GB RAM / 2 vCPUs** ($24/mo) to handle 40+ active sales members. |
| **2. Database** | **Managed MongoDB** | Securely stores all user data, orders, and products with 24/7 backups. |
| **3. File Storage** | **DO Spaces (S3)** | **CRITICAL**: To store 400+ photos daily. Without this, your server will crash in a week. |

---

## 🛠️ What I Need From You (Checklist)

Please provide these **exact details** when they are ready in your dashboard:

### ✅ 1. For the Server (Droplet)
- [ ] **IP Address** (e.g., `159.223.x.x`)
- [ ] **Password** (The one you set during creation)

### ✅ 2. For the Storage (Spaces)
- [ ] **Bucket Name** (e.g., `nexus-oms-storage`)
- [ ] **Region** (e.g., `blr1`)
- [ ] **Access Key** (Generated in API section)
- [ ] **Secret Key** (Generated with Access Key)

### ✅ 3. For the Database (Managed MongoDB)
- [ ] **Connection String** (URI)

---

## 🚀 Why 4GB RAM & Premium Intel?
1. **Concurrent Users**: 40 people using the app at once means 40 active connections. 4GB RAM keeps the server smooth.
2. **NVMe Storage**: Premium Intel comes with NVMe SSD which is much faster for processing the 400+ photos uploaded daily.
3. **DO Spaces**: We will move all photos to the cloud (Spaces). This makes the app 10x faster for the users.
