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

echo "=== Create Internal Server User (Key-only) ==="

# 1. Create user
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
  echo "✔ User $USERNAME created"
else
  echo "ℹ User $USERNAME already exists"
fi

# 2. SSH key only
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

# 3. Disable password login
passwd -l "$USERNAME"

# 4. Optional sudo (comment out if not admin)
usermod -aG wheel "$USERNAME"

echo "✔ Internal user ready (SSH key only)"
