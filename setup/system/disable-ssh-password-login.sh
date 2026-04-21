#!/bin/bash

set -euo pipefail

echo "================================"
echo "Disable SSH password login"
echo "================================"
echo ""

SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_DROPIN_DIR="/etc/ssh/sshd_config.d"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "❌ SSH config not found: $SSHD_CONFIG"
    exit 1
fi

backup_if_needed() {
    local file="$1"
    local backup_file="${file}.bak.${TIMESTAMP}"
    if [ ! -f "$backup_file" ]; then
        cp "$file" "$backup_file"
        echo "✓ Backup created: $backup_file"
    fi
}

update_password_auth_line() {
    local file="$1"
    if grep -qE '^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]+' "$file"; then
        backup_if_needed "$file"
        sed -i -E 's/^[[:space:]]*#?[[:space:]]*PasswordAuthentication[[:space:]]+.*/PasswordAuthentication no/' "$file"
        echo "✓ Updated: $file"
        return 0
    fi
    return 1
}

echo "Scanning sshd config files..."

declare -a SSH_CONFIG_FILES
SSH_CONFIG_FILES=("$SSHD_CONFIG")

if [ -d "$SSHD_DROPIN_DIR" ]; then
    while IFS= read -r file; do
        SSH_CONFIG_FILES+=("$file")
    done < <(find "$SSHD_DROPIN_DIR" -maxdepth 1 -type f -name '*.conf' | sort)
fi

found_directive=false
for file in "${SSH_CONFIG_FILES[@]}"; do
    if update_password_auth_line "$file"; then
        found_directive=true
    fi
done

if [ "$found_directive" = false ]; then
    backup_if_needed "$SSHD_CONFIG"
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    echo "✓ Added PasswordAuthentication no to $SSHD_CONFIG"
fi

if ! command -v sshd >/dev/null 2>&1; then
    echo "❌ sshd command not found, cannot validate config"
    exit 1
fi

sshd -t

effective_password_auth="$(sshd -T 2>/dev/null | awk '/^passwordauthentication / {print $2; exit}')"
if [ "$effective_password_auth" != "no" ]; then
    echo "❌ Effective SSH config still allows password login (passwordauthentication $effective_password_auth)"
    echo "Please check Match blocks or custom include order in sshd config."
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
