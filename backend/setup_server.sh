#!/bin/bash
# NexusOMS Server Setup Script
# ENV argument: "production" or "uat"
# Usage: bash setup_server.sh production
#        bash setup_server.sh uat

ENV=${1:-production}
REPO_DIR="/root/Job"
PORT=3000

if [ "$ENV" = "uat" ]; then
  REPO_DIR="/root/Job-uat"
  PORT=3001
fi

echo "🚀 Setting up NexusOMS [$ENV] server..."

# === 1. System Update ===
apt-get update -y && apt-get upgrade -y

# === 2. Install Node.js 20 LTS ===
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs nginx

# === 3. Install PM2 ===
npm install -g pm2

# === 4. Create logs and clone repo ===
mkdir -p /root/logs
git clone https://github.com/Aman1945/Job.git $REPO_DIR
cd $REPO_DIR/backend
npm install --production

# === 5. Setup .env ===
cp .env.example .env
sed -i "s|PORT=3000|PORT=$PORT|g" $REPO_DIR/backend/.env
echo ""
echo "⚠️  IMPORTANT: Edit .env and fill in:"
echo "   nano $REPO_DIR/backend/.env"
echo "   -> MONGODB_URI (from DigitalOcean DB)"
echo "   -> JWT_SECRET (keep unique per env)"
echo ""

# === 6. Nginx Config ===
cat > /etc/nginx/sites-available/nexus-$ENV << NGINX
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/nexus-$ENV /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# === 7. Start App ===
cd $REPO_DIR/backend
pm2 start ecosystem.config.js --only nexus-$ENV
pm2 save
pm2 startup

echo ""
echo "✅ NexusOMS [$ENV] is LIVE at http://$(curl -s ifconfig.me)"
echo ""
