#!/bin/bash
set -e

echo "=== PAM Password / Lockout / Session Policy ==="

dnf install -y libpwquality

# Password complexity
sed -i 's/^# minlen.*/minlen = 14/' /etc/security/pwquality.conf
sed -i 's/^# dcredit.*/dcredit = -1/' /etc/security/pwquality.conf
sed -i 's/^# ucredit.*/ucredit = -1/' /etc/security/pwquality.conf
sed -i 's/^# lcredit.*/lcredit = -1/' /etc/security/pwquality.conf
sed -i 's/^# ocredit.*/ocredit = -1/' /etc/security/pwquality.conf

# Lockout policy
for f in system-auth password-auth; do
  sed -i '/pam_faillock.so/d' /etc/pam.d/$f
  sed -i '/pam_env.so/a auth required pam_faillock.so preauth silent deny=5 unlock_time=900' /etc/pam.d/$f
  sed -i '/pam_unix.so/a auth [default=die] pam_faillock.so authfail deny=5 unlock_time=900' /etc/pam.d/$f
  sed -i '/pam_unix.so/a account required pam_faillock.so' /etc/pam.d/$f
done

# Session timeout
cat <<EOF > /etc/profile.d/timeout.sh
export TMOUT=900
readonly TMOUT
EOF

chmod 644 /etc/profile.d/timeout.sh

echo "✔ PAM password, lockout, session policy applied"