#!/bin/bash
set -e

echo "=== CIS Base OS Hardening ==="

# Disable unused filesystems
cat <<EOF > /etc/modprobe.d/cis.conf
install cramfs /bin/true
install squashfs /bin/true
install udf /bin/true
EOF

# EFI systems need vfat to mount /boot/efi; avoid breaking boot.
if [ ! -d /sys/firmware/efi ] && ! mountpoint -q /boot/efi; then
  echo "install vfat /bin/true" >> /etc/modprobe.d/cis.conf
fi

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

# Permissions (CIS-aligned defaults)
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 600 /etc/shadow
chmod 600 /etc/gshadow

echo "✔ CIS base hardening done"
