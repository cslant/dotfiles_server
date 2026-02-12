#!/bin/bash

# Install NVM globally for all users (including new users)

echo "================================"
echo "Setting up NVM globally for all users"
echo "================================"
echo ""

# Define NVM installation directory
NVM_DIR="/usr/local/nvm"
NVM_VERSION="v0.40.1"

# Create NVM directory if it doesn't exist
if [ ! -d "$NVM_DIR" ]; then
    echo "Creating NVM directory at $NVM_DIR..."
    sudo mkdir -p "$NVM_DIR"
fi

# Download and install NVM to global location
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Installing NVM $NVM_VERSION to $NVM_DIR..."
    sudo curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | sudo bash
    sudo mv "$HOME/.nvm/"* "$NVM_DIR/" 2>/dev/null || true
    sudo rm -rf "$HOME/.nvm" 2>/dev/null || true
else
    echo "✓ NVM already installed at $NVM_DIR"
fi

# Create developers group if it doesn't exist
if ! getent group developers > /dev/null 2>&1; then
    echo "Creating 'developers' group..."
    sudo groupadd developers
fi

# Set ownership and permissions for all users
echo "Setting permissions for all users..."
sudo chown -R root:developers "$NVM_DIR"
sudo chmod -R 775 "$NVM_DIR"
sudo find "$NVM_DIR" -type d -exec chmod 775 {} \;
sudo find "$NVM_DIR" -type f -exec chmod 664 {} \;
sudo chmod +x "$NVM_DIR/nvm.sh"
sudo chmod +x "$NVM_DIR/bash_completion" 2>/dev/null || true

# Set SGID bit so new files inherit group ownership
sudo find "$NVM_DIR" -type d -exec chmod g+s {} \;

# Create profile.d script to load NVM for all users
echo "Creating /etc/profile.d/nvm.sh for auto-loading..."
sudo tee /etc/profile.d/nvm.sh > /dev/null <<'EOF'
# NVM configuration for all users
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# NPM global packages directory
export NPM_GLOBAL_DIR="/usr/local/nvm/npm-global"
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
EOF

sudo chmod +x /etc/profile.d/nvm.sh

# Create zshrc config for NVM
echo "Creating zsh configuration for NVM..."
sudo tee /etc/zsh/nvm.zsh > /dev/null <<'EOF'
# NVM configuration for zsh users
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# NPM global packages directory
export NPM_GLOBAL_DIR="/usr/local/nvm/npm-global"
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
EOF

sudo chmod +x /etc/zsh/nvm.zsh

# Load NVM for current session
export NVM_DIR="/usr/local/nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest LTS Node.js version
if command -v nvm &>/dev/null; then
    echo "Installing latest LTS Node.js version..."
    if ! nvm install --lts --reinstall-packages-from=current; then
        echo "Cleaning up existing Node.js installation directories..."
        NODE_VERSION=$(nvm version-remote --lts)
        if [ -d "$NVM_DIR/versions/node/$NODE_VERSION" ]; then
            sudo rm -rf "$NVM_DIR/versions/node/$NODE_VERSION"
        fi
        nvm install --lts
    fi
    nvm use --lts
    nvm alias default 'lts/*'

    echo ""
    echo "✓ Node.js installed successfully"
    node --version
    npm --version

    # Setup npm global directory with proper permissions
    echo ""
    echo "Configuring npm global directory..."
    NPM_GLOBAL_DIR="/usr/local/nvm/npm-global"
    sudo mkdir -p "$NPM_GLOBAL_DIR"
    sudo chown -R root:developers "$NPM_GLOBAL_DIR"
    sudo chmod -R 775 "$NPM_GLOBAL_DIR"
    sudo chmod g+s "$NPM_GLOBAL_DIR"

    # Configure npm to use this directory
    npm config set prefix "$NPM_GLOBAL_DIR"

    # Add to PATH in profile
    if ! grep -q "NPM_GLOBAL_DIR" /etc/profile.d/nvm.sh; then
        sudo tee -a /etc/profile.d/nvm.sh > /dev/null <<'NPMEOF'
# NPM global packages directory
export NPM_GLOBAL_DIR="/usr/local/nvm/npm-global"
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
NPMEOF
    fi

    echo "✓ NPM global directory configured at $NPM_GLOBAL_DIR"
else
    echo "⚠️  Please logout and login again to use nvm"
fi

# Add NVM config to /etc/skel for new users
echo ""
echo "Adding NVM configuration to /etc/skel for new users..."

# For bash users
if [ ! -f /etc/skel/.bashrc ]; then
    sudo touch /etc/skel/.bashrc
fi

if ! grep -q "NVM_DIR" /etc/skel/.bashrc; then
    sudo tee -a /etc/skel/.bashrc > /dev/null <<'EOF'

# NVM configuration
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
    echo "✓ Added NVM to /etc/skel/.bashrc"
fi

# For zsh users
if [ ! -f /etc/skel/.zshrc ]; then
    sudo touch /etc/skel/.zshrc
fi

if ! grep -q "NVM_DIR" /etc/skel/.zshrc; then
    sudo tee -a /etc/skel/.zshrc > /dev/null <<'EOF'

# NVM configuration
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
    echo "✓ Added NVM to /etc/skel/.zshrc"
fi

# Update existing users (optional - only for current user)
CURRENT_USER_HOME="$HOME"
if [ -f "$CURRENT_USER_HOME/.bashrc" ] && ! grep -q "NVM_DIR.*usr/local/nvm" "$CURRENT_USER_HOME/.bashrc"; then
    {
        echo ""
        echo "# NVM configuration"
        echo "export NVM_DIR=\"/usr/local/nvm\""
        echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\""
        echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\""
    } >> "$CURRENT_USER_HOME/.bashrc"
    echo "✓ Updated current user's .bashrc"
fi

if [ -f "$CURRENT_USER_HOME/.zshrc" ] && ! grep -q "NVM_DIR.*usr/local/nvm" "$CURRENT_USER_HOME/.zshrc"; then
    {
        echo ""
        echo "# NVM configuration"
        echo "export NVM_DIR=\"/usr/local/nvm\""
        echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\""
        echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\""
    } >> "$CURRENT_USER_HOME/.zshrc"
    echo "✓ Updated current user's .zshrc"
fi

echo ""
echo "================================"
echo "✓ NVM global setup completed!"
echo "================================"
echo ""
echo "📌 NVM installed at: $NVM_DIR"
echo "📌 NPM global packages at: /usr/local/nvm/npm-global"
echo "📌 All users in 'developers' group can use NVM without sudo"
echo ""
echo "📌 To add a user to developers group:"
echo "   sudo usermod -aG developers <username>"
echo ""
echo "📌 All new users will have NVM automatically configured"
echo "📌 To use NVM in current session:"
echo "   source /etc/profile.d/nvm.sh"
echo ""
echo "📌 Verify installation:"
echo "   nvm --version"
echo "   node --version"
echo "   npm --version"
echo ""
