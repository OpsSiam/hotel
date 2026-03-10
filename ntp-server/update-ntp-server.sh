echo "=== NTP Configuration (Chrony) ==="

CHRONY_CONF="/etc/chrony.conf"

# install chrony if not installed
dnf install -y chrony

# backup config
cp $CHRONY_CONF ${CHRONY_CONF}.bak.$(date +%F)

# configure ntp servers
cat <<EOF > $CHRONY_CONF
# NTP servers
server time.google.com iburst
server time.cloudflare.com iburst
pool 2.rocky.pool.ntp.org iburst

# drift file
driftfile /var/lib/chrony/drift

# step clock if offset is large
makestep 1.0 3

# sync hardware clock
rtcsync

# require at least 2 sources
minsources 2

# log directory
logdir /var/log/chrony
EOF

# enable and start chrony
systemctl enable --now chronyd

# restart to apply config
systemctl restart chronyd

echo "✔ NTP configured"