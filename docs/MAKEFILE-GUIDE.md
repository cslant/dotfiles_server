# Makefile Usage Guide

## Overview

This Makefile provides convenient shortcuts for all installation commands in the dotfiles_server project. Instead of typing long commands, you can use simple `make` commands.

## Quick Start

```bash
# Show all available commands
make help

# Show quick shortcuts
make shortcuts
```

## Installation & Setup

### First Time Setup

```bash
# Make scripts executable
make install

# Verify setup
make verify
```

### Update from Git

```bash
make update
```

## Command Reference

### System Setup

| Command | Description | Example |
|---------|-------------|---------|
| `make setup` | Setup the server | `make setup` |
| `make ssh-port PORT=XXXX` | Change SSH port | `make ssh-port PORT=19742` |
| `make ssh-timeout` | Configure SSH timeout | `make ssh-timeout` |
| `make ufw-setup SSH_PORT=XXXX` | Install/configure UFW | `make ufw-setup SSH_PORT=19742` |

**Shortcuts:** `make s`, `make sp PORT=XXXX`, `make st`, `make ufw SSH_PORT=XXXX`

---

### PHP & Development

| Command | Description | Example |
|---------|-------------|---------|
| `make php` | Install PHP | `make php` |
| `make php-ext VER=X.X` | Install PHP extensions | `make php-ext VER=8.4` |
| `make lazydocker` | Install lazydocker | `make lazydocker` |

**Shortcuts:** `make p`, `make pe VER=8.4`, `make ld`

---

### Global Dev Environment

| Command | Description | Example |
|---------|-------------|---------|
| `make global-dev` | Setup NVM, NPM, Yarn, ZSH globally | `make global-dev` |
| `make global-dev-force` | Force update for all users | `make global-dev-force` |
| `make zsh-global` | Setup only ZSH globally | `make zsh-global` |
| `make zsh-global-force` | Force update ZSH dotfiles for all users | `make zsh-global-force` |
| `make add-user USER=name` | Add user to developers group | `make add-user USER=john` |
| `make add-user-all` | Add all users to group | `make add-user-all` |

**Shortcuts:** `make gd`, `make gdf`, `make zg`, `make zgf`, `make au USER=john`, `make aua`

---

### Zabbix Monitoring

| Command | Description | Example |
|---------|-------------|---------|
| `make zabbix-server` | Install Zabbix Server | `make zabbix-server` |
| `make zabbix-client IP=X.X.X.X` | Install Zabbix Agent | `make zabbix-client IP=192.168.1.100` |
| `make update-zabbix-ip IP=X.X.X.X` | Update Zabbix Server IP | `make update-zabbix-ip IP=192.168.1.200` |

**Shortcuts:** `make zs`, `make zc IP=192.168.1.100`, `make uzi IP=192.168.1.200`

---

### Database

| Command | Description | Example |
|---------|-------------|---------|
| `make fix-mysql` | Fix MySQL frozen issue | `make fix-mysql` |

**Shortcuts:** `make fm`

---

## Usage Examples

### Basic Setup

```bash
# 1. First time setup
make install

# 2. Setup server
make setup

# 3. Configure SSH timeout
make ssh-timeout

# 4. Change SSH port
make ssh-port PORT=19742

# 5. Setup firewall
make ufw-setup SSH_PORT=19742
```

### Development Environment

```bash
# Install global dev tools
make global-dev

# Install only ZSH global
make zsh-global

# Add current user to developers group (already done by global-dev)
# Add additional users
make add-user USER=john
make add-user USER=mary

# Or add all users at once
make add-user-all

# Force update all existing users
make global-dev-force
```

### PHP Development

```bash
# Install PHP
make php

# Install PHP 8.4 extensions
make php-ext VER=8.4

# Install lazydocker
make lazydocker
```

### Zabbix Monitoring

```bash
# On monitoring server
make zabbix-server

# On client servers (method 1: interactive)
make zabbix-client

# On client servers (method 2: direct)
make zabbix-client IP=192.168.1.100

# Update Zabbix Server IP on existing clients
make update-zabbix-ip IP=192.168.1.200
```

### Using Shortcuts

```bash
# Setup
make s                    # instead of: make setup

# SSH
make sp PORT=19742       # instead of: make ssh-port PORT=19742
make st                  # instead of: make ssh-timeout

# PHP
make p                   # instead of: make php
make pe VER=8.4         # instead of: make php-ext VER=8.4

# Dev environment
make gd                  # instead of: make global-dev
make gdf                 # instead of: make global-dev-force
make zg                  # instead of: make zsh-global
make zgf                 # instead of: make zsh-global-force
make au USER=john        # instead of: make add-user USER=john

# Zabbix
make zs                  # instead of: make zabbix-server
make zc IP=192.168.1.100 # instead of: make zabbix-client IP=192.168.1.100
make uzi IP=192.168.1.200 # instead of: make update-zabbix-ip IP=192.168.1.200

# Database
make fm                  # instead of: make fix-mysql
```

## Utility Commands

### Testing & Verification

```bash
# Verify installation
make verify

# Test SSH configuration
make test-ssh

# Test Zabbix Agent
make test-zabbix

# Test NVM installation
make test-nvm

# Run all tests
make test-all
```

