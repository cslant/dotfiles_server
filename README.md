# Dotfiles Server

This script is used to set up a new server with my dotfiles.

## OS Availability:
- [x] Ubuntu 20.04
- [x] Ubuntu 22.04
- [x] Debian 10

## Installation

Clone the repository and run the script:

```bash
# git clone --depth=1 https://github.com/tanhongit/dotfiles_server.git
git clone git@github.com:tanhongit/dotfiles_server.git
```

```bash
cd dotfiles_server
```

### Method 1: Using Makefile (Recommended)

Quick and easy commands using Make:

```bash
# Show all available commands
make help

# Setup server
make setup
# or use short alias
make s
```

> See [Makefile Guide](docs/MAKEFILE-GUIDE.md) for complete documentation.

### Method 2: Direct Script

```bash
./install.sh a
```

> Note: You may need to make the script executable by running `chmod +x install.sh` before running it.
> 
> ```bash
> chmod +x install.sh
> ```

## Quick Commands (Makefile)

| Command | Description | Short Alias |
|---------|-------------|-------------|
| `make setup` | Setup the server | `make s` |
| `make ssh-port PORT=XXXX` | Change SSH port | `make sp PORT=XXXX` |
| `make ssh-timeout` | Configure SSH timeout | `make st` |
| `make ufw-setup SSH_PORT=XXXX` | Install/configure UFW | `make ufw SSH_PORT=XXXX` |
| `make php` | Install PHP | `make p` |
| `make php-ext VER=X.X` | Install PHP extensions | `make pe VER=X.X` |
| `make zsh-global` | Setup only ZSH global | `make zg` |
| `make global-dev` | Setup NVM, NPM, Yarn, ZSH | `make gd` |
| `make add-user USER=name` | Add user to developers group | `make au USER=name` |
| `make zabbix-server` | Install Zabbix Server | `make zs` |
| `make zabbix-client IP=X.X.X.X` | Install Zabbix Agent | `make zc IP=X.X.X.X` |
| `make update-zabbix-ip IP=X.X.X.X` | Update Zabbix Server IP | `make uzi IP=X.X.X.X` |

**Examples:**
```bash
make setup
make ssh-port PORT=19742
make ufw-setup SSH_PORT=19742
make zsh-global
make global-dev
make add-user USER=john
make zabbix-client IP=192.168.1.100
```

Full documentation: [Makefile Guide](docs/MAKEFILE-GUIDE.md)

## Usage

The runner has the following commands:

| Command                   | Description                                             |
|---------------------------|---------------------------------------------------------|
| `setup`, `s`, `a`         | Setup the server                                        |
| `ssh_port`, `sp`          | Change the SSH port                                     |
| `ssh_timeout`, `st`       | Configure SSH timeout (auto disconnect after 5min idle) |
| `ufw_setup`, `ufw`        | Install and configure UFW firewall                      |
| `php`, `php-install`      | Install PHP version you want                            |
| `php_extension`, `pe`     | Install PHP extensions                                  |
| `lazydocker`, `ld`        | Install lazydocker                                      |
| `zsh_global`, `zg`        | Setup ZSH globally (standalone)                         |
| `global_dev`, `gd`        | Setup NVM, NPM, Yarn, ZSH globally for all users        |
| `add_dev_user`, `adu`     | Add user(s) to developers group for dev tools access    |
| `zabbix_server`, `zs`     | Install Zabbix Server with auto web server detection    |
| `zabbix_client`, `zc`     | Install Zabbix Agent (client)                           |
| `update_zabbix_ip`, `uzi` | Update Zabbix Server IP for installed agent             |
| `fix_mysql`, `fmf`        | Fix MySQL FROZEN issue (when downgrading from MariaDB)  |

### Standalone ZSH Global Setup

Setup only ZSH + Oh-My-Zsh globally (without NVM/Yarn):

```bash
sudo bash install.sh zsh_global
# or
sudo bash install.sh zg
```

Force update dotfiles for all existing users:

```bash
sudo bash install.sh zsh_global --force
```

### UFW Setup

Install and configure UFW firewall with safe defaults:

