# DigitalOcean Deployment Plan - NexuSOMS

Migrating the entire infrastructure (Backend, Database, and File Storage) to DigitalOcean for a robust, scalable, and professional production environment.

## 🏗️ Architecture Overview

| Component | DigitalOcean Service | Description |
|-----------|----------------------|-------------|
| **Backend** | Droplet (Ubuntu) | Node.js API server running with PM2 and Nginx. |
| **Database** | Managed MongoDB | High-availability database with automated backups. |
| **Storage** | Spaces | S3-compatible object storage for PODs, Invoices, and Excel imports. |
| **SSL/DNS** | Cloudflare / Let's Encrypt | Secure HTTPS for API communication. |

---

## 🚀 Proposed Changes

### 1. Backend Service (Droplet)
We will set up a Droplet with the following stack:
- **Node.js**: LTS version.
- **Nginx**: Reverse proxy to handle incoming requests and SSL.
- **PM2**: Process manager to ensure the API stays online 24/7.
- **Certbot**: Automated SSL certificate management.

### 2. Managed MongoDB
- Create a **Managed MongoDB** cluster on DigitalOcean.
- Update the `MONGODB_URI` in the backend environment variables.
- Migrate existing data from MongoDB Atlas (if any) using `mongodump` and `mongorestore`.

### 3. S3-Compatible Storage (Spaces)
- Create a **DigitalOcean Space** and a corresponding **CDN (Endpoint)**.
- Update `backend/services/storageService.js` to point to DigitalOcean endpoints.
- Transition all local file handling in `server.js` to use the `storageService`.

#### [MODIFY] [storageService.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/services/storageService.js)
- Update configuration to use DigitalOcean-specific environment variables (`DO_SPACES_KEY`, `DO_SPACES_SECRET`, `DO_SPACES_ENDPOINT`, `DO_SPACES_BUCKET`).

#### [MODIFY] [server.js](file:///c:/Users/Dell/Desktop/NEW%20JOB/backend/server.js)
- Update upload routes (Bulk Import, POD upload) to upload directly to Spaces instead of the local `uploads/` directory.

### 4. Frontend Configuration
#### [MODIFY] [api_config.dart](file:///c:/Users/Dell/Desktop/NEW%20JOB/flutter/lib/config/api_config.dart)
- Update `productionServer` to the new DigitalOcean domain/IP.

---

## 🛠️ Step-by-Step Setup Guide

### Phase 1: Infrastructure Provisioning
1. **Create Space**: Region (e.g., SGP1/FRA1), File Listing (Private), CDN (Enabled).
2. **Create Managed DB**: Select MongoDB, VPC (Default), Cluster Name (`nexus-db`).
3. **Create Droplet**: Ubuntu 22.04, Basic (Regular), 2GB RAM / 1 vCPU is recommended.

### Phase 2: Server Configuration (SSH)
```bash
# Update and Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs nginx

# Install PM2
sudo apt install -g pm2 # Corrected from npm install -g pm2 which might fail depending on permissions

# Clone and Setup
git clone https://github.com/Aman1945/Job.git
cd Job/backend
npm install
cp .env.example .env # Update with DO credentials
```

### Phase 3: Nginx & SSL
- Configure `/etc/nginx/sites-available/nexus` to proxy to `localhost:3000`.
- Run `sudo certbot --nginx` for HTTPS.

---

## ✅ Verification Plan

### Automated Tests
- Run `npm start` on the server and check the logs for successful MongoDB and Spaces initialization.
- Test `/api/health` endpoint from a local browser.

### Manual Verification
- **File Upload**: Perform a Bulk Import of materials in the app and verify the file appears in DigitalOcean Spaces.
- **Real-time**: Verify Socket.io connections are working through the Nginx proxy.
- **Mobile Access**: Ensure the Flutter app connects to the new production URL.
