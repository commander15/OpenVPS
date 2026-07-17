# 🌐 OpenVPS

> A lightweight, self-hosted Docker orchestrator for managing your private core services and administrative dashboard tools. Built for simplicity, speed, and clean orchestration.

---

## 🛠️ Installation & Setup

Get OpenVPS up and running on your server with these quick steps:

### 1. Prerequisites
Ensure you have Docker and Git installed on your system:
```bash
# Debian/Ubuntu quick-install for Docker (if needed)
curl -fsSL [https://get.docker.com](https://get.docker.com) -o get-docker.sh && sh get-docker.sh
```

### 2. Clone the Repository
Clone your OpenVPS repository to your server and navigate into the project root:
```bash
git clone [https://github.com/yourusername/openvps.git](https://github.com/yourusername/openvps.git)
cd openvps
```

### 3. Run the Installer
Run the installer with sudo to make the scripts executable, initialize the shared Docker networks, and register the global vps system command:
```bash
sudo ./vps-install.sh
```

### 4. Initialize Your Environment

Run the CLI tool for the first time. It will notice your .env is missing, safely copy it from .env.example, and prompt you to configure it:
```bash
vps
```

Open the newly created .env file and update your database credentials, domain names, or secrets:
```bash
nano .env
```

## 🚀 Quick Start / Common Commands

- Bring up the core services
```bash
vps up
```

- Bring up the admin dashboard and tools:
```bash
vps admin up
```

- Stop everything (automatically stops admin):
```bash
vps down
```

- Create or delete external docker services (created automatically during openvps installation):
```bash
vps network up
vps network down
```

- View real-time service logs:
```bash
vps logs
```

- Update OpenVPS:
```bash
vps update
```

### Note
Under the hood, vps commands run docker compose --profile "*" **your args**.
While vps admin commands run docker compose --profile "admin" **your args**.
Also, vps update command run git fetch and git reset --hard (overiding all changes you've made by yourself so avoid chaning any file in OpenVPS directoy).

## 📦 Directory Structure

openvps/
├── bin/
│   ├── vps.sh           # Main router & controller
│   ├── core.sh          # Core stacks wrapper
│   ├── admin.sh         # Administrative backend/frontend wrapper
│   └── networks.sh      # Shared Docker network management (vps_network, web_network)
├── frontend/            # Angular SPA Dashboard
│   ├── Dockerfile       # Light-weight Nginx multi-stage build
│   └── ...
├── backend/             # Laravel SQLite-backed REST API
│   ├── Dockerfile       # Optimized PHP 8.3 FPM image
│   └── ...
├── vps-install.sh       # Global CLI symlink installer
├── vps-uninstall.sh     # Global CLI uninstaller & service cleanup
└── README.md            # You are here!

## 🔒 Network Security & IP Bindings
The .env file exposes both a PUBLIC_IP and a PRIVATE_IP variable to achieve a zero-trust, secure-by-default routing architecture.

### 🌐 Internal Networking
OpenVPS runs on two isolated, shared Docker networks to keep communications clean and secure:

1. vps_network: Used for communication between the core system, target local containers, and system-monitoring utilities.

2. web_network: Reserved for routing HTTP traffic from your public reverse proxy (e.g., Nginx Proxy Manager) directly to the target services (your apps web containers like nginx or php-fpm ones).

### 🌐 Public Routing (PUBLIC_IP)
Critical administrative tools—such as Portainer (Docker Manager) and DbGate (Database Manager)—bind exclusively to your PRIVATE_IP.

### 🛡️ Private Admin Routing (PRIVATE_IP)

- **The Recommended Setup (VPN / Tailscale)**: Set PRIVATE_IP to your VPN interface IP (e.g., your Tailscale IP). This allows you to securely access your admin dashboards from anywhere on your private network (Tailnet), completely hidden from public internet probes and brute-force attacks.

- **The Public Fallback (Not Recommended)**: You can set PRIVATE_IP to 0.0.0.0 to make your administration tools publicly accessible, though this is discouraged for security reasons.

## 🧹 Uninstallation

To completely stop all running containers, destroy the shared Docker networks, and remove the global symlink from your system, simply run:

```bash
sudo ./vps-uninstall.sh
```
