#!/bin/bash

set -e

echo "================================"
echo "Disable SSH password login"
echo "================================"
echo ""

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "❌ SSH config not found: $SSHD_CONFIG"
    exit 1
fi

BACKUP_FILE="${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"

if grep -qE '^[[:space:]]*PasswordAuthentication[[:space:]]+no' "$SSHD_CONFIG"; then
    echo "✓ PasswordAuthentication is already set to no"
else
    if grep -qE '^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]+' "$SSHD_CONFIG"; then
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]+.*/PasswordAuthentication no/' "$SSHD_CONFIG"
    else
        echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    fi
    echo "✓ Updated PasswordAuthentication to no"
fi

if command -v sshd >/dev/null 2>&1; then
    sshd -t
else
    echo "❌ sshd command not found, cannot validate config"
    exit 1
fi

if systemctl is-active ssh >/dev/null 2>&1; then
    systemctl restart ssh
elif systemctl is-active sshd >/dev/null 2>&1; then
    systemctl restart sshd
else
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
fi

echo ""
echo "✅ SSH password login disabled"
echo "🔐 Only key-based SSH login is allowed now"
