#!/bin/bash
set -e

### CONFIG ###
SCAN_TIME="30 3 * * *"        # Daily 03:30
SCRIPT_PATH="/usr/local/bin/clamav_docker_scan.sh"
CRON_FILE="/etc/cron.d/clamav_scan"
LOGDIR="/var/log/clamav"

echo "=== ClamAV Docker Scan Setup ==="

# 1. Check Docker
if ! command -v docker &>/dev/null; then
  echo "ERROR: Docker not found. Please install Docker first."
  exit 1
fi

# 2. Create log directory
echo "[1/4] Preparing log directory..."
mkdir -p "$LOGDIR"
chmod 750 "$LOGDIR"

# 3. Create scan script
echo "[2/4] Installing scan script..."
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash

DATE=$(date +"%F")
START_TS=$(date +"%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

LOGDIR="/var/log/clamav"
LOGFILE="$LOGDIR/scan-$DATE.log"

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
  echo "=================================================="
} >> "$LOGFILE"

EXCLUDE_ARGS=""
for d in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=" --exclude-dir=/scan$d"
done

docker run --rm \
  -v /:/scan:ro \
  -v /var/log/clamav:/logs \
  clamav/clamav:stable \
  clamscan -r /scan \
    --infected \
    --verbose \
    $EXCLUDE_ARGS \
    --log=/logs/scan-$DATE.log

END_TS=$(date +"%Y-%m-%d %H:%M:%S")

{
  echo "=================================================="
  echo "ClamAV Scan END"
  echo "End Time: $END_TS"
  echo "=================================================="
  echo ""
} >> "$LOGFILE"
EOF

chmod +x "$SCRIPT_PATH"

# 4. Install cron
echo "[3/4] Installing cron job..."
cat << EOF > "$CRON_FILE"
# Daily ClamAV Docker Scan
$SCAN_TIME root $SCRIPT_PATH
EOF

chmod 644 "$CRON_FILE"

echo "[4/4] Setup completed successfully."
echo
echo "✔ Script : $SCRIPT_PATH"
echo "✔ Cron   : $CRON_FILE"
echo "✔ Logs   : $LOGDIR/scan-YYYY-MM-DD.log"
echo
echo "You can test now with:"
echo "  $SCRIPT_PATH"
