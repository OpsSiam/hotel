# ClamAV Docker Scan

Containerized ClamAV scanning with a cron schedule and log rotation by date.

## Files
- `clamav_docker_setup.sh` one-time setup script
- `install_clam_av.md` extended guide

## Requirements
- Linux host with Docker installed
- Run as root

## Quick start
```bash
chmod +x /path/to/clamav_docker_setup.sh
sudo /path/to/clamav_docker_setup.sh
```

This creates:
- `/usr/local/bin/clamav_docker_scan.sh`
- `/etc/cron.d/clamav_scan`
- `/var/log/clamav/scan-YYYY-MM-DD.log`

## Defaults
- Schedule: `30 3 * * *` (daily 03:30)
- Log directory: `/var/log/clamav`

