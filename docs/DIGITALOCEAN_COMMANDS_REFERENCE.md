# 🚀 DigitalOcean Deployment - Quick Commands

**Nexus OMS - Quick Reference Sheet**

---

## 📱 Essential Connection Details

```bash
## Save These Securely:
Droplet IP: ___.___.___.___
SSH Username: root
SSH Password: **********

MongoDB URI: mongodb+srv://doadmin:****@nexus-oms-db-*****.db.ondigitalocean.com/nexus_oms

Spaces Access Key: ********************
Spaces Secret Key: ****************************************
Spaces Bucket: nexus-oms-photos
Spaces Endpoint: blr1.digitaloceanspaces.com
```

---

## 🔐 SSH Connection

```bash
## Using PuTTY (Windows):
Host: YOUR_DROPLET_IP
Port: 22
Username: root
Password: [Your Password]

## Using Terminal (Mac/Linux):
ssh root@YOUR_DROPLET_IP
```

---

## 🛠️ Initial Server Setup Commands

```bash
## 1. Update System
sudo apt update && sudo apt upgrade -y

## 2. Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

## 3. Install PM2
sudo npm install -g pm2

## 4. Install Nginx
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

## 5. Configure Firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

---

## 📂 Deploy Backend

```bash
## 1. Clone Repository
cd /root
git clone https://github.com/Aman1945/Job.git
cd Job/backend

## 2. Install Dependencies
npm install

## 3. Create .env File
nano .env
# (Paste your environment variables)
# Save: Ctrl+X, Y, Enter

## 4. Start with PM2
pm2 start server.js --name nexus-backend
pm2 save
pm2 startup
```

---

## 🔄 Update Code (Git Pull)

```bash
## Pull latest changes
cd /root/Job
git pull origin main

## Install new dependencies (if any)
cd backend
npm install

## Restart backend
pm2 restart nexus-backend

## Check logs
pm2 logs nexus-backend
```

---

## 📊 PM2 Process Management

```bash
## View running processes
pm2 status

## View logs (live)
pm2 logs nexus-backend

## View last 50 log lines
pm2 logs nexus-backend --lines 50

## Restart app
pm2 restart nexus-backend

## Stop app
pm2 stop nexus-backend

## Start app
pm2 start nexus-backend

## Delete from PM2
pm2 delete nexus-backend

## Monitor real-time
pm2 monit

## Clear logs
pm2 flush
```

---

## 🌐 Nginx Configuration

```bash
## Edit Nginx config
sudo nano /etc/nginx/sites-available/nexus-oms

## Test configuration
sudo nginx -t

## Reload Nginx
sudo systemctl reload nginx

## Restart Nginx
sudo systemctl restart nginx

## Check status
sudo systemctl status nginx

## View error logs
sudo tail -f /var/log/nginx/error.log

## View access logs
sudo tail -f /var/log/nginx/access.log
```

---

## 🗄️ Database Operations

```bash
## Test MongoDB connection
cd /root/Job/backend
node -e "require('dotenv').config(); const mongoose = require('mongoose'); mongoose.connect(process.env.MONGODB_URI).then(() => console.log('✅ DB Connected!')).catch(e => console.log('❌ Error:', e));"

## Run migration script
node migrate-permissions.js

## Check database stats
node db-stats-v2.js
```

---

## 📈 System Monitoring

```bash
## Check CPU & Memory
htop
# or
top

## Check disk usage
df -h

## Check memory usage
free -h

## Check running processes
ps aux | grep node

## Check network connections
netstat -tulpn | grep LISTEN

## Check system logs
journalctl -xe
```

---

## 🔥 Firewall Management

```bash
## Check firewall status
sudo ufw status

## Allow specific port
sudo ufw allow 3000/tcp

## Remove rule
sudo ufw delete allow 3000/tcp

## Reset firewall
sudo ufw reset
```

---

## 🧪 Testing Endpoints

```bash
## Health check (from server)
curl http://localhost:3000/api/health

## Health check (public)
curl http://YOUR_DROPLET_IP/api/health

## Login test
curl -X POST http://YOUR_DROPLET_IP/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"id":"animesh.jamuar@bigsams.in","password":"password123"}'

## Get users
curl http://YOUR_DROPLET_IP/api/users
```

---

## 🗂️ File Management

```bash
## List files
ls -lah

## Navigate to backend
cd /root/Job/backend

## View .env file
cat .env

## Edit .env file
nano .env

## Create backup
cp .env .env.backup

## View file size
du -sh /root/Job

## Remove folder
rm -rf foldername

## Copy files
cp source destination
```

---

## 📦 Backup Commands

```bash
## Create manual database backup
mongodump --uri="YOUR_MONGODB_URI" --out=/root/backups/$(date +%Y%m%d)

## Create tar archive of code
tar -czf nexus-backup-$(date +%Y%m%d).tar.gz /root/Job

## Download backup to local (from local machine)
scp root@YOUR_DROPLET_IP:/root/backups/backup.tar.gz ./

## Upload file to server (from local machine)
scp ./file.txt root@YOUR_DROPLET_IP:/root/
```

---

## 🔧 Troubleshooting

```bash
## App not responding?
pm2 restart nexus-backend
pm2 logs nexus-backend --lines 100

## MongoDB connection error?
cat /root/Job/backend/.env | grep MONGODB_URI
# Verify connection string is correct

## Nginx 502 Bad Gateway?
pm2 status                    # Check if backend running
curl http://localhost:3000    # Test backend locally
sudo nginx -t                 # Test nginx config
sudo systemctl restart nginx  # Restart nginx

## Out of memory?
free -h                       # Check memory
pm2 restart nexus-backend     # Restart app
# Consider upgrading Droplet plan

## Port already in use?
sudo lsof -i :3000           # Check what's using port 3000
sudo kill -9 [PID]           # Kill process
pm2 restart nexus-backend    # Restart

## Permission denied?
sudo chmod +x script.sh      # Make executable
sudo chown root:root file    # Change ownership
```

---

## ⚡ Performance Optimization

```bash
## Enable Nginx gzip compression
sudo nano /etc/nginx/nginx.conf
# Add: gzip on;

## PM2 cluster mode (multi-core)
pm2 start server.js -i max --name nexus-backend

## Monitor performance
pm2 monit                    # Real-time monitoring
```

---

## 🎯 Common Tasks

### 1. Restart Everything
```bash
pm2 restart nexus-backend
sudo systemctl restart nginx
```

### 2. View All Logs
```bash
pm2 logs nexus-backend &
sudo tail -f /var/log/nginx/error.log
```

### 3. Update Environment Variable
```bash
nano /root/Job/backend/.env
# Edit variable
pm2 restart nexus-backend
```

### 4. Check Server Health
```bash
pm2 status
curl http://localhost:3000/api/health
free -h
df -h
```

---

## 📞 Emergency Commands

```bash
## Stop everything
pm2 stop all
sudo systemctl stop nginx

## Kill all Node processes
pkill node

## Reboot server
sudo reboot

## Force restart PM2
pm2 kill
pm2 resurrect
```

---

## 💡 Pro Tips

1. **Always check logs first:** `pm2 logs`
2. **Test locally before public:** `curl http://localhost:3000`
3. **Backup before major changes:** `pm2 save`
4. **Monitor resources:** `htop` or `pm2 monit`
5. **Keep .env secure:** Don't commit to Git!

---

**Bookmark this page for quick reference! 🔖**
