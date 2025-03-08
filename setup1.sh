#!/bin/bash

# Konfigurasi
DOMAIN="ai.bengkelagung.my.id"
N8N_PORT="5678"

# Set variabel lingkungan secara permanen
echo "Setting environment variables..."
echo 'export WEBHOOK_URL="https://'"$DOMAIN"'"' | sudo tee -a /etc/profile
echo 'export N8N_HOST="'"$DOMAIN"'"' | sudo tee -a /etc/profile
echo 'export N8N_PROTOCOL="https"' | sudo tee -a /etc/profile
echo 'export N8N_PORT="'"$N8N_PORT"'"' | sudo tee -a /etc/profile
source /etc/profile

# Buat file .env untuk n8n
echo "Creating .env file for n8n..."
sudo mkdir -p ~/.n8n
cat <<EOF | sudo tee ~/.n8n/.env
WEBHOOK_URL="https://$DOMAIN"
N8N_HOST="$DOMAIN"
N8N_PROTOCOL="https"
N8N_PORT="$N8N_PORT"
EOF

# Restart n8n dengan PM2
echo "Restarting n8n service..."
pm2 stop n8n
pm2 delete n8n
pm2 start n8n --name "n8n" --env ~/.n8n/.env -- start
pm2 save
pm2 startup

# Restart server untuk menerapkan perubahan
echo "Rebooting system..."
sudo reboot
