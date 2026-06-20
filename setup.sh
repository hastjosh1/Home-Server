#!/bin/bash
# ============================================================
# Home Server Setup Script
# ============================================================
# This script prepares a fresh Ubuntu server to run the
# complete media stack. Run it once on a new machine.
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
# ============================================================

set -e

echo ""
echo "=============================================="
echo "       Home Server Setup Script"
echo "=============================================="
echo ""

# ----------------------------------------------------------
# Step 1: Check that .env file exists
# ----------------------------------------------------------
if [ ! -f .env ]; then
    echo "ERROR: .env file not found!"
    echo ""
    echo "Before running this script, you need to create your .env file:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    echo ""
    echo "Fill in your own values (server IP, DuckDNS token, etc.)"
    echo "Then run this script again."
    exit 1
fi

echo "[1/6] .env file found ✓"

# ----------------------------------------------------------
# Step 2: Load environment variables
# ----------------------------------------------------------
source .env
echo "[2/6] Environment variables loaded ✓"

# ----------------------------------------------------------
# Step 3: Create the folder structure
# ----------------------------------------------------------
echo "[3/6] Creating folder structure..."

# Media and download directories
sudo mkdir -p /data/torrents/movies
sudo mkdir -p /data/torrents/tv
sudo mkdir -p /data/media/movies
sudo mkdir -p /data/media/tv

# Config directories for each service
sudo mkdir -p /opt/media-stack/config/emby
sudo mkdir -p /opt/media-stack/config/radarr
sudo mkdir -p /opt/media-stack/config/sonarr
sudo mkdir -p /opt/media-stack/config/prowlarr
sudo mkdir -p /opt/media-stack/config/rdtclient
sudo mkdir -p /opt/media-stack/config/homarr/redis
sudo mkdir -p /opt/media-stack/config/homarr/appdata
sudo mkdir -p /opt/media-stack/config/pihole/etc-pihole
sudo mkdir -p /opt/media-stack/config/pihole/etc-dnsmasq.d

echo "   Folders created ✓"

# ----------------------------------------------------------
# Step 4: Set permissions
# ----------------------------------------------------------
echo "[4/6] Setting permissions..."
sudo chown -R ${PUID:-1000}:${PGID:-1000} /data /opt/media-stack
echo "   Permissions set ✓"

# ----------------------------------------------------------
# Step 5: Free port 53 for Pi-hole
# ----------------------------------------------------------
echo "[5/6] Freeing port 53 for Pi-hole..."

# Ubuntu's built-in DNS stub listener occupies port 53 by default.
# We need to disable it so Pi-hole can use that port instead.
if grep -q "^#\?DNSStubListener=yes" /etc/systemd/resolved.conf 2>/dev/null; then
    sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
    echo "   systemd-resolved DNS stub disabled ✓"
else
    echo "   systemd-resolved already configured ✓"
fi

# ----------------------------------------------------------
# Step 6: Copy files and start Docker containers
# ----------------------------------------------------------
echo "[6/6] Deploying Docker stack..."
sudo cp docker-compose.yml /opt/media-stack/docker-compose.yml
sudo cp .env /opt/media-stack/.env
cd /opt/media-stack
sudo docker compose up -d

echo ""
echo "=============================================="
echo "   🎉 Deployment successful!"
echo "=============================================="
echo ""
echo "Access your services at:"
echo "  🏠 Homarr (Dashboard):  http://${SERVER_IP}:7575"
echo "  🎬 Emby (Media Server): http://${SERVER_IP}:8096"
echo "  🎥 Radarr (Movies):     http://${SERVER_IP}:7878"
echo "  📺 Sonarr (TV Shows):   http://${SERVER_IP}:8989"
echo "  🔍 Prowlarr (Indexers): http://${SERVER_IP}:9696"
echo "  ⬇️  RDTClient (Torbox):  http://${SERVER_IP}:6500"
echo "  🛡️  Pi-hole (Ad Block):  http://${SERVER_IP}:8089/admin"
echo ""
echo "=============================================="
echo "   Next Steps"
echo "=============================================="
echo ""
echo "1. Read docs/post-install.md for step-by-step"
echo "   configuration of each application."
echo ""
echo "2. In Prowlarr, add a SOCKS5 proxy:"
echo "   Host: ${SERVER_IP}  Port: 1080"
echo "   Tag it 'warp-proxy' and assign to blocked indexers."
echo ""
echo "3. Point your router's DNS to ${SERVER_IP}"
echo "   to enable network-wide ad blocking!"
echo ""
