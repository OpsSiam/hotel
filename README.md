# Server Ops Toolkit

Scripts to install Node Exporter and schedule ClamAV scans via Docker for general use.

## 0) Install Docker (optional)

Script location: `install-docker/install-docker.sh`

### Requirements
- Run as root
- `dnf`-based systems (e.g., CentOS/Rocky/Alma)

### Steps (place the file in `/usr/local/bin`)
```bash
nano /usr/local/bin/install-docker.sh
chmod +x /usr/local/bin/install-docker.sh
sudo /usr/local/bin/install-docker.sh
```

## 1) Install Node Exporter (Docker Compose)

Script location: `install-node-exporter/install-node-exporter.sh`

### Requirements
- Run as root
- Docker and Docker Compose v2 installed

### Steps (place the file in `/usr/local/bin`)
```bash
nano /usr/local/bin/install-node-exporter.sh
chmod +x /usr/local/bin/install-node-exporter.sh
sudo /usr/local/bin/install-node-exporter.sh
```

### Optional config
Variables in the script:
- `MONITOR_IP="10.10.20.3"` used to allow port 9100 only from this IP via firewall
- `INSTALL_DIR="/opt/node-exporter"`

After installation, Node Exporter listens on `:9100`.

## 2) Install ClamAV scan via Docker (cron)

Script location: `clam-av/clamav_docker_setup.sh`

### Requirements
- Docker installed
- Run as root

### Steps (place the file in `/usr/local/bin`)
```bash
nano /usr/local/bin/clamav_docker_setup.sh
chmod +x /usr/local/bin/clamav_docker_setup.sh
sudo /usr/local/bin/clamav_docker_setup.sh
```

### Defaults
- Scan time: `30 3 * * *` (daily at 03:30)
- Script: `/usr/local/bin/clamav_docker_scan.sh`
- Cron file: `/etc/cron.d/clamav_scan`
- Log: `/var/log/clamav/scan-YYYY-MM-DD.log`

### Manual test
```bash
sudo /usr/local/bin/clamav_docker_scan.sh
```
