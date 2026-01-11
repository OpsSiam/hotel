#!/bin/bash
set -e

echo "== Install node-exporter (Docker Compose v2, NFTABLES SAFE) =="

MONITOR_IP="10.10.20.3"
INSTALL_DIR="/opt/node-exporter"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# ---------------- CHECK DOCKER ----------------
if ! command -v docker >/dev/null 2>&1; then
  echo "[X] Docker not installed. Run install-docker/install-docker.sh first."
  exit 1
fi

if ! systemctl is-active docker >/dev/null 2>&1; then
  echo "[X] Docker is not running. Fix Docker before continue."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[X] Docker Compose v2 not found. Run install-docker/install-docker.sh first."
  exit 1
fi

# ---------------- CLEAN OLD ----------------
docker rm -f node-exporter >/dev/null 2>&1 || true

# ---------------- SETUP DIR ----------------
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

# ---------------- COMPOSE ----------------
cat << 'EOF' > docker-compose.yml
services:
  nodeexporter:
    image: prom/node-exporter:v0.18.1
    container_name: node-exporter
    restart: unless-stopped
    network_mode: host
    pid: host
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)(\$|/)'
EOF

# ---------------- START ----------------
docker compose up -d

echo ""
docker ps | grep node-exporter || true
echo "== DONE =="
echo "node-exporter listening on :9100 (host network, nftables untouched)"
