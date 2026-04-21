#!/bin/bash

set -e

run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

resolve_ssh_port() {
    local provided_port="${1:-}"
    local detected_port=""

    if [ -n "$provided_port" ]; then
        echo "$provided_port"
        return
    fi

    if [ -f /etc/ssh/sshd_config ]; then
        detected_port=$(grep -E '^[[:space:]]*Port[[:space:]]+[0-9]+' /etc/ssh/sshd_config | awk '{print $2}' | tail -n 1)
    fi

    if [ -n "$detected_port" ]; then
        echo "$detected_port"
    else
        echo "22"
    fi
}

is_valid_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        return 1
    fi
    return 0
}

SSH_PORT=$(resolve_ssh_port "${1:-}")

if ! is_valid_port "$SSH_PORT"; then
    echo "❌ Invalid SSH port: $SSH_PORT"
    exit 1
fi

echo "================================"
echo "Setting up UFW firewall"
echo "================================"
echo "SSH port to allow: $SSH_PORT"
echo ""

if ! command -v ufw >/dev/null 2>&1; then
    echo "Installing UFW..."
    run_as_root apt-get update
    run_as_root apt-get install -y ufw
else
    echo "✓ UFW already installed"
fi

echo ""
echo "Applying firewall rules..."
run_as_root ufw default deny incoming
run_as_root ufw default allow outgoing
run_as_root ufw allow "$SSH_PORT/tcp"
run_as_root ufw allow 80/tcp
run_as_root ufw allow 443/tcp

echo ""
echo "Enabling UFW..."
run_as_root ufw --force enable
run_as_root ufw reload

echo ""
echo "Current UFW status:"
run_as_root ufw status verbose
echo ""
echo "✅ UFW setup completed"
