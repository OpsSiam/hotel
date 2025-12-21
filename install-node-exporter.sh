#!/bin/bash
set -e

echo "== Install node-exporter (Docker Compose v2, FIXED) =="

# ---------------- CONFIG ----------------
MONITOR_IP="10.10.20.3"
INSTALL_DIR="/opt/node-exporter"

# ---------------- CHECK ROOT ----------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# ---------------- INSTALL DOCKER ----------------
if ! command -v docker >/dev/null 2>&1; then
  echo "[+] Installing Docker CE..."
  dnf -y install dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf -y install docker-ce docker-ce-cli containerd.io
  systemctl enable --now docker
else
  echo "[✓] Docker already installed"
fi

# ---------------- INSTALL DOCKER COMPOSE V2 ----------------
if ! docker compose version >/dev/null 2>&1; then
  echo "[+] Installing Docker Compose v2 plugin..."
  mkdir -p /usr/local/lib/docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
else
  echo "[✓] Docker Compose v2 already installed"
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
