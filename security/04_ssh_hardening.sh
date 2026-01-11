#!/bin/bash
set -e

echo "[07] User & sudo policy"

# password policy
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs

# sudo policy
if ! grep -q "^%wheel" /etc/sudoers; then
  echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
fi

echo "✔ User policy applied"