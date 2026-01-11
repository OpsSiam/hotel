#!/bin/bash
set -e

echo "== Install node-exporter (Docker Compose v2) =="

# ---------------- CONFIG ----------------
MONITOR_IP="10.10.20.3"
INSTALL_DIR="/opt/node-exporter"

# ---------------- CHECK ROOT ----------------
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

# ---------------- CLEAN OLD CONTAINER ----------------
docker rm -f node-exporter >/dev/null 2>&1 || true

# ---------------- DIRECTORY ----------------
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

# ---------------- DOCKER COMPOSE FILE ----------------
echo "[+] Creating docker-compose.yml (NO IP BIND)"

cat << 'EOF' > docker-compose.yml
services:
  nodeexporter:
    image: prom/node-exporter:v0.18.1
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)(\$|/)'
    ports:
      - "9100:9100"
EOF

# ---------------- FIREWALL ----------------
if systemctl is-active firewalld >/dev/null 2>&1; then
  echo "[+] Configuring firewall: allow 9100 only from ${MONITOR_IP}"
  firewall-cmd --permanent --remove-port=9100/tcp || true
  firewall-cmd --permanent \
    --add-rich-rule="rule family='ipv4' source address='${MONITOR_IP}' port protocol='tcp' port='9100' accept"
  firewall-cmd --reload
fi

# ---------------- START ----------------
echo "[+] Starting node-exporter..."
docker compose up -d

# ---------------- VERIFY ----------------
echo ""
echo "[✓] node-exporter container:"
docker ps | grep node-exporter || true

echo ""
echo "== DONE =="
echo "node-exporter is listening on :9100"
echo "Firewall allows access ONLY from ${MONITOR_IP}"
