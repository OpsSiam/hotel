#!/bin/bash
set -e

echo "[04] auditd rules"

cat <<EOF >/etc/audit/rules.d/99-hardening.rules
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k scope
-w /var/log/ -p wa -k logs

-a always,exit -F arch=b64 -S execve -k exec
-a always,exit -F arch=b32 -S execve -k exec
EOF

augenrules --load

echo "✔ auditd rules loaded"