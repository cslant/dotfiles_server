# Quick Reference - All Available Commands

## 🚀 Main Setup
```bash
bash install.sh setup        # Full server setup
bash install.sh s            # Short version
bash install.sh a            # Short version
```

## 🔐 SSH Configuration
```bash
bash install.sh ssh_port     # Change SSH port
bash install.sh sp           # Short version

bash install.sh ssh_timeout  # Auto logout after 5min idle
bash install.sh st           # Short version
```

## 🐘 PHP Installation
```bash
bash install.sh php          # Install PHP
bash install.sh php_extension 8.4  # Install PHP 8.4 extensions
bash install.sh pe 8.4       # Short version
```

## 🐳 Docker Tools
```bash
bash install.sh lazydocker   # Install lazydocker
bash install.sh ld           # Short version

bash install.sh docker         # Install Docker & Docker Compose (with optional lazydocker)
```

## 🌍 Global Development Environment
```bash
# Install NVM, NPM, Yarn, ZSH for all users
bash install.sh global_dev
bash install.sh gd           # Short version

# Force update for existing users
bash install.sh global_dev -f
bash install.sh gd --force
```

## 📊 Zabbix Monitoring

### Install Zabbix Server
```bash
bash install.sh zabbix_server
bash install.sh zs           # Short version
```
Features:
- Auto-detects Nginx/Apache
- MySQL/MariaDB database
- Zabbix 7.0 LTS
- Secure random passwords
- Firewall configuration

### Install Zabbix Agent (Client)
```bash
# Will prompt for Server IP
bash install.sh zabbix_client
bash install.sh zc           # Short version

# Pass Server IP directly
bash install.sh zabbix_client 192.168.1.100
bash install.sh zc 192.168.1.100
```

## 🔧 Troubleshooting

### Fix MySQL FROZEN Issue
When you see "MySQL has been frozen" error:
```bash
bash install.sh fix_mysql
bash install.sh fix_mysql_frozen
bash install.sh fmf          # Short version
```

This fixes the issue when downgrading from MariaDB to MySQL.

## 📋 All Commands Summary

| Command | Short | Description |
|---------|-------|-------------|
| `setup` | `s`, `a` | Full server setup |
| `ssh_port` | `sp` | Change SSH port |
| `ssh_timeout` | `st` | Configure SSH timeout |
| `php` | - | Install PHP |
| `php_extension` | `pe` | Install PHP extensions |
| `lazydocker` | `ld` | Install lazydocker |
| `docker` | - | Install Docker & Docker Compose (with optional lazydocker) |
| `global_dev` | `gd` | Global dev environment |
| `zabbix_server` | `zs` | Install Zabbix Server |
| `zabbix_client` | `zc` | Install Zabbix Agent |
| `fix_mysql` | `fmf` | Fix MySQL FROZEN issue |

## 💡 Examples

```bash
# Setup new server
bash install.sh setup

# Change SSH port to 2222
bash install.sh ssh_port 2222

# Install PHP 8.4 extensions
bash install.sh php_extension 8.4

# Setup Zabbix monitoring
bash install.sh zabbix_server
bash install.sh zabbix_client 192.168.1.100

# Fix MySQL issue
bash install.sh fix_mysql

# Global dev environment with force update
sudo bash install.sh global_dev --force
```

## 🆘 Need Help?

```bash
bash install.sh
# Shows usage information
```

For detailed documentation, see:
- [README.md](../README.md) - Full documentation
- [ZABBIX-SETUP.md](setup/system/ZABBIX-SETUP.md) - Zabbix guide
- [SSH-TIMEOUT-DEBUG.md](setup/system/SSH-TIMEOUT-DEBUG.md) - SSH timeout debug

