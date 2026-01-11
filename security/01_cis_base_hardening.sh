#!/bin/bash
set -e

echo "[01] CIS Base Hardening"

cat <<EOF >/etc/sysctl.d/99-cis.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.tcp_syncookies = 1
kernel.randomize_va_space = 2
EOF

sysctl --system

chmod 600 /etc/shadow
chmod 600 /etc/gshadow
chmod 644 /etc/passwd
chmod 644 /etc/group

echo "✔ CIS base hardening applied"