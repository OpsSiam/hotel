#!/bin/bash
set -e

echo "=== Patch Management ==="

dnf install -y dnf-automatic

sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sed -i 's/emit_via = stdio/emit_via = syslog/' /etc/dnf/automatic.conf

systemctl enable --now dnf-automatic.timer

echo "✔ automatic patching enabled"