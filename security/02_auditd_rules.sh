#!/bin/bash
set -e

echo "=== Auditd Rules Setup ==="

cat <<EOF > /etc/audit/rules.d/99-pci.rules
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudo
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k faillock
-a always,exit -F arch=b64 -S execve -k commands
EOF

augenrules --load

echo "✔ auditd rules applied"