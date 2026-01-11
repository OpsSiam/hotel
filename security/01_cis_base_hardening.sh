#!/bin/bash
set -e

echo "=== CIS Base OS Hardening ==="

# Disable unused filesystems
cat <<EOF > /etc/modprobe.d/cis.conf
install cramfs /bin/true
install squashfs /bin/true
install udf /bin/true
install vfat /bin/true
EOF

# Kernel hardening
cat <<EOF > /etc/sysctl.d/99-cis.conf
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
kernel.randomize_va_space = 2
EOF

sysctl --system

# Permissions
chmod 600 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

echo "✔ CIS base hardening done"