#!/bin/bash

# ======================== Set SSH Timeout ========================
# Auto logout SSH after 5 minutes (300 seconds) of user inactivity
#
# There are 2 types of timeout:
# 1. TMOUT: Logout when user doesn't type any command (shell idle) - THIS IS WHAT YOU NEED
# 2. ClientAlive: Only checks network connection, not user activity

TIMEOUT_SECONDS=300  # 5 minutes

echo '=========================================='
echo '🔧 Setting up SSH idle timeout (5 minutes)'
echo '=========================================='
echo ''

# ============ Method 1: TMOUT (Shell idle timeout) ============
# This is the CORRECT way to auto logout when user doesn't type any command

echo '1️⃣ Setting TMOUT for all users...'

# Remove old TMOUT entries to avoid duplicates and readonly errors
sudo sed -i '/TMOUT/d' /etc/profile 2>/dev/null
sudo sed -i '/TMOUT/d' /etc/bash.bashrc 2>/dev/null
sudo sed -i '/Auto logout after/d' /etc/profile 2>/dev/null
sudo sed -i '/Auto logout after/d' /etc/bash.bashrc 2>/dev/null
sudo rm -f /etc/profile.d/ssh-timeout.sh 2>/dev/null

# Add TMOUT to /etc/profile.d/ for bash users (ONLY place for bash)
sudo tee /etc/profile.d/ssh-timeout.sh > /dev/null <<EOF
# Auto logout after 5 minutes of inactivity
TMOUT=$TIMEOUT_SECONDS
readonly TMOUT
export TMOUT
EOF

sudo chmod +x /etc/profile.d/ssh-timeout.sh
echo '✓ Created /etc/profile.d/ssh-timeout.sh (for bash)'

# Add TMOUT for ZSH users - ZSH doesn't load /etc/profile.d/ by default
echo ''
echo '1️⃣.1 Setting TMOUT for ZSH users...'

# Create /etc/zsh directory if not exists
sudo mkdir -p /etc/zsh

# Remove old TMOUT entries to avoid duplicates and readonly errors
sudo sed -i '/TMOUT/d' /etc/zsh/zshenv 2>/dev/null
sudo sed -i '/TMOUT/d' /etc/zsh/zshrc 2>/dev/null
sudo sed -i '/Auto logout after/d' /etc/zsh/zshenv 2>/dev/null
sudo sed -i '/Auto logout after/d' /etc/zsh/zshrc 2>/dev/null

# Add to /etc/zsh/zshenv ONLY (loaded first for all zsh sessions)
sudo tee -a /etc/zsh/zshenv > /dev/null <<'EOF'

# Auto logout after 5 minutes of inactivity
TMOUT=300

# Custom message before logout for ZSH
TRAPALRM() {
    print '\n👋 Hi, timed out waiting for input, bye!'
    kill -HUP $$
}

readonly TMOUT
export TMOUT
EOF
echo '✓ Added TMOUT to /etc/zsh/zshenv'

# Remove TMOUT from /etc/skel/.zshrc if exists (avoid conflicts)
sudo sed -i '/TMOUT/d' /etc/skel/.zshrc 2>/dev/null
sudo sed -i '/Auto logout after/d' /etc/skel/.zshrc 2>/dev/null

# ============ Method 2: ClientAlive (Network keepalive) ============
# Keep this to ensure disconnection when network has issues

echo ''
echo '2️⃣ Setting ClientAlive for network timeout...'

# Remove old configurations if exist
sudo sed -i '/^ClientAliveInterval/d' /etc/ssh/sshd_config 2>/dev/null
sudo sed -i '/^ClientAliveCountMax/d' /etc/ssh/sshd_config 2>/dev/null

# Add new configuration
echo 'ClientAliveInterval 60' | sudo tee -a /etc/ssh/sshd_config
echo 'ClientAliveCountMax 5' | sudo tee -a /etc/ssh/sshd_config
echo '✓ ClientAlive configured (60s × 5 = 300s)'

# ============ Restart SSH Service ============
echo ''
echo '3️⃣ Restarting SSH service...'

# Disable SSH socket to ensure sshd_config takes effect (Ubuntu 22.10+)
if systemctl list-units --full -all | grep -Fq "ssh.socket"; then
    sudo systemctl stop ssh.socket 2>/dev/null
    sudo systemctl disable ssh.socket 2>/dev/null
    sudo systemctl daemon-reload
    echo '✓ ssh.socket disabled'
fi

# Restart SSH service
if systemctl list-units --full -all | grep -Fq "sshd.service"; then
    sudo systemctl restart sshd
    echo '✓ sshd.service restarted'
elif systemctl list-units --full -all | grep -Fq "ssh.service"; then
    sudo systemctl restart ssh
    echo '✓ ssh.service restarted'
else
    printf "⚠️ Could not find SSH service, please restart it manually\n"
fi

echo ''
echo '=========================================='
echo '✨ SSH timeout configured successfully!'
echo '=========================================='
echo ''
echo '📌 TMOUT='$TIMEOUT_SECONDS's (5 minutes) - Logout when no command typed'
echo '📌 ClientAlive: 60s × 5 = 300s - Disconnect when network lost'
echo ''
echo '⚠️ NOTE:'
echo '   - TMOUT takes effect immediately for NEW sessions'
echo '   - Current session needs to logout and login again'
echo '   - Test: open new SSH, do nothing for 5 minutes'
echo ''
echo '🔍 Verify:'
echo "   echo \$TMOUT    # Should show 300"
echo '   grep TMOUT /etc/profile.d/ssh-timeout.sh  # For bash'
echo '   grep TMOUT /etc/zsh/zshenv               # For zsh'
