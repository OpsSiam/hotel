#!/bin/bash
set -e

echo "== Install Docker CE + Docker Compose v2 =="

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

echo "== DONE =="
