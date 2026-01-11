#!/bin/bash
set -e

### CONFIG ###
SCAN_TIME="30 3 * * *"                 # Daily 03:30
SCRIPT_PATH="/usr/local/bin/clamav_docker_scan.sh"
CRON_FILE="/etc/cron.d/clamav_scan"
LOGDIR="/var/log/clamav"

echo "=== ClamAV Docker Scan Setup ==="

# -------------------------------------------------------------------
# 1. Check Docker
# -------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker not found. Please install Docker first."
  exit 1
fi

# -------------------------------------------------------------------
# 2. Prepare log directory
# -------------------------------------------------------------------
mkdir -p "$LOGDIR"
chmod 750 "$LOGDIR"

# -------------------------------------------------------------------
# 3. Create scan script
# -------------------------------------------------------------------
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
for d in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=" --exclude-dir=/scan$d"
done

docker run --rm \
  -v /:/scan:ro \
  clamav/clamav:stable \
  clamscan -r /scan \
    --infected \
    --verbose \
    $EXCLUDE_ARGS \
  2>&1 | tee -a "$LOGPATH"

END_TS=$(date +"%Y-%m-%d %H:%M:%S")

{
  echo "=================================================="
  echo "ClamAV Scan END"
  echo "End Time: $END_TS"
  echo "=================================================="
  echo ""
} >> "$LOGPATH"
EOS

chmod +x "$SCRIPT_PATH"

# -------------------------------------------------------------------
# 4. Install cron
# -------------------------------------------------------------------
cat << EOF > "$CRON_FILE"
# Daily ClamAV Docker Scan
$SCAN_TIME root $SCRIPT_PATH
EOF

chmod 644 "$CRON_FILE"

echo
echo "✔ Installed scan script : $SCRIPT_PATH"
echo "✔ Cron configured      : $SCAN_TIME"
echo "✔ Log directory        : $LOGDIR"
echo
echo "Test manually with:"
echo "  $SCRIPT_PATH"
