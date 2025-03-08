#!/bin/bash

# Install Docker (Jika belum terinstall)
echo "Menambahkan repository Docker..."
sudo apt-get update
sudo apt-get install -y sudo apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Menambahkan user ke grup Docker agar bisa menjalankan Docker tanpa sudo
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose (Jika belum terinstall)
echo "Menginstall Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Membuat direktori untuk n8n
mkdir -p ~/n8n
cd ~/n8n

# Membuat file docker-compose.yml untuk n8n
cat << EOF > docker-compose.yml
version: '3'

services:
  n8n:
    image: n8n/n8n
    container_name: n8n
    environment:
      - N8N_HOST=ai.bengkelagung.my.id
      - N8N_PORT=5678
      - VUE_APP_URL_BASE_API=https://ai.bengkelagung.my.id/api/v1
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=agung
      - N8N_BASIC_AUTH_PASSWORD=agung
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=localhost
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n
    ports:
      - "5678:5678"
    volumes:
      - ~/.n8n:/root/.n8n
    restart: always

EOF

# Jalankan Docker Compose untuk memulai n8n
echo "Menjalankan n8n dengan Docker Compose..."
docker-compose up -d

# Setup untuk mengakses n8n di domain dan email
echo "Setelah selesai, Anda bisa mengakses n8n di https://ai.bengkelagung.my.id:5678"
echo "Gunakan username: agung dan password yang sudah ditentukan untuk login ke n8n."
