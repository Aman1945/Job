# 🌊 DigitalOcean Deployment Guide - Nexus OMS

Complete step-by-step guide to deploy Nexus OMS on DigitalOcean with MongoDB and Photo Storage.

---

## 📋 Table of Contents

1. [DigitalOcean Server Setup](#1-digitalocean-server-setup)
2. [MongoDB Database Configuration](#2-mongodb-database-configuration)
3. [Photo Storage Setup](#3-photo-storage-setup)
4. [Backend Deployment](#4-backend-deployment)
5. [Domain & SSL Setup](#5-domain--ssl-setup)
6. [Monitoring & Backups](#6-monitoring--backups)

---

## 💰 Pricing Overview

| Service | Plan | Cost (Monthly) | Purpose |
|---------|------|----------------|---------|
| **Droplet (Server)** | Basic 2GB RAM | $12 | Backend API hosting |
| **MongoDB Atlas** | M0 Free Tier | $0 | Database (512MB) |
| **Spaces (Storage)** | 250GB | $5 | Photo/File storage |
| **Total** | - | **$17/month** | Complete infrastructure |

---

# 1. 🖥️ DigitalOcean Server Setup

## Step 1.1: Create DigitalOcean Account

1. Visit: **https://www.digitalocean.com/**
2. Click **"Sign Up"**
3. Enter your email and password
4. Verify email
5. Add payment method (Credit card or PayPal)
6. ✅ Get $200 free credit (60 days) for new users

---

## Step 1.2: Create a Droplet (Server)

### What is a Droplet?
A Droplet is DigitalOcean's virtual private server (VPS).

### Create Droplet:

1. **Login to DigitalOcean Dashboard**
2. Click **"Create"** → **"Droplets"**

3. **Choose an Image:**
   - Select **"Ubuntu 22.04 LTS"** (recommended)
   - This is the operating system

4. **Choose Plan:**
   - Select **"Basic"** plan
   - Choose **"Regular"** CPU
   - Select **$12/month** option:
     - 2 GB RAM
     - 1 vCPU
     - 50 GB SSD
     - 2 TB transfer

5. **Choose Datacenter Region:**
   - Select **"Bangalore"** (closest to India)
   - OR **"Singapore"** (good for Asia)

6. **Authentication:**
   - Select **"Password"** (easier for beginners)
   - Create a strong root password
   - Example: `NexusOMS@2026!`
   - **SAVE THIS PASSWORD SECURELY!**

7. **Hostname:**
   - Enter: `nexus-oms-server`

8. **Click "Create Droplet"**

9. ✅ Wait 1-2 minutes for droplet creation

10. **Note Your Droplet IP:**
    - You'll see IP address like: `143.198.123.45`
    - **SAVE THIS IP ADDRESS!**

---

## Step 1.3: Connect to Your Server

### Using Windows (PuTTY):

1. **Download PuTTY:**
   - Visit: https://www.putty.org/
   - Download and install

2. **Connect:**
   - Open PuTTY
   - Host Name: `your-droplet-ip` (e.g., 143.198.123.45)
   - Port: `22`
   - Click **"Open"**

3. **Login:**
   - Username: `root`
   - Password: (the password you created)
   - ✅ You're now connected to your server!

### Using Mac/Linux (Terminal):

```bash
ssh root@your-droplet-ip
# Enter password when prompted
```

---

## Step 1.4: Initial Server Setup

### Update System:

```bash
# Update package list
apt update

# Upgrade all packages
apt upgrade -y
```

### Install Node.js:

```bash
# Install Node.js 18.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x
npm --version   # Should show 9.x.x
```

### Install PM2 (Process Manager):

```bash
# Install PM2 globally
npm install -g pm2

# Verify installation
pm2 --version
```

### Install Git:

```bash
# Install Git
apt install -y git

# Verify installation
git --version
```

### Install Nginx (Web Server):

```bash
# Install Nginx
apt install -y nginx

# Start Nginx
systemctl start nginx
systemctl enable nginx

# Check status
systemctl status nginx
```

---

## Step 1.5: Setup Firewall

```bash
# Allow SSH
ufw allow 22/tcp

# Allow HTTP
ufw allow 80/tcp

# Allow HTTPS
ufw allow 443/tcp

# Allow Node.js (port 3000)
ufw allow 3000/tcp

# Enable firewall
ufw enable

# Check status
ufw status
```

---

# 2. 🗄️ MongoDB Database Configuration

## Option A: MongoDB Atlas (Recommended - FREE)

### Step 2.1: Create MongoDB Atlas Account

1. Visit: **https://www.mongodb.com/cloud/atlas**
2. Click **"Try Free"**
3. Sign up with email or Google
4. Verify email
5. ✅ Login to MongoDB Atlas

### Step 2.2: Create a Cluster

1. Click **"Build a Database"**
2. Select **"M0 FREE"** tier:
   - 512 MB storage
   - Shared RAM
   - **$0/month** ✅
3. Choose **Cloud Provider:**
   - Select **"AWS"**
   - Region: **"Mumbai (ap-south-1)"** (closest to India)
4. Cluster Name: `NexusOMS`
5. Click **"Create"**
6. ✅ Wait 3-5 minutes for cluster creation

### Step 2.3: Create Database User

1. Click **"Database Access"** (left sidebar)
2. Click **"Add New Database User"**
3. **Authentication Method:** Password
4. **Username:** `nexusadmin`
5. **Password:** `NexusOMS@2026` (or auto-generate)
6. **SAVE THIS PASSWORD!**
7. **Database User Privileges:** Read and write to any database
8. Click **"Add User"**

### Step 2.4: Whitelist IP Address

1. Click **"Network Access"** (left sidebar)
2. Click **"Add IP Address"**
3. **Option 1 (For Development):**
   - Click **"Allow Access from Anywhere"**
   - IP: `0.0.0.0/0`
   - ⚠️ Not recommended for production
4. **Option 2 (For Production):**
   - Add your DigitalOcean droplet IP
   - IP: `143.198.123.45` (your droplet IP)
5. Click **"Confirm"**

### Step 2.5: Get Connection String

1. Click **"Database"** (left sidebar)
2. Click **"Connect"** on your cluster
3. Select **"Connect your application"**
4. **Driver:** Node.js
5. **Version:** 4.1 or later
6. **Copy the connection string:**

```
mongodb+srv://nexusadmin:<password>@nexusoms.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

7. **Replace `<password>` with your actual password:**

```
mongodb+srv://nexusadmin:NexusOMS@2026@nexusoms.xxxxx.mongodb.net/NexusOMS?retryWrites=true&w=majority
```

8. **SAVE THIS CONNECTION STRING!**

---

## Option B: Self-Hosted MongoDB on DigitalOcean

### Step 2.6: Install MongoDB on Droplet

```bash
# Import MongoDB public key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update package list
apt update

# Install MongoDB
apt install -y mongodb-org

# Start MongoDB
systemctl start mongod
systemctl enable mongod

# Check status
systemctl status mongod
```

### Step 2.7: Secure MongoDB

```bash
# Connect to MongoDB shell
mongosh

# Create admin user
use admin
db.createUser({
  user: "nexusadmin",
  pwd: "NexusOMS@2026",
  roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
})

# Exit
exit
```

### Step 2.8: Enable Authentication

```bash
# Edit MongoDB config
nano /etc/mongod.conf

# Find and modify:
security:
  authorization: enabled

# Save and exit (Ctrl+X, Y, Enter)

# Restart MongoDB
systemctl restart mongod
```

### Connection String (Self-Hosted):

```
mongodb://nexusadmin:NexusOMS@2026@localhost:27017/NexusOMS?authSource=admin
```

---

# 3. 📸 Photo Storage Setup

## Option A: DigitalOcean Spaces (Recommended)

### What is Spaces?
DigitalOcean Spaces is object storage (like AWS S3) for files, images, and backups.

### Step 3.1: Create a Space

1. **Login to DigitalOcean**
2. Click **"Create"** → **"Spaces"**
3. **Choose Datacenter:**
   - Select **"Bangalore"** or **"Singapore"**
4. **Enable CDN:** Yes (for faster image loading)
5. **Space Name:** `nexus-oms-photos`
6. **Select Project:** Default
7. Click **"Create a Space"**
8. ✅ Space created!

### Step 3.2: Get Access Keys

1. Click **"API"** (left sidebar)
2. Scroll to **"Spaces access keys"**
3. Click **"Generate New Key"**
4. **Name:** `nexus-oms-key`
5. Click **"Generate Key"**
6. **SAVE THESE KEYS:**
   - **Access Key:** `DO00XXXXXXXXXXXXX`
   - **Secret Key:** `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - ⚠️ You can only see the secret key once!

### Step 3.3: Configure Space

**Your Space URL:**
```
https://nexus-oms-photos.blr1.digitaloceanspaces.com
```

**CDN URL (faster):**
```
https://nexus-oms-photos.blr1.cdn.digitaloceanspaces.com
```

### Step 3.4: Set Permissions

1. Go to your Space
2. Click **"Settings"**
3. **File Listing:** Private (recommended)
4. **CORS Configuration:**

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3000
  }
]
```

5. Click **"Save"**

---

## Option B: Local Storage on Droplet

### Step 3.5: Create Upload Directory

```bash
# Create directory for uploads
mkdir -p /var/www/nexus-oms/uploads

# Set permissions
chmod 755 /var/www/nexus-oms/uploads

# Create subdirectories
mkdir -p /var/www/nexus-oms/uploads/pod
mkdir -p /var/www/nexus-oms/uploads/products
mkdir -p /var/www/nexus-oms/uploads/customers
```

---

# 4. 🚀 Backend Deployment

## Step 4.1: Clone Repository

```bash
# Navigate to web directory
cd /var/www

# Clone your repository
git clone https://github.com/Aman1945/Job.git nexus-oms

# Navigate to backend
cd nexus-oms/backend
```

## Step 4.2: Install Dependencies

```bash
# Install Node.js packages
npm install

# Install additional packages if needed
npm install multer multer-s3 aws-sdk dotenv
```

## Step 4.3: Create Environment File

```bash
# Create .env file
nano .env
```

**Add these variables:**

```env
# Server Configuration
PORT=3000
NODE_ENV=production

# MongoDB Configuration (Atlas)
MONGODB_URI=mongodb+srv://nexusadmin:NexusOMS@2026@nexusoms.xxxxx.mongodb.net/NexusOMS?retryWrites=true&w=majority

# OR MongoDB Configuration (Self-Hosted)
# MONGODB_URI=mongodb://nexusadmin:NexusOMS@2026@localhost:27017/NexusOMS?authSource=admin

# DigitalOcean Spaces Configuration
DO_SPACES_ENDPOINT=blr1.digitaloceanspaces.com
DO_SPACES_BUCKET=nexus-oms-photos
DO_SPACES_ACCESS_KEY=DO00XXXXXXXXXXXXX
DO_SPACES_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DO_SPACES_CDN_URL=https://nexus-oms-photos.blr1.cdn.digitaloceanspaces.com

# Gemini AI Configuration
GEMINI_API_KEY=AIzSyBSRHNpNsgK_lshamksmQGulHHrN9BJEA

# JWT Secret
JWT_SECRET=nexus-oms-super-secret-key-2026

# CORS Configuration
ALLOWED_ORIGINS=*
```

**Save and exit:** Ctrl+X, Y, Enter

## Step 4.4: Test Backend

```bash
# Start server
node server.js

# You should see:
# ✅ Connected to MongoDB Atlas
# 🚀 Server running on port 3000
```

**Press Ctrl+C to stop**

## Step 4.5: Start with PM2

```bash
# Start with PM2
pm2 start server.js --name nexus-oms

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

# Check status
pm2 status

# View logs
pm2 logs nexus-oms
```

---

## Step 4.6: Configure Nginx Reverse Proxy

```bash
# Create Nginx configuration
nano /etc/nginx/sites-available/nexus-oms
```

**Add this configuration:**

```nginx
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or IP

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Increase upload size for photos
    client_max_body_size 50M;
}
```

**Save and exit:** Ctrl+X, Y, Enter

```bash
# Enable site
ln -s /etc/nginx/sites-available/nexus-oms /etc/nginx/sites-enabled/

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

---

## Step 4.7: Test Deployment

**Visit in browser:**
```
http://your-droplet-ip
```

**You should see:**
- Nexus OMS API welcome page
- Status: Running
- Database: Connected

**Test API endpoint:**
```
http://your-droplet-ip/api/users
```

---

# 5. 🌐 Domain & SSL Setup

## Step 5.1: Point Domain to Droplet

1. **Buy a domain** (from Namecheap, GoDaddy, etc.)
2. **Add DNS records:**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | your-droplet-ip | 3600 |
| A | www | your-droplet-ip | 3600 |

3. Wait 10-30 minutes for DNS propagation

---

## Step 5.2: Install SSL Certificate (HTTPS)

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Get SSL certificate
certbot --nginx -d your-domain.com -d www.your-domain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose to redirect HTTP to HTTPS (option 2)

# Auto-renewal test
certbot renew --dry-run
```

**Now your site is accessible at:**
```
https://your-domain.com
```

---

# 6. 📊 Monitoring & Backups

## Step 6.1: Setup PM2 Monitoring

```bash
# Monitor processes
pm2 monit

# View logs
pm2 logs

# Restart if needed
pm2 restart nexus-oms

# Stop
pm2 stop nexus-oms

# Delete
pm2 delete nexus-oms
```

---

## Step 6.2: MongoDB Backups

### Automated Backups (MongoDB Atlas):

1. Login to MongoDB Atlas
2. Click **"Backup"** (left sidebar)
3. Enable **"Continuous Backup"**
4. Configure backup schedule:
   - Daily backups
   - Retain for 7 days

### Manual Backup (Self-Hosted):

```bash
# Create backup directory
mkdir -p /var/backups/mongodb

# Backup database
mongodump --uri="mongodb://nexusadmin:NexusOMS@2026@localhost:27017/NexusOMS?authSource=admin" --out=/var/backups/mongodb/backup-$(date +%Y%m%d)

# Restore from backup
mongorestore --uri="mongodb://nexusadmin:NexusOMS@2026@localhost:27017/NexusOMS?authSource=admin" /var/backups/mongodb/backup-20260217
```

### Automated Backup Script:

```bash
# Create backup script
nano /root/backup-mongodb.sh
```

**Add:**

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/mongodb"
DATE=$(date +%Y%m%d)

# Create backup
mongodump --uri="mongodb://nexusadmin:NexusOMS@2026@localhost:27017/NexusOMS?authSource=admin" --out=$BACKUP_DIR/backup-$DATE

# Delete backups older than 7 days
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $DATE"
```

```bash
# Make executable
chmod +x /root/backup-mongodb.sh

# Add to crontab (daily at 2 AM)
crontab -e

# Add this line:
0 2 * * * /root/backup-mongodb.sh >> /var/log/mongodb-backup.log 2>&1
```

---

## Step 6.3: DigitalOcean Spaces Backup

```bash
# Install s3cmd
apt install -y s3cmd

# Configure s3cmd
s3cmd --configure

# Enter:
# Access Key: DO00XXXXXXXXXXXXX
# Secret Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# S3 Endpoint: blr1.digitaloceanspaces.com
# DNS-style bucket: %(bucket)s.blr1.digitaloceanspaces.com

# List files
s3cmd ls s3://nexus-oms-photos/

# Download all files
s3cmd sync s3://nexus-oms-photos/ /var/backups/spaces/
```

---

## Step 6.4: Server Monitoring

### Install Monitoring Tools:

```bash
# Install htop (process monitor)
apt install -y htop

# Install ncdu (disk usage)
apt install -y ncdu

# Check disk space
df -h

# Check memory
free -h

# Check running processes
htop
```

### Setup DigitalOcean Monitoring:

1. Login to DigitalOcean
2. Click on your Droplet
3. Click **"Monitoring"** tab
4. Enable:
   - CPU usage alerts
   - Memory usage alerts
   - Disk usage alerts
5. Set alert threshold: 80%
6. Add email for notifications

---

# 📝 Quick Reference Commands

## Server Management:

```bash
# Restart server
pm2 restart nexus-oms

# View logs
pm2 logs nexus-oms

# Check status
pm2 status

# Reload Nginx
systemctl reload nginx

# Restart Nginx
systemctl restart nginx
```

## Database:

```bash
# Connect to MongoDB
mongosh "mongodb+srv://nexusadmin:NexusOMS@2026@nexusoms.xxxxx.mongodb.net/NexusOMS"

# Backup
mongodump --uri="your-connection-string" --out=/var/backups/mongodb/backup

# Restore
mongorestore --uri="your-connection-string" /var/backups/mongodb/backup
```

## Updates:

```bash
# Pull latest code
cd /var/www/nexus-oms/backend
git pull origin main

# Install new dependencies
npm install

# Restart server
pm2 restart nexus-oms
```

---

# 🚨 Troubleshooting

## Issue 1: Server Not Starting

```bash
# Check logs
pm2 logs nexus-oms

# Check if port is in use
netstat -tulpn | grep 3000

# Kill process on port 3000
kill -9 $(lsof -t -i:3000)

# Restart
pm2 restart nexus-oms
```

## Issue 2: MongoDB Connection Failed

```bash
# Test connection
mongosh "your-connection-string"

# Check firewall
ufw status

# Check MongoDB Atlas IP whitelist
# Add your droplet IP in Atlas dashboard
```

## Issue 3: Photos Not Uploading

```bash
# Check Spaces credentials in .env
cat /var/www/nexus-oms/backend/.env | grep DO_SPACES

# Test Spaces access
s3cmd ls s3://nexus-oms-photos/

# Check upload directory permissions
ls -la /var/www/nexus-oms/uploads
```

## Issue 4: High Memory Usage

```bash
# Check memory
free -h

# Restart PM2
pm2 restart all

# Clear cache
sync; echo 3 > /proc/sys/vm/drop_caches
```

---

# 💰 Cost Breakdown

| Service | Plan | Monthly Cost |
|---------|------|--------------|
| **DigitalOcean Droplet** | 2GB RAM | $12 |
| **MongoDB Atlas** | M0 Free | $0 |
| **DigitalOcean Spaces** | 250GB | $5 |
| **Domain** | .com | $10-15/year |
| **SSL Certificate** | Let's Encrypt | FREE |
| **Total** | - | **~$17/month** |

---

# 📞 Support Resources

| Resource | URL |
|----------|-----|
| DigitalOcean Docs | https://docs.digitalocean.com/ |
| MongoDB Atlas Docs | https://docs.atlas.mongodb.com/ |
| Spaces Documentation | https://docs.digitalocean.com/products/spaces/ |
| PM2 Documentation | https://pm2.keymetrics.io/docs/ |
| Nginx Documentation | https://nginx.org/en/docs/ |

---

**Last Updated:** February 17, 2026  
**Version:** 1.0  
**Nexus OMS Deployment Team**
