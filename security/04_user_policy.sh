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
Banner /etc/issue.net
EOF

sshd -t
systemctl restart sshd

echo "✔ SSH hardened"


echo "=== SSH Permission Hardening ==="

chmod 700 /root/.ssh || true
chmod 600 /root/.ssh/authorized_keys || true

echo "✔ SSH permissions secured"


echo "=== Password Policy (PCI DSS) ==="

LOGIN_DEFS="/etc/login.defs"

cp $LOGIN_DEFS ${LOGIN_DEFS}.bak.$(date +%F)

sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' $LOGIN_DEFS
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' $LOGIN_DEFS
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' $LOGIN_DEFS

echo "✔ Password expiration policy set"


echo "=== Password Complexity ==="

PWQUALITY="/etc/security/pwquality.conf"

if ! grep -q "minlen = 12" $PWQUALITY; then
cat <<EOF >> $PWQUALITY

# PCI DSS password policy
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
retry = 3
EOF
fi

echo "✔ Password complexity configured"


echo "=== Password History ==="

PAM_FILE="/etc/pam.d/system-auth"

if [ -f $PAM_FILE ]; then
sed -i 's/pam_unix.so.*/pam_unix.so remember=5/' $PAM_FILE || true
fi

echo "✔ Password history enabled"


echo "=== Account Lockout ==="

PAM_FAILLOCK="/etc/security/faillock.conf"

if [ -f $PAM_FAILLOCK ]; then
sed -i 's/^deny.*/deny = 6/' $PAM_FAILLOCK || echo "deny = 6" >> $PAM_FAILLOCK
sed -i 's/^unlock_time.*/unlock_time = 900/' $PAM_FAILLOCK || echo "unlock_time = 900" >> $PAM_FAILLOCK
fi

echo "✔ Account lockout configured"


echo "=== Session Timeout ==="

PROFILE="/etc/profile.d/session_timeout.sh"

cat <<EOF > $PROFILE
TMOUT=900
readonly TMOUT
export TMOUT
EOF

chmod +x $PROFILE

echo "✔ Session timeout set (15 minutes)"


echo "=== Security Banner ==="

cat <<EOF > /etc/issue.net
Authorized uses only. All activity may be monitored and reported.
EOF

echo "✔ Login banner configured"


echo "=== Apply Password Policy to Existing Users ==="

for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    chage -M 90 -m 1 -W 7 $user || true
done

echo "✔ Password policy applied"


echo "=== Hardening Complete ==="
