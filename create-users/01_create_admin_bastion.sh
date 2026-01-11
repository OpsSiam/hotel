#!/bin/bash
set -e

ADMIN="${ADMIN:-${1:-}}"
PUBKEY_FILE="${PUBKEY_FILE:-${2:-}}"

if [ -z "$ADMIN" ]; then
  read -r -p "Admin username: " ADMIN
fi
if [ -z "$ADMIN" ]; then
  echo "❌ Username required"
  exit 1
fi

DEFAULT_PUBKEY="/root/${ADMIN}.pub"
if [ -z "$PUBKEY_FILE" ]; then
  read -r -p "Public key path [$DEFAULT_PUBKEY]: " PUBKEY_FILE
fi
if [ -z "$PUBKEY_FILE" ]; then
  PUBKEY_FILE="$DEFAULT_PUBKEY"
fi

echo "=== Create Bastion ADMIN User (MFA enforced) ==="

# 1. Create user
if ! id "$ADMIN" &>/dev/null; then
  useradd -m -s /bin/bash "$ADMIN"
  echo "✔ User $ADMIN created"
else
  echo "ℹ User $ADMIN already exists"
fi

# 2. SSH key
mkdir -p /home/$ADMIN/.ssh
chmod 700 /home/$ADMIN/.ssh

if [ ! -f "$PUBKEY_FILE" ]; then
  echo "❌ Missing public key: $PUBKEY_FILE"
  exit 1
fi

cat "$PUBKEY_FILE" > /home/$ADMIN/.ssh/authorized_keys
chmod 600 /home/$ADMIN/.ssh/authorized_keys
chown -R $ADMIN:$ADMIN /home/$ADMIN/.ssh

# 3. Sudo (admin)
usermod -aG wheel "$ADMIN"

# 4. Password required for PAM + MFA
echo "🔑 Set password for $ADMIN"
passwd "$ADMIN"

echo
echo "=== MANUAL STEP (REQUIRED) ==="
echo "Login as $ADMIN and run:"
echo "  google-authenticator"
echo
echo "✔ Bastion ADMIN ready (MFA required)"
