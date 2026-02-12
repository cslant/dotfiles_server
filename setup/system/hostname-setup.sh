#!/bin/bash

# ======================== Change System Hostname ========================
# This script changes the system hostname and updates all necessary files
# including /etc/hostname, /etc/hosts, and cloud-init metadata

echo '=========================================='
echo '🔧 Setting up system hostname'
echo '=========================================='
echo ''

# Get current hostname
CURRENT_HOSTNAME=$(hostname)
echo "📌 Current hostname: $CURRENT_HOSTNAME"
echo ''

# Get new hostname from argument or prompt
NEW_HOSTNAME=$1

while true; do
    if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]] && [[ -n $NEW_HOSTNAME ]]; then
        yn="y"
    else
        if [[ -z $NEW_HOSTNAME ]]; then
            read -r -p "Enter new hostname:  " NEW_HOSTNAME
        fi
        echo ""
        read -r -p "Change hostname to '$NEW_HOSTNAME'? (Y/N)  " yn
    fi

    case $yn in
    [Yy]*)
        # Validate hostname
        # RFC 1123: hostname can contain letters, digits, hyphens, max 63 chars
        if [[ ! $NEW_HOSTNAME =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
            echo "❌ Invalid hostname format!"
            echo "   Hostname must:"
            echo "   - Start and end with alphanumeric character"
            echo "   - Contain only letters, digits, and hyphens"
            echo "   - Be 1-63 characters long"
            echo ""
            NEW_HOSTNAME=""
            if [[ $ACCEPT_INSTALL =~ ^[Yy]$ ]]; then
                break
            fi
            continue
        fi

        echo ""
        echo "=========================== Hostname Change ==========================="
        echo "Old hostname: $CURRENT_HOSTNAME"
        echo "New hostname: $NEW_HOSTNAME"
        echo ""
        echo "Processing..."

        # ============ 1. Change hostname using hostnamectl ============
        echo "1️⃣ Updating system hostname with hostnamectl..."
        if command -v hostnamectl >/dev/null 2>&1; then
            sudo hostnamectl set-hostname "$NEW_HOSTNAME"
            echo "✓ hostnamectl updated"
        else
            # Fallback for systems without hostnamectl
            echo "$NEW_HOSTNAME" | sudo tee /etc/hostname >/dev/null
            sudo hostname "$NEW_HOSTNAME"
            echo "✓ /etc/hostname updated"
        fi

        # ============ 2. Update /etc/hosts ============
        echo ""
        echo "2️⃣ Updating /etc/hosts..."

        # Backup /etc/hosts
        sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d%H%M%S)

        # Replace old hostname with new hostname in /etc/hosts
        # Handle both 127.0.1.1 format and other variations
        sudo sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts 2>/dev/null || true
        sudo sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts 2>/dev/null || true

        # Ensure there's an entry for the new hostname
        if ! grep -q "$NEW_HOSTNAME" /etc/hosts; then
            # Add entry if not exists
            if grep -q "127.0.1.1" /etc/hosts; then
                sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
            else
                echo "127.0.1.1	$NEW_HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
            fi
        fi
        echo "✓ /etc/hosts updated"
        echo "  Backup created: /etc/hosts.backup.$(date +%Y%m%d%H%M%S)"

        # ============ 3. Update cloud-init metadata (if exists) ============
        echo ""
        echo "3️⃣ Checking cloud-init metadata..."
        if [ -f /etc/cloud/cloud.cfg ]; then
            CLOUD_HOSTNAME=$(sudo grep "preserve_hostname:" /etc/cloud/cloud.cfg | grep -v "#" || echo "")
            if [[ -z $CLOUD_HOSTNAME ]] || [[ $CLOUD_HOSTNAME == *"false"* ]]; then
                # Set preserve_hostname: true to prevent cloud-init from overwriting
                sudo sed -i 's/preserve_hostname:.*/preserve_hostname: true/' /etc/cloud/cloud.cfg 2>/dev/null || true
                if ! grep -q "^preserve_hostname:" /etc/cloud/cloud.cfg; then
                    echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg >/dev/null
                fi
                echo "✓ cloud-init configured to preserve hostname"
            else
                echo "✓ cloud-init already configured to preserve hostname"
            fi
        else
            echo "  (cloud-init not found, skipping)"
        fi

        # ============ 4. Update Postfix mail server (if exists) ============
        echo ""
        echo "4️⃣ Checking Postfix configuration..."
        if command -v postconf >/dev/null 2>&1; then
            sudo postconf -e "myhostname=$NEW_HOSTNAME"
            echo "✓ Postfix myhostname updated to $NEW_HOSTNAME"
        else
            echo "  (Postfix not found, skipping)"
        fi

        # ============ 5. Summary ============
        echo ""
        echo "=========================================="
        echo "✨ Hostname changed successfully!"
        echo "=========================================="
        echo ""
        echo "New hostname: $NEW_HOSTNAME"
        echo ""
        echo "⚠️ NOTE:"
        echo "   - Changes take effect immediately"
        echo "   - You may need to reconnect SSH for prompt to update"
        echo "   - Some services may need restart"
        echo ""
        echo "🔍 Verify:"
        echo "   hostname          # Should show $NEW_HOSTNAME"
        echo "   hostname -f       # Should show FQDN"
        echo "   cat /etc/hostname # Should show $NEW_HOSTNAME"
        echo ""

        break
        ;;
    [Nn]*) break ;;
    *)
        echo "Please answer yes or no."
        NEW_HOSTNAME=""
        ;;
    esac
done
