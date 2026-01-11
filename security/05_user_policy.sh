#!/bin/bash
set -e

echo "=== SSH Hardening ==="

cat <<EOF > /etc/ssh/sshd_config.d/99-hardening.conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 4
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 0
AllowTcpForwarding no
X11Forwarding no
EOF

sshd -t
systemctl restart sshd

echo "✔ SSH hardened"