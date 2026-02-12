# Makefile for dotfiles_server
# Quick shortcuts for all installation commands

.PHONY: help setup ssh-port ssh-timeout hostname php php-ext lazydocker \
        global-dev add-user zabbix-server zabbix-client update-zabbix-ip \
        fix-mysql clean

# Default target - show help
help:
	@echo "=================================================="
	@echo "  Dotfiles Server - Quick Commands"
	@echo "=================================================="
	@echo ""
	@echo "Usage: make <command>"
	@echo ""
	@echo "System Setup:"
	@echo "  make setup                - Setup the server"
	@echo "  make ssh-port PORT=XXXX   - Change SSH port (default: 22)"
	@echo "  make ssh-timeout          - Configure SSH timeout (5min auto-disconnect)"
	@echo "  make hostname NAME=server - Change system hostname"
	@echo ""
	@echo "PHP & Development:"
	@echo "  make php                - Install PHP"
	@echo "  make php-ext VER=X.X    - Install PHP extensions (e.g., VER=8.4)"
	@echo "  make lazydocker         - Install lazydocker"
	@echo ""
	@echo "Global Dev Environment:"
	@echo "  make global-dev         - Setup NVM, NPM, Yarn, ZSH globally"
	@echo "  make global-dev-force   - Force update for all existing users"
	@echo "  make add-user USER=name - Add user to developers group"
	@echo "  make add-user-all       - Add all users to developers group"
	@echo ""
	@echo "Monitoring (Zabbix):"
	@echo "  make zabbix-server      - Install Zabbix Server"
	@echo "  make zabbix-client IP=X.X.X.X - Install Zabbix Agent (client)"
	@echo "  make update-zabbix-ip IP=X.X.X.X - Update Zabbix Server IP"
	@echo ""
	@echo "Database:"
	@echo "  make fix-mysql          - Fix MySQL frozen issue"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make ssh-port PORT=19742"
	@echo "  make hostname NAME=myserver"
	@echo "  make php-ext VER=8.4"
	@echo "  make global-dev-force"
	@echo "  make add-user USER=john"
	@echo "  make zabbix-client IP=192.168.1.100"
	@echo "  make update-zabbix-ip IP=192.168.1.200"
	@echo ""
	@echo "=================================================="

# System Setup Commands
setup:
	@bash install.sh setup

ssh-port:
	@if [ -z "$(PORT)" ]; then \
		bash install.sh ssh_port; \
	else \
		bash install.sh ssh_port $(PORT); \
	fi

ssh-timeout:
	@bash install.sh ssh_timeout

hostname:
	@if [ -z "$(NAME)" ]; then \
		sudo bash install.sh hostname; \
	else \
		sudo bash install.sh hostname $(NAME); \
	fi

# PHP & Development
php:
	@bash install.sh php

php-ext:
	@if [ -z "$(VER)" ]; then \
		bash install.sh php_extension; \
	else \
		bash install.sh php_extension $(VER); \
	fi

lazydocker:
	@bash install.sh lazydocker

# Global Dev Environment
global-dev:
	@sudo bash install.sh global_dev

global-dev-force:
	@sudo bash install.sh global_dev --force

add-user:
	@if [ -z "$(USER)" ]; then \
		echo "Error: USER parameter required"; \
		echo "Usage: make add-user USER=username"; \
		echo "   or: make add-user-all"; \
		exit 1; \
	else \
		sudo bash install.sh add_dev_user $(USER); \
	fi

add-user-all:
	@sudo bash install.sh add_dev_user --all

# Zabbix Monitoring
zabbix-server:
	@sudo bash install.sh zabbix_server

zabbix-client:
	@if [ -z "$(IP)" ]; then \
		sudo bash install.sh zabbix_client; \
	else \
		sudo bash install.sh zabbix_client $(IP); \
	fi

update-zabbix-ip:
	@if [ -z "$(IP)" ]; then \
		sudo bash install.sh update_zabbix_ip; \
	else \
		sudo bash install.sh update_zabbix_ip $(IP); \
	fi

# Database
fix-mysql:
	@sudo bash install.sh fix_mysql

# Clean / Maintenance
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.backup.*" -type f -mtime +30 -delete 2>/dev/null || true
	@echo "✓ Cleanup complete"