```bash
# Auto-detect SSH port from sshd_config (fallback 22)
sudo bash install.sh ufw_setup

# Or set SSH port manually
sudo bash install.sh ufw_setup 19742
```

This command will:
- ✓ Install UFW (if missing)
- ✓ Set default deny incoming / allow outgoing
- ✓ Allow SSH port, 80/tcp, and 443/tcp
- ✓ Enable and reload firewall

### Global Dev Setup

Setup development environment globally for all users (including new users):

```bash
sudo bash install.sh global_dev
# or
sudo bash install.sh gd
```

This will install and configure:
- ✓ ZSH with Oh-My-Zsh (Powerlevel10k theme)
- ✓ NVM (Node Version Manager) at `/usr/local/nvm`
- ✓ Node.js (LTS version)
- ✓ NPM (Node Package Manager) with global packages at `/usr/local/nvm/npm-global`
- ✓ Yarn (Package Manager) with global packages at `/usr/local/nvm/yarn-global`
- ✓ Creates `developers` group with proper permissions

**Force update dotfiles for all existing users:**

```bash
sudo bash install.sh global_dev -f
# or
sudo bash install.sh gd --force
```

The `-f` or `--force` flag will:
- Force copy/update all dotfiles (.zshrc, .zsh_aliases, .p10k.zsh) from `home/` folder to all existing users
- Backup existing dotfiles before updating
- Apply new configuration to all users with UID >= 1000
- Automatically add all existing users to `developers` group

#### Managing User Permissions

After installing global dev tools, users need to be added to the `developers` group to use NVM, NPM, and Yarn:

**Add specific user(s):**

```bash
sudo bash install.sh add_dev_user john
# or multiple users
sudo bash install.sh add_dev_user john mary bob
```

**Add all existing users:**

```bash
sudo bash install.sh add_dev_user --all
# or
sudo bash install.sh adu -a
```

**Important:** Users must logout and login again (or run `newgrp developers`) to apply group membership.

After that, users can:
- Install Node.js versions: `nvm install 22`
- Install npm packages globally: `npm install -g <package>`
- Install yarn packages globally: `yarn global add <package>`

**Benefits of using `developers` group:**
- ✓ No need to use `sudo` for installing packages
- ✓ All users in the group share the same Node.js versions
- ✓ Centralized package management
- ✓ Secure permissions (only authorized users can install packages)

### Zabbix Setup

Setup Zabbix monitoring system with automatic web server detection:

**Install Zabbix Server:**

```bash
sudo bash install.sh zabbix_server
# or
sudo bash install.sh zs
```

Features:
- ✓ Auto-detects Nginx or Apache (or lets you choose)
- ✓ Installs MySQL database
- ✓ Configures Zabbix Server, Frontend, and Agent
- ✓ Generates secure random passwords
- ✓ Configures firewall automatically
- ✓ Supports Ubuntu 20.04, 22.04, 24.04
- ✓ Zabbix 7.0 LTS

**Install Zabbix Agent (Client):**

```bash
# Method 1: Will prompt for Server IP
sudo bash install.sh zabbix_client
# or
sudo bash install.sh zc

# Method 2: Pass Server IP directly
sudo bash install.sh zabbix_client 192.168.1.100
# or
sudo bash install.sh zc 192.168.1.100
```

Features:
- ✓ Installs Zabbix Agent
- ✓ Prompts for Zabbix Server IP
- ✓ Configures agent to connect to server
- ✓ Configures firewall automatically

**Update Zabbix Server IP (for already installed agents):**

```bash
# Method 1: Will prompt for new Server IP
sudo bash install.sh update_zabbix_ip
# or
sudo bash install.sh uzi

# Method 2: Pass new Server IP directly
sudo bash install.sh update_zabbix_ip 192.168.1.200
# or
sudo bash install.sh uzi 192.168.1.200
```

Features:
- ✓ Updates existing Zabbix Agent configuration
- ✓ Validates IP address format
- ✓ Creates backup before changes
- ✓ Auto-restarts agent service
- ✓ Verifies connection to new server
- ✓ Supports both Zabbix Agent and Agent2

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
