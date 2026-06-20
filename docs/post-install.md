# 🔧 Post-Install Configuration Guide

After running `setup.sh`, all your Docker containers are running. But they don't know about each other yet! Follow this guide step-by-step to wire everything together.

> **Tip:** Open your Homarr dashboard at `http://<SERVER_IP>:7575` to easily access all services from one page.

---

## Table of Contents

1. [Configure RDTClient (Torbox)](#1-configure-rdtclient-torbox)
2. [Configure Prowlarr (Indexers)](#2-configure-prowlarr-indexers)
3. [Configure the WARP Proxy](#3-configure-the-warp-proxy)
4. [Configure Radarr (Movies)](#4-configure-radarr-movies)
5. [Configure Sonarr (TV Shows)](#5-configure-sonarr-tv-shows)
6. [Sync Prowlarr to Radarr & Sonarr](#6-sync-prowlarr-to-radarr--sonarr)
7. [Configure Pi-hole (Ad Blocking)](#7-configure-pi-hole-ad-blocking)
8. [Configure Homarr (Dashboard)](#8-configure-homarr-dashboard)
9. [Test Everything](#9-test-everything)

---

## 1. Configure RDTClient (Torbox)

RDTClient is the bridge between your *arr apps and Torbox (the cloud torrent service).

1. Open **RDTClient** at `http://<SERVER_IP>:6500`
2. On your first visit, you'll be asked to create an account. Create a username and password (this is local only).
3. Go to **Settings**
4. Under **Download Client**, select **Torbox** as the provider
5. Paste your **Torbox API Key** (get it from [torbox.app/settings](https://torbox.app/settings))
6. Set the **Download path** to `/data/downloads`
7. Under **Post Processing**, set:
   - **Min file size to download**: `10` MB (to skip small junk files)
   - **On torrent finished**: `No action` (Radarr/Sonarr will handle moving files)
8. Click **Save**

---

## 2. Configure Prowlarr (Indexers)

Prowlarr manages all your torrent search sites (indexers) in one place.

1. Open **Prowlarr** at `http://<SERVER_IP>:9696`
2. Go to **Indexers** (left sidebar)
3. Click the **`+`** (Add Indexer) button
4. Search for and add your preferred indexers. Recommended ones that work well:
   - **TorrentGalaxy** — Huge library, no Cloudflare issues
   - **MagnetDL** — Great alternative
   - **1337x** — Large library (may need WARP proxy if ISP blocks it, use mirror `1337x.st`)
   - **EZTV** — TV show specialist (use mirror `eztv.re` if blocked)
5. For each indexer, click **Test** to make sure it connects successfully
6. Click **Save**

### Add FlareSolverr Proxy (for Cloudflare-protected sites)

1. Go to **Settings** → **Indexers**
2. Scroll to the bottom and click the **`+`** button under **Indexer Proxies**
3. Select **FlareSolverr**
4. Set the **Host** to `http://flaresolverr:8191` (use the container name since they're on the same Docker network)
5. Give it the tag `flaresolverr`
6. Click **Test**, then **Save**
7. Now edit any Cloudflare-protected indexer and assign the `flaresolverr` tag

---

## 3. Configure the WARP Proxy

The WARP proxy helps bypass ISP-level website blocks.

1. In **Prowlarr**, go to **Settings** → **Indexers**
2. Scroll to the bottom, click the **`+`** button under **Indexer Proxies**
3. Select **Socks5**
4. Set the following:
   - **Name**: `WARP Proxy`
   - **Host**: `<SERVER_IP>` (e.g., `192.168.1.7`)
   - **Port**: `1080`
   - **Username**: *(leave empty)*
   - **Password**: *(leave empty)*
5. Give it the tag `warp-proxy`
6. Click **Test**, then **Save**
7. Now edit any ISP-blocked indexer and assign the `warp-proxy` tag

> **Note:** Don't assign the WARP proxy to indexers that already work without it. Only use it for indexers your ISP actively blocks.

---

## 4. Configure Radarr (Movies)

1. Open **Radarr** at `http://<SERVER_IP>:7878`

### Add RDTClient as a Download Client

Radarr thinks RDTClient is a qBittorrent client (RDTClient emulates it).

1. Go to **Settings** → **Download Clients**
2. Click the **`+`** button
3. Select **qBittorrent**
4. Set:
   - **Name**: `RDTClient`
   - **Host**: `<SERVER_IP>` (e.g., `192.168.1.7`)
   - **Port**: `6500`
   - **Username**: your RDTClient username
   - **Password**: your RDTClient password
5. Click **Test**, then **Save**

### Set the Root Folder

1. Go to **Movies** → **Add New**
2. Search for any movie
3. In the **Root Folder** dropdown, click **Add a new path**
4. Navigate to `/data/media/movies` and select it
5. This only needs to be done once — Radarr will remember it

### Set a Quality Profile

1. Go to **Settings** → **Profiles**
2. The default profiles are fine for most people
3. If you want only 1080p content, edit the profile and uncheck 720p and below

---

## 5. Configure Sonarr (TV Shows)

1. Open **Sonarr** at `http://<SERVER_IP>:8989`

### Add RDTClient as a Download Client

Same process as Radarr:

1. Go to **Settings** → **Download Clients**
2. Click the **`+`** button
3. Select **qBittorrent**
4. Set:
   - **Name**: `RDTClient`
   - **Host**: `<SERVER_IP>` (e.g., `192.168.1.7`)
   - **Port**: `6500`
   - **Username**: your RDTClient username
   - **Password**: your RDTClient password
5. Click **Test**, then **Save**

### Set the Root Folder

1. Go to **Series** → **Add New**
2. Search for any TV show
3. In the **Root Folder** dropdown, click **Add a new path**
4. Navigate to `/data/media/tv` and select it

---

## 6. Sync Prowlarr to Radarr & Sonarr

This is the magic step! Once synced, Prowlarr will automatically push all your indexers to Radarr and Sonarr.

### Get API Keys

First, grab the API keys from Radarr and Sonarr:

- **Radarr**: Go to **Settings** → **General** → copy the **API Key**
- **Sonarr**: Go to **Settings** → **General** → copy the **API Key**

### Add Apps in Prowlarr

1. Open **Prowlarr** at `http://<SERVER_IP>:9696`
2. Go to **Settings** → **Apps**
3. Click the **`+`** button

#### Add Radarr:
- Select **Radarr**
- **Prowlarr Server**: `http://prowlarr:9696` (or `http://<SERVER_IP>:9696`)
- **Radarr Server**: `http://radarr:7878` (or `http://<SERVER_IP>:7878`)
- **API Key**: paste the Radarr API key
- Click **Test**, then **Save**

#### Add Sonarr:
- Select **Sonarr**
- **Prowlarr Server**: `http://prowlarr:9696` (or `http://<SERVER_IP>:9696`)
- **Sonarr Server**: `http://sonarr:8989` (or `http://<SERVER_IP>:8989`)
- **API Key**: paste the Sonarr API key
- Click **Test**, then **Save**

4. Click **Sync App Indexers** to push all your indexers to both apps immediately

---

## 7. Configure Pi-hole (Ad Blocking)

### Access the Dashboard

1. Open Pi-hole at `http://<SERVER_IP>:8089/admin`
2. If you set a password in `.env`, log in with it. If you left it blank, you'll go straight to the dashboard.

### Allow External Queries (Important!)

By default, Pi-hole in Docker only responds to queries from inside the container network. You need to allow queries from your actual home devices:

1. Go to **Settings** → **DNS**
2. Click the **"Basic"** toggle in the top right to switch to **"Advanced"**
3. Under **Interface Settings**, select **"Permit all origins"**
4. Click **Save & Apply**

### Set Upstream DNS

1. In **Settings** → **DNS**, make sure at least one upstream DNS server is checked
2. **Google (ECS, DNSSEC)** is a reliable default choice
3. Click **Save & Apply**

### Configure a Single Device (Testing)

To test Pi-hole on just one device before committing your whole network:

**Android:**
1. Go to **Settings** → **Wi-Fi**
2. Tap the **gear/info icon** on your connected network
3. Change **IP Settings** from **DHCP** to **Static**
4. Set **DNS 1** and **DNS 2** to your `<SERVER_IP>`
5. Save

**iOS:**
1. Go to **Settings** → **Wi-Fi**
2. Tap the **info (i) icon** on your connected network
3. Tap **Configure DNS** → **Manual**
4. Delete existing DNS servers and add your `<SERVER_IP>`
5. Save

### Configure Your Entire Network

To block ads for every device on your network automatically:

1. Log into your **home router** (usually at `192.168.1.1` or `10.0.0.1`)
2. Find **LAN/DHCP Settings** or **DNS Settings**
3. Set the **Primary DNS** to your `<SERVER_IP>`
4. Save and reboot the router
5. All devices will now use Pi-hole automatically when they reconnect to Wi-Fi!

---

## 8. Configure Homarr (Dashboard)

1. Open **Homarr** at `http://<SERVER_IP>:7575`
2. On your first visit, you'll see a setup wizard. Create an admin account.
3. Start adding **widgets** for each service:
   - Click **Add Widget** → Search for the service (Radarr, Sonarr, Pi-hole, etc.)
   - Enter the service URL (e.g., `http://<SERVER_IP>:7878` for Radarr)
   - Enter the API key where required

### Pi-hole Widget (v6)

When adding the Pi-hole widget:
- Set the **Version** to **6**
- Set the **URL** to `http://<SERVER_IP>:8089` (do NOT include `/admin`)
- Use your Pi-hole web password as the API key (leave blank if no password)

---

## 9. Test Everything

### Test the Download Pipeline

1. Open **Radarr** → **Add New Movie**
2. Search for a movie (e.g., "Big Buck Bunny" — it's free!)
3. Click **Add Movie** → check **Start search for missing movie**
4. Watch the magic happen:
   - Check **Prowlarr** → the search results will appear
   - Check **RDTClient** → the torrent will be sent to Torbox
   - Check **Radarr** → **Activity** tab shows the download progress
5. Once complete, open **Emby** and the movie should appear in your library!

### Test Pi-hole

1. On a device configured to use Pi-hole as DNS, visit a website with lots of ads (like Forbes.com)
2. Check your Pi-hole dashboard — you should see the **Queries Blocked** counter going up!

### Test DuckDNS

1. Open a browser and go to `http://<YOUR_SUBDOMAIN>.duckdns.org:8096`
2. If port forwarding is set up on your router, you'll see your Emby server!

---

## 🎉 You're Done!

Your home server is fully configured. Sit back, add some movies to Radarr, some shows to Sonarr, and enjoy your own personal streaming service!

If you run into any issues, check the **Troubleshooting** section in the main [README](../README.md).