# Quick aliases (shorter versions)
s: setup
sp: ssh-port
st: ssh-timeout
hn: hostname
p: php
pe: php-ext
ld: lazydocker
gd: global-dev
gdf: global-dev-force
au: add-user
aua: add-user-all
zs: zabbix-server
zc: zabbix-client
uzi: update-zabbix-ip
fm: fix-mysql

# Show all available shortcuts
shortcuts:
	@echo "Quick Shortcuts:"
	@echo "  s   = setup"
	@echo "  sp  = ssh-port"
	@echo "  st  = ssh-timeout"
	@echo "  hn  = hostname"
	@echo "  p   = php"
	@echo "  pe  = php-ext"
	@echo "  ld  = lazydocker"
	@echo "  gd  = global-dev"
	@echo "  gdf = global-dev-force"
	@echo "  au  = add-user"
	@echo "  aua = add-user-all"
	@echo "  zs  = zabbix-server"
	@echo "  zc  = zabbix-client"
	@echo "  uzi = update-zabbix-ip"
	@echo "  fm  = fix-mysql"
	@echo ""
	@echo "Examples:"
	@echo "  make s"
	@echo "  make sp PORT=19742"
	@echo "  make hn NAME=myserver"
	@echo "  make pe VER=8.4"
	@echo "  make gdf"
	@echo "  make au USER=john"
	@echo "  make zc IP=192.168.1.100"
	@echo "  make uzi IP=192.168.1.200"

# Install/Update
install:
	@echo "Installing dotfiles_server..."
	@chmod +x install.sh
	@chmod +x setup/**/*.sh
	@echo "✓ Installation complete"
	@echo ""
	@echo "Run 'make help' to see available commands"

# Verify setup
verify:
	@echo "Verifying setup..."
	@echo ""
	@echo "Checking files..."
	@test -f install.sh && echo "✓ install.sh found" || echo "✗ install.sh missing"
	@test -d setup && echo "✓ setup/ directory found" || echo "✗ setup/ directory missing"
	@echo ""
	@echo "Checking permissions..."
	@test -x install.sh && echo "✓ install.sh is executable" || echo "✗ install.sh is not executable"
	@echo ""
	@echo "Checking shell..."
	@echo "Current shell: $$SHELL"
	@echo ""
	@echo "✓ Verification complete"

# Update from git
update:
	@echo "Updating from git repository..."
	@git pull origin main
	@chmod +x install.sh
	@chmod +x setup/**/*.sh
	@echo "✓ Update complete"

# Show version/info
info:
	@echo "Dotfiles Server Information"
	@echo "=================================================="
	@echo "Repository: dotfiles_server"
	@echo "Location: $$(pwd)"
	@echo "Branch: $$(git branch --show-current 2>/dev/null || echo 'N/A')"
	@echo "Last commit: $$(git log -1 --oneline 2>/dev/null || echo 'N/A')"
	@echo "=================================================="

# Test connections
test-ssh:
	@echo "Testing SSH configuration..."
	@sudo sshd -t && echo "✓ SSH config is valid" || echo "✗ SSH config has errors"

test-zabbix:
	@if command -v zabbix_agent2 >/dev/null 2>&1; then \
		echo "✓ Zabbix Agent 2 is installed"; \
		sudo systemctl is-active --quiet zabbix-agent2 && echo "✓ Zabbix Agent 2 is running" || echo "✗ Zabbix Agent 2 is not running"; \
	elif command -v zabbix_agentd >/dev/null 2>&1; then \
		echo "✓ Zabbix Agent is installed"; \
		sudo systemctl is-active --quiet zabbix-agent && echo "✓ Zabbix Agent is running" || echo "✗ Zabbix Agent is not running"; \
	else \
		echo "✗ Zabbix Agent is not installed"; \
	fi

test-nvm:
	@if [ -d "/usr/local/nvm" ]; then \
		echo "✓ NVM is installed at /usr/local/nvm"; \
		if getent group developers >/dev/null 2>&1; then \
			echo "✓ developers group exists"; \
			echo "  Members: $$(getent group developers | cut -d: -f4)"; \
		else \
			echo "✗ developers group does not exist"; \
		fi; \
	else \
		echo "✗ NVM is not installed"; \
	fi

# Run all tests
test-all: test-ssh test-zabbix test-nvm
	@echo ""
	@echo "✓ All tests complete"

