cat << 'EOF' > /opt/clam-av/clamav_docker_setup.sh
#!/bin/bash
set -e

### CONFIG ###
SCAN_TIME="30 3 * * *"
SCRIPT_PATH="/usr/local/bin/clamav_docker_scan.sh"
CRON_FILE="/etc/cron.d/clamav_scan"
LOGDIR="/var/log/clamav"

echo "=== ClamAV Docker Scan Setup ==="

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker not found"
  exit 1
fi

# Prepare log dir
mkdir -p "$LOGDIR"
chmod 750 "$LOGDIR"

# Create scan script
cat << 'EOS' > "$SCRIPT_PATH"
#!/bin/bash
set -e

PATH=/usr/sbin:/usr/bin:/sbin:/bin

HOSTNAME=$(hostname)
DATE=$(date +"%F")
START_TS=$(date +"%Y-%m-%d %H:%M:%S")

LOGDIR="/var/log/clamav"
LOGFILE="scan-${DATE}.log"
LOGPATH="${LOGDIR}/${LOGFILE}"

EXCLUDES=(
  "/proc"
  "/sys"
  "/dev"
  "/run"
  "/var/lib/docker"
  "/var/lib/containerd"
)

mkdir -p "$LOGDIR"

{
  echo "=================================================="
  echo "ClamAV Scan START"
  echo "Host      : $HOSTNAME"
  echo "Start Time: $START_TS"
  echo "Mode      : Docker (read-only filesystem)"
  echo "Log File  : $LOGFILE"
  echo "=================================================="
} >> "$LOGPATH"

EXCLUDE_ARGS=""
for d in "\${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=" --exclude-dir=/scan\$d"
done

docker run --rm \
  -v /:/scan:ro \
  -v "$LOGDIR":/logs \
  clamav/clamav:stable \
  clamscan -r /scan \
    --infected \
    --verbose \
    \$EXCLUDE_ARGS \
    --log="/logs/\$LOGFILE"

END_TS=\$(date +"%Y-%m-%d %H:%M:%S")

{
  echo "=================================================="
  echo "ClamAV Scan END"
  echo "End Time: \$END_TS"
  echo "=================================================="
  echo ""
} >> "\$LOGPATH"
EOS

chmod +x "$SCRIPT_PATH"

# Install cron
cat << EOF2 > "$CRON_FILE"
# Daily ClamAV Docker Scan
$SCAN_TIME root $SCRIPT_PATH
EOF2

chmod 644 "$CRON_FILE"

echo "✔ Installed $SCRIPT_PATH"
echo "✔ Cron configured ($SCAN_TIME)"
echo "✔ Logs at $LOGDIR"
EOF
