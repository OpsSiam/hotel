#!/bin/bash
set -e

USERNAME="${USERNAME:-${1:-}}"
PUBKEY_FILE="${PUBKEY_FILE:-${2:-}}"

if [ -z "$USERNAME" ]; then
  read -r -p "Username: " USERNAME
fi
if [ -z "$USERNAME" ]; then
  echo "❌ Username required"
  exit 1
fi

DEFAULT_PUBKEY="/root/${USERNAME}.pub"
if [ -z "$PUBKEY_FILE" ]; then
  read -r -p "Public key path [$DEFAULT_PUBKEY]: " PUBKEY_FILE
fi
if [ -z "$PUBKEY_FILE" ]; then
  PUBKEY_FILE="$DEFAULT_PUBKEY"
fi

echo "=== Create Bastion User with MFA ==="

# 1. Create user
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
  echo "✔ User $USERNAME created"
else
  echo "ℹ User $USERNAME already exists"
fi

# 2. Setup SSH key
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh

if [ -f "$PUBKEY_FILE" ]; then
  cat "$PUBKEY_FILE" > /home/$USERNAME/.ssh/authorized_keys
  chmod 600 /home/$USERNAME/.ssh/authorized_keys
else
  echo "❌ Public key not found: $PUBKEY_FILE"
  exit 1
fi

chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

# 3. Add sudo (wheel)
usermod -aG wheel "$USERNAME"

# 4. Enforce password (needed for PAM + MFA)
passwd "$USERNAME"

echo
echo "=== NEXT STEP (manual) ==="
echo "Login as $USERNAME and run:"
echo "  google-authenticator"
echo
echo "✔ Bastion user ready (MFA will be required)"
