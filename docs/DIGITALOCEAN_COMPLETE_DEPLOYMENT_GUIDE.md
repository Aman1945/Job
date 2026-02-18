# 🚀 DigitalOcean Complete Deployment Guide

**Nexus OMS - Production Ready ho jayega!**

Yeh guide aapko **step-by-step** sikhayegi ki kaise apna pura application DigitalOcean pe deploy karein.

---

## 📋 Table of Contents

1. [Pre-Deployment Checklist](#1-pre-deployment-checklist)
2. [DigitalOcean Account Setup](#2-digitalocean-account-setup)
3. [Infrastructure Planning](#3-infrastructure-planning)
4. [Create Droplet (Server)](#4-create-droplet-server)
5. [Setup Managed MongoDB](#5-setup-managed-mongodb)
6. [Setup Spaces (Photo Storage)](#6-setup-spaces-photo-storage)
7. [Server Configuration](#7-server-configuration)
8. [Deploy Backend Code](#8-deploy-backend-code)
9. [Database Migration](#9-database-migration)
10. [Configure Nginx & SSL](#10-configure-nginx--ssl)
11. [Flutter App Configuration](#11-flutter-app-configuration)
12. [Testing & Verification](#12-testing--verification)
13. [Monitoring & Maintenance](#13-monitoring--maintenance)

---

## 1. Pre-Deployment Checklist

### ✅ Local System Ready Hai?

**Backend:**
- [ ] Git repository updated hai
- [ ] All features tested hain locally
- [ ] Environment variables documented hain
- [ ] Database schema finalized hai

**Credentials Tayar Karo:**
```
GitHub Repository: https://github.com/Aman1945/Job.git
Local MongoDB Data: Export kar lo backup mein
API Keys: Gemini API key ready rakho
```

**Required Tools:**
- [ ] PuTTY installed (SSH client for Windows)
- [ ] MongoDB Compass (database GUI)
- [ ] Postman (API testing)

---

## 2. DigitalOcean Account Setup

### Step 1: Sign Up

1. **Website pe jao:** https://www.digitalocean.com/
2. **Sign Up** button click karo
3. Email aur password enter karo
4. Email verification karo

### Step 2: Billing Setup

1. **Billing → Payment Methods** pe jao
2. Credit/Debit card add karo
3. **$200 free credit** milega (60 days valid)

> **💡 Pro Tip:** GitHub Student Pack se apply karo for extra credits!

---

## 3. Infrastructure Planning

### 🏗️ Kya Chahiye?

| Component | Purpose | Recommended Plan | Monthly Cost |
|:----------|:--------|:-----------------|:-------------|
| **Droplet** | Backend server | Basic ($6/mo) | $6 |
| **Managed MongoDB** | Database | Basic ($15/mo) | $15 |
| **Spaces** | Photo storage | 250GB ($5/mo) | $5 |
| **Backups** | Droplet backup | 20% extra | $1.20 |
| **Total** | | | **~$27.20/month** |

### Droplet Specs (Basic Plan):
```
CPU: 1 vCPU
RAM: 1GB
SSD: 25GB
Transfer: 1000GB
```

> **⚠️ Important:** Ye small traffic ke liye hai. Agar zyada users hain, upgrade karna padega.

---

## 4. Create Droplet (Server)

### Step-by-Step Droplet Creation

1. **Dashboard → Create → Droplets** pe click karo

2. **Choose Region:**
   - Select: **Bangalore, India** (IN1) - Lowest latency for India

3. **Choose Image:**
   - Select: **Ubuntu 22.04 LTS**

4. **Choose Size:**
   - Select: **Basic** plan
   - CPU Option: **Regular** 
   - $6/month - 1GB RAM / 1 vCPU / 25GB SSD

5. **Choose Authentication:**
   - Select: **Password** (easier for beginners)
   - Enter a strong password (save it securely!)
   - Alternative: SSH Key (more secure, advanced)

6. **Finalize Details:**
   - Hostname: `nexus-oms-server`
   - Tags: `production`, `backend`
   - Enable: ☑ **Monitoring** (free)
   - Enable: ☑ **Automated Backups** (+20% cost)

7. **Click "Create Droplet"**

**Wait 1-2 minutes** for droplet creation.

### Save These Details:

```
Droplet IP Address: xxx.xxx.xxx.xxx (you'll get this)
Username: root
Password: [your chosen password]
```

---

## 5. Setup Managed MongoDB

### Step-by-Step Database Creation

1. **Dashboard → Create → Databases** pe click karo

2. **Choose Database Engine:**
   - Select: **MongoDB**
   - Version: **6.0** (latest stable)

3. **Choose Region:**
   - Same as Droplet: **Bangalore, India**

4. **Choose Plan:**
   - Select: **Basic** plan
   - $15/month - 1GB RAM / 10GB Storage / 1 Node

5. **Finalize Details:**
   - Database Cluster Name: `nexus-oms-db`
   - Tags: `production`, `database`

6. **Click "Create Database Cluster"**

**Wait 5-10 minutes** for database provisioning.

### Connection Details (Save These):

DigitalOcean will show you connection strings:

```bash
# Connection String Format:
mongodb+srv://doadmin:[PASSWORD]@nexus-oms-db-xxxxx.db.ondigitalocean.com/admin?tls=true&authSource=admin

# Replace [PASSWORD] with your actual password
# Database name: nexus_oms (create karna padega)
```

### Create Database:

1. **MongoDB Compass** open karo
2. DigitalOcean connection string paste karo
3. Connect karo
4. **Create Database:** `nexus_oms`

---

## 6. Setup Spaces (Photo Storage)

### Step-by-Step Spaces Creation

1. **Dashboard → Create → Spaces** pe click karo

2. **Choose Region:**
   - Select: **Bangalore** (same region)

3. **Configure Spaces:**
   - Enable CDN: ☑ **Yes** (faster image loading)
   - Space Name: `nexus-oms-photos`
   - Restrict File Listing: ☑ **Yes** (security)

4. **Click "Create a Space"**

### Generate API Keys:

1. **API → Spaces Keys → Generate New Key**
2. Key Name: `nexus-backend-key`
3. **Save these securely:**

```bash
Spaces Access Key: XXXXXXXXXXXXXXXXXXXX
Spaces Secret Key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Bucket Name: nexus-oms-photos
Endpoint: blr1.digitaloceanspaces.com
CDN URL: https://nexus-oms-photos.blr1.cdn.digitaloceanspaces.com
```

---

## 7. Server Configuration

### Step 1: SSH into Droplet

**Using PuTTY (Windows):**

1. Open PuTTY
2. **Host Name:** Your Droplet IP (e.g., `164.52.200.100`)
3. **Port:** 22
4. **Connection Type:** SSH
5. Click **Open**
6. Login as: `root`
7. Password: [Your droplet password]

### Step 2: Update System

```bash
# Update package lists
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git build-essential
```

### Step 3: Install Node.js

```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node -v   # Should show v18.x.x
npm -v    # Should show 9.x.x
```

### Step 4: Install PM2 (Process Manager)

```bash
# Install PM2 globally
sudo npm install -g pm2

# Verify
pm2 -v
```

### Step 5: Install Nginx (Reverse Proxy)

```bash
# Install Nginx
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx
```

### Step 6: Configure Firewall

```bash
# Allow SSH, HTTP, HTTPS
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Check status
sudo ufw status
```

---

## 8. Deploy Backend Code

### Step 1: Clone Repository

```bash
# Navigate to home
cd /root

# Clone your repo
git clone https://github.com/Aman1945/Job.git
cd Job/backend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Create .env File

```bash
nano .env
```

**Paste this (update with your actual values):**

```bash
# Server
PORT=3000
NODE_ENV=production

# MongoDB (DigitalOcean Managed)
MONGODB_URI=mongodb+srv://doadmin:[YOUR_DB_PASSWORD]@nexus-oms-db-xxxxx.db.ondigitalocean.com/nexus_oms?tls=true&authSource=admin

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# DigitalOcean Spaces
DO_SPACES_ACCESS_KEY=YOUR_SPACES_ACCESS_KEY
DO_SPACES_SECRET_KEY=YOUR_SPACES_SECRET_KEY
DO_SPACES_BUCKET=nexus-oms-photos
DO_SPACES_ENDPOINT=blr1.digitaloceanspaces.com
DO_SPACES_CDN_URL=https://nexus-oms-photos.blr1.cdn.digitaloceanspaces.com

# Gemini AI
GEMINI_API_KEY=YOUR_GEMINI_API_KEY

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

**Save:** Press `Ctrl+X`, then `Y`, then `Enter`

### Step 4: Start Backend with PM2

```bash
# Start app
pm2 start server.js --name nexus-backend

# Save PM2 config (auto-restart on reboot)
pm2 save
pm2 startup

# Check status
pm2 status
pm2 logs nexus-backend
```

### Step 5: Test Backend

```bash
# Test locally on server
curl http://localhost:3000/api/health

# Should return: {"status":"ok"}
```

---

## 9. Database Migration

### Step 1: Export Local Data

**On your local Windows machine:**

```bash
# Open Command Prompt
cd C:\Users\Dell\Desktop\NEW JOB\backend

# Export all collections
mongodump --db nexus_oms --out ./backup
```

### Step 2: Import to DigitalOcean

**Using MongoDB Compass:**

1. Connect to DigitalOcean MongoDB (connection string from Step 5)
2. Select `nexus_oms` database
3. For each collection:
   - Click **Import Data**
   - Select JSON file from backup
   - Click **Import**

**Collections to import:**
- users
- customers
- products
- orders
- (any other collections you have)

### Step 3: Verify Data

```bash
# On server, test connection
cd /root/Job/backend
node -e "require('dotenv').config(); const mongoose = require('mongoose'); mongoose.connect(process.env.MONGODB_URI).then(() => console.log('DB Connected!')).catch(e => console.log(e));"
```

---

## 10. Configure Nginx & SSL

### Step 1: Create Nginx Config

```bash
sudo nano /etc/nginx/sites-available/nexus-oms
```

**Paste this:**

```nginx
server {
    listen 80;
    server_name YOUR_DROPLET_IP;  # Replace with your IP or domain

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

**Save and exit**

### Step 2: Enable Config

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/nexus-oms /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 3: Test Public Access

Open browser on your laptop:
```
http://YOUR_DROPLET_IP/api/health
```

Should return: `{"status":"ok"}`

---

## 11. Flutter App Configuration

### Update API Config

**File:** `flutter/lib/config/api_config.dart`

```dart
class ApiConfig {
  // Production server
  static const String baseUrl = 'http://YOUR_DROPLET_IP/api';
  
  // For testing
  // static const String baseUrl = 'http://localhost:3000/api';
}
```

### Rebuild Flutter App

```bash
cd flutter
flutter clean
flutter pub get
flutter run
```

---

## 12. Testing & Verification

### Backend API Testing

**Using Postman:**

1. **Health Check:**
   ```
   GET http://YOUR_DROPLET_IP/api/health
   ```

2. **Login Test:**
   ```
   POST http://YOUR_DROPLET_IP/api/auth/login
   Body: {
     "id": "animesh.jamuar@bigsams.in",
     "password": "password123"
   }
   ```

3. **Get Users:**
   ```
   GET http://YOUR_DROPLET_IP/api/users
   ```

### Flutter App Testing

1. **Login:** Animesh credentials
2. **Dashboard:** Verify all data loads
3. **Create Order:** Test order creation
4. **Upload Photo:** Test image upload to Spaces

---

## 13. Monitoring & Maintenance

### Check Server Health

```bash
# SSH into server
ssh root@YOUR_DROPLET_IP

# Check PM2 status
pm2 status

# View logs
pm2 logs nexus-backend

# Restart if needed
pm2 restart nexus-backend
```

### Monitor Resources

DigitalOcean Dashboard:
- CPU usage
- Memory usage
- Network traffic
- Disk usage

### Backup Strategy

**Automated Backups:**
- Droplet: Weekly snapshots (enabled)
- MongoDB: Daily backups (Managed DB feature)
- Spaces: Versioning enabled

**Manual Backup:**
```bash
# Export database
mongodump --uri="YOUR_MONGODB_CONNECTION_STRING" --out=/root/backups/$(date +%Y%m%d)
```

---

## 🎯 Quick Reference

### SSH Access:
```bash
ssh root@YOUR_DROPLET_IP
```

### PM2 Commands:
```bash
pm2 status              # Check status
pm2 logs nexus-backend  # View logs
pm2 restart nexus-backend  # Restart
pm2 stop nexus-backend  # Stop
pm2 monit              # Real-time monitoring
```

### Nginx Commands:
```bash
sudo systemctl status nginx   # Check status
sudo systemctl restart nginx  # Restart
sudo nginx -t                # Test config
sudo tail -f /var/log/nginx/error.log  # View errors
```

### Update Code:
```bash
cd /root/Job
git pull origin main
cd backend
npm install
pm2 restart nexus-backend
```

---

## 🚨 Troubleshooting

### Backend Not Starting?
```bash
pm2 logs nexus-backend --lines 50
# Check for MongoDB connection errors
```

### Database Connection Failed?
```bash
# Verify MongoDB connection string in .env
cat /root/Job/backend/.env | grep MONGODB_URI
```

### Nginx 502 Error?
```bash
# Check if backend is running
pm2 status
curl http://localhost:3000/api/health
```

### Out of Memory?
```bash
# Check memory
free -h

# Upgrade Droplet to 2GB RAM plan
```

---

## 💰 Cost Optimization Tips

1. **Use MongoDB Atlas Free Tier** initially (512MB free)
2. **Resize Droplet** after testing actual load
3. **Spaces:** Enable lifecycle policies to delete old files
4. **Monitoring:** Use DigitalOcean monitoring (free)

---

## ✅ Final Checklist

Before going live:
- [ ] All API endpoints tested
- [ ] Flutter app connected to production
- [ ] Database migrated and verified
- [ ] File uploads working (Spaces)
- [ ] Backups enabled
- [ ] Monitoring set up
- [ ] PM2 auto-restart configured
- [ ] Nginx properly configured
- [ ] Firewall rules set
- [ ] SSL certificate (if domain available)

---

**Congratulations! 🎉 Your Nexus OMS is now LIVE on DigitalOcean!**

**Support Contact:**
- DigitalOcean Docs: https://docs.digitalocean.com/
- Community: https://www.digitalocean.com/community/

---

**Last Updated:** February 2026
