#!/bin/bash
set -e

echo "[05] Patch management"

dnf install -y dnf-automatic

sed -i 's/^apply_updates.*/apply_updates = yes/' /etc/dnf/automatic.conf
sed -i 's/^upgrade_type.*/upgrade_type = security/' /etc/dnf/automatic.conf

systemctl enable --now dnf-automatic.timer

echo "✔ Automatic security patch enabled"