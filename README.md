# 🏠 Home Server

A complete, self-hosted media server and home lab stack powered by Docker. Search for movies and TV shows, download them automatically, stream them to any device, block ads network-wide, and manage everything from a beautiful dashboard.

> **One command to deploy.** Clone this repo, fill in your `.env`, run `setup.sh`, and you're done.

---

## 📋 Table of Contents

- [What's Included](#-whats-included)
- [Architecture Overview](#-architecture-overview)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Post-Install Configuration](#-post-install-configuration)
- [Port Reference](#-port-reference)
- [Folder Structure](#-folder-structure)
- [How It All Works Together](#-how-it-all-works-together)
- [Updating Containers](#-updating-containers)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)

---

## 🧰 What's Included

| Service | What It Does | Web UI Port |
|---------|-------------|-------------|
| **[Emby](https://emby.media/)** | Media server — streams your movies & TV shows to any device (like a personal Netflix) | `8096` |
| **[Radarr](https://radarr.video/)** | Movie manager — automatically searches, grabs, and organizes movies | `7878` |
| **[Sonarr](https://sonarr.tv/)** | TV show manager — automatically searches, grabs, and organizes TV episodes | `8989` |
| **[Prowlarr](https://prowlarr.com/)** | Indexer manager — manages all your torrent search sites in one place | `9696` |
| **[RDTClient](https://github.com/rogerfar/rdt-client)** | Download client — bridges [Torbox](https://torbox.app/) cloud downloads to your server | `6500` |
| **[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)** | Cloudflare solver — bypasses Cloudflare challenges for Prowlarr indexers | `8191` |
| **[Homarr](https://homarr.dev/)** | Dashboard — a beautiful homepage to access all your services | `7575` |
| **[Pi-hole](https://pi-hole.net/)** | Ad blocker — blocks ads and trackers for your entire network | `8089` |
| **[DuckDNS](https://www.duckdns.org/)** | Dynamic DNS — keeps a free domain pointed at your home IP | — |
| **[WARP Proxy](https://developers.cloudflare.com/warp-client/)** | SOCKS5 proxy — routes traffic through Cloudflare to bypass ISP blocks | `1080` |
| **[OpenSpeedTest](https://openspeedtest.com/)** | Network speed test — test your local and internet connection speed | `3000` |
| **[RuView](https://github.com/ruvnet/RuView)** | Spatial Intelligence — Demo mode showcasing WiFi sensing | `3001` |

---

## 🏗 Architecture Overview

```
                    ┌─────────────────────────────────┐
                    │         YOUR DEVICES             │
                    │   (Phone, TV, Laptop, Tablet)    │
                    └────────────────┬────────────────┘
                                     │
                              Home Network
                                     │
                    ┌────────────────┴────────────────┐
                    │        HOME SERVER (Ubuntu)      │
                    │                                  │
                    │  ┌──────────┐   ┌──────────┐    │
                    │  │  Homarr  │   │ Pi-hole  │    │
                    │  │Dashboard │   │Ad Blocker│    │
                    │  └──────────┘   └──────────┘    │
                    │                                  │
                    │  ┌──────────┐   ┌──────────┐    │
                    │  │   Emby   │   │ Prowlarr │    │
                    │  │Streaming │   │ Indexers  │    │
                    │  └──────────┘   └─────┬────┘    │
                    │                       │         │
                    │  ┌──────────┐   ┌─────┴────┐    │
                    │  │  Radarr  │   │  Sonarr  │    │
                    │  │ Movies   │   │ TV Shows │    │
                    │  └────┬─────┘   └─────┬────┘    │
                    │       └───────┬───────┘         │
                    │               │                  │
                    │        ┌──────┴──────┐           │
                    │        │  RDTClient  │           │
                    │        │  (Torbox)   │           │
                    │        └─────────────┘           │
                    └──────────────────────────────────┘
```

---

## 📦 Prerequisites

### Hardware
- A dedicated machine (old laptop, mini PC, or any spare computer)
- At least **4 GB RAM** (8 GB recommended)
- At least **50 GB** of storage for media (more is better!)
- Connected to your home network via **Ethernet cable** (recommended) or Wi-Fi

### Software
- **Ubuntu Server 22.04+** (or any Debian-based Linux distro)
- **Docker** and **Docker Compose** installed
- **Git** installed
- A **[Torbox](https://torbox.app/)** account (for cloud downloading)
- A **[DuckDNS](https://www.duckdns.org/)** account (free, for dynamic DNS)

### Installing Docker (if not already installed)

```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo sh

# Add your user to the docker group (so you don't need sudo every time)
sudo usermod -aG docker $USER

# Log out and back in for the group change to take effect
```

### Installing Git (if not already installed)

```bash
sudo apt update && sudo apt install -y git
```

---

## 🚀 Quick Start

### Step 1: Clone this repository

```bash
cd ~
git clone https://github.com/hastjoshi/home-server.git
cd home-server
```

### Step 2: Create your environment file

```bash
cp .env.example .env
nano .env
```

Fill in your own values:
- **`SERVER_IP`** — Your server's local IP address. Find it by running `hostname -I | awk '{print $1}'`
- **`DUCKDNS_SUBDOMAIN`** — Your DuckDNS subdomain (just the part before `.duckdns.org`)
- **`DUCKDNS_TOKEN`** — Your DuckDNS token (from the DuckDNS website)
- **`HOMARR_SECRET_KEY`** — Generate one by running `openssl rand -hex 32`

Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

### Step 3: Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

That's it! The script will:
1. ✅ Create all necessary directories
2. ✅ Set correct file permissions
3. ✅ Free port 53 for Pi-hole
4. ✅ Pull all Docker images and start every container

### Step 4: Configure your applications

Once everything is running, follow the **[Post-Install Configuration Guide](docs/post-install.md)** to connect all the services together.

---

## ⚙️ Post-Install Configuration

After running the setup script, your containers are running but they don't know about each other yet. Follow the detailed **[Post-Install Configuration Guide](docs/post-install.md)** to:

1. Set up RDTClient with your Torbox account
2. Connect Prowlarr to your indexers
3. Connect Radarr and Sonarr to Prowlarr and RDTClient
4. Configure Pi-hole for network-wide ad blocking
5. Set up the WARP proxy for blocked indexers
6. Customize your Homarr dashboard

---

## 🔌 Port Reference

| Port | Service | URL |
|------|---------|-----|
| `7575` | Homarr (Dashboard) | `http://<SERVER_IP>:7575` |
| `8096` | Emby (Media Server) | `http://<SERVER_IP>:8096` |
| `7878` | Radarr (Movies) | `http://<SERVER_IP>:7878` |
| `8989` | Sonarr (TV Shows) | `http://<SERVER_IP>:8989` |
| `9696` | Prowlarr (Indexers) | `http://<SERVER_IP>:9696` |
| `6500` | RDTClient (Torbox) | `http://<SERVER_IP>:6500` |
| `8191` | FlareSolverr | `http://<SERVER_IP>:8191` |
| `8089` | Pi-hole (Ad Blocker) | `http://<SERVER_IP>:8089/admin` |
| `53` | Pi-hole DNS | (used automatically) |
| `1080` | WARP SOCKS5 Proxy | `socks5://<SERVER_IP>:1080` |
| `3000` | OpenSpeedTest | `http://<SERVER_IP>:3000` |
| `3001` | RuView (Demo) | `http://<SERVER_IP>:3001` |

---

## 📁 Folder Structure

```
Server Filesystem:

/opt/media-stack/                  # Main stack directory
├── docker-compose.yml             # Container definitions
├── .env                           # Your secrets (not in git!)
└── config/                        # Persistent configuration
    ├── emby/                      # Emby server config
    ├── radarr/                    # Radarr config & database
    ├── sonarr/                    # Sonarr config & database
    ├── prowlarr/                  # Prowlarr config & database
    ├── rdtclient/                 # RDTClient database
    ├── homarr/
    │   ├── appdata/               # Homarr v1.0 data
    │   └── redis/                 # Redis persistence
    └── pihole/
        ├── etc-pihole/            # Pi-hole config
        └── etc-dnsmasq.d/         # DNS config

/data/                             # Media storage
├── torrents/                      # Download staging area
│   ├── movies/                    # Movie downloads land here
│   └── tv/                        # TV show downloads land here
└── media/                         # Organized library
    ├── movies/                    # Radarr moves finished movies here
    └── tv/                        # Sonarr moves finished shows here
```

---

## 🔄 How It All Works Together

Here's the complete flow when you request a movie:

1. **You** search for "Tetris" in **Radarr** and click "Add Movie"
2. **Radarr** asks **Prowlarr** to search all your indexers for "Tetris"
3. **Prowlarr** searches sites like TorrentGalaxy and finds the best quality torrent
4. **Prowlarr** sends the result back to **Radarr**
5. **Radarr** picks the best release and sends the torrent to **RDTClient**
6. **RDTClient** uploads the torrent to **Torbox** (cloud service)
7. **Torbox** downloads the file on their fast servers (your ISP sees nothing!)
8. **RDTClient** downloads the finished file from Torbox to `/data/torrents/movies/`
9. **Radarr** detects the download, renames it properly, and moves it to `/data/media/movies/`
10. **Emby** automatically detects the new movie and adds it to your library with artwork and metadata
11. **You** open Emby on your phone/TV/laptop and watch it! 🍿

---

## 🔄 Updating Containers

To update all containers to their latest versions:

```bash
cd /opt/media-stack

# Pull the latest images
sudo docker compose pull

# Recreate containers with the new images
sudo docker compose up -d

# (Optional) Remove old, unused images to free disk space
sudo docker image prune -f
```

---

## 🔧 Troubleshooting

### Pi-hole won't start (Port 53 already in use)

**Cause:** Ubuntu's built-in `systemd-resolved` service is hogging port 53.

**Fix:**
```bash
sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
```

If you have **Cloudflare WARP** installed on the server, it also grabs port 53. The docker-compose.yml already handles this by binding Pi-hole to your specific `SERVER_IP` instead of `0.0.0.0`.

---

### Indexers showing "Forbidden" or "Cloudflare Protection" errors in Prowlarr

**Cause:** Your ISP is blocking the indexer website, or Cloudflare is blocking automated access.

**Fix:**
1. Try using a **mirror URL** for the indexer (e.g., `1337x.st` instead of `1337x.to`)
2. Assign the `warp-proxy` tag to the indexer in Prowlarr to route it through Cloudflare WARP
3. If Cloudflare still blocks it, switch to indexers that don't use aggressive Cloudflare protection (like **TorrentGalaxy** or **MagnetDL**)

---

### Radarr/Sonarr says "Root folder does not exist"

**Cause:** You need to set the root folder path for the first time.

**Fix:**
- In **Radarr**: When adding a movie, set the Root Folder to `/data/media/movies`
- In **Sonarr**: When adding a TV show, set the Root Folder to `/data/media/tv`

---

### "No internet" after setting Pi-hole as DNS on a device

**Cause:** Pi-hole's Docker container is rejecting DNS queries from outside its internal network.

**Fix:**
1. Go to Pi-hole dashboard → **Settings** → **DNS**
2. Click the **"Basic"** toggle to switch to **"Advanced"**
3. Under **Interface Settings**, select **"Permit all origins"**
4. Click **Save & Apply**

---

### Downloads stuck in RDTClient

**Cause:** RDTClient may have lost connection to Torbox.

**Fix:**
1. Open RDTClient (`http://<SERVER_IP>:6500`)
2. Go to **Settings** and verify your Torbox API key is correct
3. Check that the download paths are set to `/data/downloads`

---

## ❓ FAQ

### Can I access my server from outside my home?
Yes! DuckDNS keeps a free domain (like `yourname.duckdns.org`) pointed at your home's public IP. However, you'll also need to set up **port forwarding** on your router and ideally a **reverse proxy** (like Nginx Proxy Manager or Caddy) with HTTPS for secure remote access.

### Can I use Jellyfin instead of Emby?
Absolutely! Just replace the `emby` service in `docker-compose.yml` with the [Jellyfin Docker image](https://hub.docker.com/r/jellyfin/jellyfin). The volume paths stay the same.

### Can I use a different download service instead of Torbox?
Yes! RDTClient also supports **Real-Debrid**, **AllDebrid**, and **Premiumize**. Just change the provider in RDTClient's settings.

### How much storage do I need?
That depends on how many movies/shows you want to keep! A typical 1080p movie is 2-8 GB, and a full TV season is 5-20 GB. A 1TB external hard drive is a great starting point.

### Is this legal?
The software itself is 100% legal and open-source. What you download with it is your responsibility. Many people use this stack to manage their personal media libraries and legally obtained content.

---

## 📄 License

This project is provided as-is for personal use. All included services are open-source projects maintained by their respective communities.

---

**Built with ❤️ and Docker**
