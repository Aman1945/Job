# 🏗️ Nexus OMS: DigitalOcean Master Integration Guide

Aapka poora system tabhi chalega jab yeh teeno cheezein (Server, DB, Photos) ek saath hongi. Is guide mein maine teeno ko jodne ka **complete plan** diya hai.

## 🔄 1. Integrated Data Flow (Kaise kaam karega?)

```mermaid
graph TD
    App[📱 Flutter App] -->|1. Upload Photo/Order| Server[🖥️ DO Droplet - Backend]
    Server -->|2. Store Photo| Spaces[📸 DO Spaces - Storage]
    Server -->|3. Save Order Link| DB[🗄️ MongoDB Atlas - Database]
    DB -.->|4. Data Confirmed| Server
    Server -.->|5. Success Response| App
```

---

## 🛠️ 2. Integrated Setup Steps (Order Matters!)

### STEP 1: Storage Pehle (Spaces)
Do this first because you need the keys to configure the server.
- **Action:** Create "Spaces" in Bangalore region.
- **Result:** You get `DO_SPACES_ACCESS_KEY` and `DO_SPACES_SECRET_KEY`.

### STEP 2: Database Setup (MongoDB)
- **Action:** MongoDB Atlas (Free) setup karein.
- **Result:** You get the `MONGODB_URI` connection string.

### STEP 3: Server Setup (Droplet)
- **Action:** Ubuntu 22.04 Droplet banayein.
- **Result:** You get a Public IP (e.g., 143.198.x.x).

---

## 🔑 3. The "Binding" (The Master .env File)

Teeno ko jodne ke liye server ke andar sirf **ek file** (`.env`) kaafi hai. Isne sabko bandha hua hai:

```env
# --- SERVER ---
PORT=3000

# --- DATABASE (Connects Droplet to MongoDB) ---
MONGODB_URI=mongodb+srv://user:pass@nexus-cluster.mongodb.net/NexusOMS

# --- PHOTO STORAGE (Connects Droplet to Spaces) ---
DO_SPACES_ACCESS_KEY=DO00XXXXXXXXX
DO_SPACES_SECRET_KEY=xxxxxxxxxxxxxxxx
DO_SPACES_BUCKET=nexus-oms-photos
DO_SPACES_ENDPOINT=blr1.digitaloceanspaces.com
DO_SPACES_CDN_URL=https://nexus-oms-photos.blr1.cdn.digitaloceanspaces.com

# --- SECURITY ---
JWT_SECRET=super-secret-key-2026
```

---

## 🚀 4. Go-Live Process

1.  **Code Clone:** Server pe `git clone` karke apna backend code le aaiye.
2.  **Config:** Upar wali `.env` file server pe banaiye aur apni keys bhariye.
3.  **Start:** `pm2 start server.js` chala kar backend ko "Always On" kijiye.
4.  **Connect App:** Flutter project mein `api_config.dart` update karke server ka IP/Domain daalo.

---

## 📂 Related Documents
- [TOTAL_DO_SETUP.md](file:///C:/Users/Dell/Desktop/NEW%20JOB/docs/TOTAL_DO_SETUP.md) - Cost breakdown.
- [DIGITALOCEAN_DEPLOYMENT_GUIDE.md](file:///C:/Users/Dell/Desktop/NEW%20JOB/DIGITALOCEAN_DEPLOYMENT_GUIDE.md) - All commands.

**Jab aap DigitalOcean par login kareinge, tab main aapko Step 1 (Spaces) se guide karna shuru karun?**
