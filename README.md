# 🌐 OpenVPS

> A lightweight, self-hosted Docker orchestrator for managing your private core services and administrative dashboard tools. Built for simplicity, speed, and clean orchestration.

---

## 🛠️ Installation & Setup

Get OpenVPS up and running on your server with these quick steps:

### 1. Install with one command
Ensure you have Docker and Git installed on your system:
```bash
curl -fsSL https://raw.githubusercontent.com/commander15/OpenVPS/refs/heads/main/installers/remote-install.sh | sh
```

### 2. Initialize Your Environment

Run the CLI tool for the first time. It will notice your .env is missing, safely copy it from .env.example, and prompt you to configure it:
```bash
vps
nano ~/openvps/.env
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

- Start everything:
```bash
vps all up
```

- Stop everything:
```bash
vps down
```

- Create or delete external docker networks (created automatically during openvps installation):
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

### Notes
- Under the hood, vps commands run docker compose --profile "*" **your args**
- While vps admin commands run docker compose --profile "admin" **your args**
- Also, vps update command run git fetch and git reset --hard (overiding all changes you've made by yourself so avoid changing any file in OpenVPS directoy, except .env of course ;))

## 📦 Directory Structure

openvps/
├── bin/
│   ├── vps.sh           # Main router & controller
│   ├── core.sh          # Core stacks wrapper
│   ├── admin.sh         # Administrative backend/frontend wrapper
│   └── network.sh       # Shared Docker network management (frontend-network, etc)
├── vps-install.sh       # Global CLI symlink installer
├── vps-uninstall.sh     # Global CLI uninstaller & service cleanup
├── docker-compose.yml   # This project kernel, a compose ap that run all the OpenVPS infra
├── .env.example         # A stratup config file, ready to use
└── README.md            # You are here!

## 🔒 Network Security & IP Bindings
The .env file exposes both a PUBLIC_IP and a PRIVATE_IP variable to achieve a zero-trust, secure-by-default routing architecture.

### 🌐 Internal Networking

OpenVPS runs on isolated, shared Docker networks to keep internal communication clean, secure, and performant:

- **frontend-network**: Reserved strictly for edge routing. It channels HTTP/HTTPS traffic from your public reverse proxy (Nginx Proxy Manager) directly to your target application web containers (e.g., standalone Nginx or PHP-FPM web layers).

- **backend-network**: Handles core microservice traffic. This network is dedicated to secure, internal communication between your app backends and infrastructure services, such as the S3 API interface on your object storage platform (MinIO).

- **database-network**: Enforces strict state isolation. This internal-only network links application backends directly to their respective databases and connects everything securely to your central database administrator panel (DBGate). By decoupling this from the frontend and object storage layers, it mitigates lateral attack risks and completely locks down raw database ports from unauthorized access.

### 🌐 Public Routing (PUBLIC_IP)
Critical administrative tools—such as Portainer (Docker Manager) and DbGate (Database Manager)—bind exclusively to your PRIVATE_IP.

### 🛡️ Private Admin Routing (PRIVATE_IP)

- **The Recommended Setup (VPN / Tailscale)**: Set PRIVATE_IP to your VPN interface IP (e.g., your Tailscale IP). This allows you to securely access your admin dashboards from anywhere on your private network (Tailnet), completely hidden from public internet probes and brute-force attacks.

- **The Public Fallback (Not Recommended)**: You can set PRIVATE_IP to 0.0.0.0 to make your administration tools publicly accessible, though this is discouraged for security reasons.

## 🗄️ Database Administration

OpenVPS groups your application databases into a strictly isolated network layer managed via a single, centralized database management console:

1. **Centralized Workspace (`vps-database-manager`)**: The database administration interface runs within the **`vps-database-manager`** container. This console is bound exclusively to your private network adapter (as specified by your VPS_PRIVATE_IP setting via port `3000`), allowing you to inspect schemas, execute raw queries, and manage records securely via your browser without exposing database ports publicly.
2. **Internal Connectivity (`database-network`)**: Every application database container (e.g., PostgreSQL, MariaDB, Redis, MongoDB) must join the shared **`database-network`**. Because **`vps-database-manager`** is a member of this network, it can instantly discover and connect to your database containers using their native internal Docker container names (e.g., `db://app-postgres-container:5432`).

## 📦 S3 Object Storage

OpenVPS leverages a centralized, S3-compatible storage engine powered by MinIO to decouple application state from local server directories:

1. **API Pipeline (`backend-network`)**: Your individual application backends hook directly into the **`vps-s3`** container hostname via port `9000` using standard S3 SDK clients. This allows workloads to cleanly upload, fetch, and process media assets, backups, or raw datasets across an optimized, internal network channel.
2. **Administration Workspace (`Tailnet / Port 9001`)**: The interactive MinIO console is safely bound to your private Tailscale network adapter. This lets you securely create buckets, monitor storage cluster performance, manage access keys, and organize object policies directly through your admin browser without exposing the **`vps-s3`** management portal to the public internet.

## 🧹 Uninstallation

To completely stop all running containers, destroy the shared Docker networks, and remove the global symlink from your system, simply run:

```bash
sudo ./vps-uninstall.sh
```
