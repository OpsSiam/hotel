#!/bin/bash
set -e

echo "[02] SSH hardening"

SSHD_CONF="/etc/ssh/sshd_config.d/99-hardening.conf"

cat <<EOF >$SSHD_CONF
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
UsePAM yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sshd -t
systemctl restart sshd

echo "✔ SSH hardened"