### Information

```bash
# Show repository info
make info

# Show available shortcuts
make shortcuts

# Show help
make help
```

### Maintenance

```bash
# Update from git
make update

# Clean old backups (older than 30 days)
make clean
```

## Advanced Usage

### Chaining Commands

```bash
# Setup server, install PHP, and global dev tools
make setup && make php && make global-dev

# Install Zabbix client and update IP
make zabbix-client IP=192.168.1.100 && make update-zabbix-ip IP=192.168.1.200
```

### Variables

You can pass variables to make commands:

```bash
# SSH port
make ssh-port PORT=19742

# UFW SSH port
make ufw-setup SSH_PORT=19742

# PHP version
make php-ext VER=8.4

# Username
make add-user USER=john

# IP address
make zabbix-client IP=192.168.1.100
make update-zabbix-ip IP=192.168.1.200
```

### Multiple Users

```bash
# Add multiple users one by one
make add-user USER=john
make add-user USER=mary
make add-user USER=bob

# Or add all users at once
make add-user-all
```

## Comparison: Makefile vs Direct Script

| Task | Direct Script | Makefile |
|------|---------------|----------|
| Setup | `bash install.sh setup` | `make setup` or `make s` |
| Change SSH port | `bash install.sh ssh_port 19742` | `make ssh-port PORT=19742` or `make sp PORT=19742` |
| Setup UFW | `sudo bash install.sh ufw_setup 19742` | `make ufw-setup SSH_PORT=19742` or `make ufw SSH_PORT=19742` |
| Install PHP ext | `bash install.sh php_extension 8.4` | `make php-ext VER=8.4` or `make pe VER=8.4` |
| ZSH global only | `sudo bash install.sh zsh_global` | `make zsh-global` or `make zg` |
| Global dev | `sudo bash install.sh global_dev` | `make global-dev` or `make gd` |
| Add user | `sudo bash install.sh add_dev_user john` | `make add-user USER=john` or `make au USER=john` |
| Zabbix client | `sudo bash install.sh zabbix_client 192.168.1.100` | `make zabbix-client IP=192.168.1.100` or `make zc IP=192.168.1.100` |
| Update Zabbix IP | `sudo bash install.sh update_zabbix_ip 192.168.1.200` | `make update-zabbix-ip IP=192.168.1.200` or `make uzi IP=192.168.1.200` |

## Benefits of Using Makefile

✅ **Shorter commands** - Less typing
✅ **Easy to remember** - Consistent naming
✅ **Tab completion** - Works with shell completion
✅ **Self-documenting** - Built-in help system
✅ **Error checking** - Validates parameters
✅ **Shortcuts** - Even shorter aliases
✅ **Utility functions** - Testing, verification, cleanup

## Troubleshooting

### Command Not Found

If `make` is not installed:

```bash
# Ubuntu/Debian
sudo apt-get install make

# CentOS/RHEL
sudo yum install make
```

### Permission Denied

Some commands require sudo. Makefile handles this automatically, but ensure you have sudo access:

```bash
# Check sudo access
sudo -v
```

### Variable Not Set

If you forget to set a required variable:

```bash
# This will show an error
make add-user

# Correct usage
make add-user USER=john
```

### See What Commands Are Running

Add `-n` flag to see what would be executed without running:

```bash
make -n setup
make -n ssh-port PORT=19742
```

## Tips & Tricks

### 1. Use Tab Completion

```bash
make <TAB>      # Shows all available targets
make ssh-<TAB>  # Shows ssh-related targets
```

### 2. Check Before Running

```bash
# Dry run - see what will be executed
make -n setup
make -n global-dev
```

### 3. Run Multiple Commands

```bash
# Use && to chain commands
make setup && make global-dev && make lazydocker
```

### 4. Save Frequent Commands

Create aliases in your `.bashrc` or `.zshrc`:

```bash
alias mgs='make global-dev'
alias mau='make add-user USER='
alias mzc='make zabbix-client IP='
```

### 5. Use Shortcuts

All commands have short versions:
- `s` = setup
- `sp` = ssh-port
- `st` = ssh-timeout
- `ufw` = ufw-setup
- `zg` = zsh-global
- `gd` = global-dev
- `zc` = zabbix-client
- etc.

## FAQ

**Q: Do I need to use Makefile?**
A: No, you can still use `bash install.sh` directly. Makefile is just a convenience wrapper.

**Q: Can I add my own commands?**
A: Yes, edit the Makefile and add your custom targets.

**Q: Why do some commands need sudo?**
A: Commands that modify system files or services need root privileges. Makefile handles this automatically.

**Q: Can I use this in scripts?**
A: Yes, you can use make commands in your automation scripts.

**Q: What if I don't have make installed?**
A: Install it with your package manager or use the direct script commands.

## Summary

The Makefile provides:
- 🚀 **Quick shortcuts** for all commands
- 📝 **Easy to remember** command names
- ✅ **Built-in help** and documentation
- 🔧 **Utility functions** for testing and maintenance
- 💡 **Short aliases** for frequent tasks

Instead of:
```bash
sudo bash install.sh add_dev_user john
```

Just type:
```bash
make au USER=john
```

Enjoy the simplified workflow! 🎉
