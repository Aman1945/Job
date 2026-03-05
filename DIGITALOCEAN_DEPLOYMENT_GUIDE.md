# NexusOMS Backend Deployment Guide for DigitalOcean

This guide outlines the complete process to deploy your Node.js backend from GitHub to a DigitalOcean Droplet.

## Prerequisites
1. A **DigitalOcean account**.
2. A **GitHub repository** containing your backend code.
3. Your code should be pushed to GitHub (we will do this now).

---

## Step 1: Create a DigitalOcean Droplet

1. Log in to your DigitalOcean Control Panel.
2. Click **Create** > **Droplets**.
3. Choose an image: Select **Ubuntu 24.04 (LTS)**.
4. Choose a size: A **Basic $6/mo or $12/mo regular SSD** plan is sufficient for Node.js.
5. Choose a datacenter region preferably closest to your users (e.g., **Bangalore** or **Singapore**).
6. **Authentication Mode**: Choose **Password** or **SSH keys** (SSH keys are highly recommended for security).
7. Name the Droplet (e.g., `nexus-backend-prod`) and click **Create Droplet**.

---

## Step 2: Connect to Your Droplet

Once your Droplet is running, note its IPv4 address.
Open your terminal (Command Prompt/PowerShell) and connect:

```bash
ssh root@YOUR_DROPLET_IP
```
(If you used a password, enter it when prompted.)

---

## Step 3: Install Node.js, NPM, and Git

Run these commands on the Droplet to update packages and install Node.js:

```bash
# Update package list
apt update && apt upgrade -y

# Install curl and git
apt install curl git -y

# Install Node.js (v20)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install -y nodejs

# Verify installation
node -v
npm -v
```

---

## Step 4: Clone Your GitHub Repository

```bash
# Navigate to the home directory
cd ~

# Clone your repository (Replace with your actual GitHub repo URL)
git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git

# Enter the backend folder
cd YOUR_REPO_NAME/backend
```

*Note: If your repo is private, you will need to set up a GitHub Fine-Grained Personal Access Token (PAT) or SSH key to clone it.*

---

## Step 5: Install Dependencies & Setup Environment

1. Install all required Node packages:
   ```bash
   npm install
   ```

2. Create the `.env` file for your production environment:
   ```bash
   nano .env
   ```
   Paste your environment variables (like MongoDB URI, JWT Secret, Port usually 3000) and press `CTRL + X`, then `Y`, then `Enter` to save.

---

## Step 6: Install PM2 for Process Management

PM2 will keep your Node.js app running in the background and restart it if it crashes.

```bash
# Install PM2 globally
npm install -g pm2

# Start your backend server
pm2 start server.js --name "nexus-backend"

# Ensure PM2 starts automatically on server reboot
pm2 startup ubuntu
```
(Run the command that PM2 outputs after the `startup` command, then:)
```bash
pm2 save
```

---

## Step 7: Install and Configure Nginx (Reverse Proxy)

We use Nginx to map your domain to the port (e.g., 3000) your Node.js app runs on.

1. Install Nginx:
   ```bash
   apt install nginx -y
   ```

2. Configure Nginx:
   ```bash
   nano /etc/nginx/sites-available/default
   ```
   Replace the contents with:
   ```nginx
   server {
       listen 80;
       server_name YOUR_DOMAIN_OR_IP; # e.g., api.yourdomain.com OR your Droplet IP

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```
   Save (`CTRL+X`, `Y`, `Enter`).

3. Restart Nginx:
   ```bash
   nginx -t
   systemctl restart nginx
   ```

---

## Step 8: Adding SSL Context (HTTPS) via Let's Encrypt (Optional but Recommended)

Once you point your domain (A Record) to the Droplet IP:

```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d YOUR_DOMAIN_OR_IP
```
Follow the prompts to secure your backend API.

You are now successfully deployed on DigitalOcean!
