#!/bin/bash

# Konfigurasi
DOMAIN="ai.bengkelagung.my.id"
EMAIL="agunghenditemorubun@gmail.com"  # Ganti dengan email untuk Let's Encrypt
NODE_VERSION="18"

# Update sistem
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install dependensi
echo "Installing dependencies..."
sudo apt install -y curl git ufw nginx certbot python3-certbot-nginx

# Install Node.js & npm
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
echo "Installing PM2..."
sudo npm install -g pm2

# Install n8n
echo "Installing n8n..."
sudo npm install -g n8n

# Konfigurasi variabel lingkungan global
echo "Setting up environment variables..."
echo "WEBHOOK_URL=\"https://$DOMAIN\"" | sudo tee -a /etc/environment
echo "N8N_HOST=\"$DOMAIN\"" | sudo tee -a /etc/environment
echo "N8N_PROTOCOL=\"https\"" | sudo tee -a /etc/environment
echo "N8N_PORT=\"5678\"" | sudo tee -a /etc/environment
source /etc/environment

# Setup PM2 untuk n8n
echo "Setting up PM2 for n8n..."
pm2 stop n8n
pm2 delete n8n
pm2 start n8n --name "n8n" -- start
pm2 save
pm2 startup

# Buat file .env untuk n8n
echo "Creating .env file..."
sudo mkdir -p ~/.n8n
cat <<EOF | sudo tee ~/.n8n/.env
WEBHOOK_URL="https://$DOMAIN"
N8N_HOST="$DOMAIN"
N8N_PROTOCOL="https"
N8N_PORT="5678"
EOF

# Konfigurasi Nginx sebagai reverse proxy
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5678/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

# Aktifkan SSL dengan Let's Encrypt
echo "Setting up SSL with Let's Encrypt..."
if certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN; then
    echo "SSL successfully installed!"
else
    echo "Failed to install SSL, please check manually."
fi

# Buka firewall
echo "Setting up firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Restart sistem agar semua konfigurasi diterapkan
echo "Restarting system..."
sudo reboot
