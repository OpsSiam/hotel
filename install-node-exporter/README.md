# Node Exporter (Docker)

Install scripts for Prometheus node-exporter using Docker Compose v2.

## Files
- `install-node-exporter.sh` deploys node-exporter using Docker Compose v2
- `install-node-exporter-nat-server.sh` deploys node-exporter on a host with Docker already running (host network, nftables safe)

## Requirements
- Run as root
- Docker and Docker Compose v2 installed

## Notes
- Port: `9100`
- Adjustable variables in both scripts:
  - `MONITOR_IP="10.10.20.3"` firewall allowlist (only in `install-node-exporter.sh`)
  - `INSTALL_DIR="/opt/node-exporter"`
