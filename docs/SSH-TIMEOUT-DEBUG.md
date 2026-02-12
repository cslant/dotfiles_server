# SSH Auto-Logout Debug Guide

## Problem: SSH does not auto logout after 5 minutes

### Step 1: Check current configuration

Run the verify script:
```bash
bash /path/to/setup/system/verify-ssh-timeout.sh
```

Or check manually:
```bash
grep -E "^ClientAlive" /etc/ssh/sshd_config
```

### Step 2: Common causes

#### ✅ Cause 1: ssh.socket is overriding configuration
**Symptom:** Port in sshd_config has no effect
**Solution:**
```bash
sudo systemctl stop ssh.socket
sudo systemctl disable ssh.socket
sudo systemctl daemon-reload
sudo systemctl restart ssh
```

#### ✅ Cause 2: Duplicate or commented configuration
**Check:**
```bash
grep -n "ClientAlive" /etc/ssh/sshd_config
```

**Solution:** Remove all old lines and add again:
```bash
sudo sed -i '/^ClientAliveInterval/d' /etc/ssh/sshd_config
sudo sed -i '/^ClientAliveCountMax/d' /etc/ssh/sshd_config
echo 'ClientAliveInterval 60' | sudo tee -a /etc/ssh/sshd_config
echo 'ClientAliveCountMax 5' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh
```

#### ✅ Cause 3: SSH client has its own keepalive
**Symptom:** Mac/Windows Terminal automatically sends keepalive
**Check client:**
- Mac/Linux: `cat ~/.ssh/config | grep ServerAlive`
- Windows: Check PuTTY/Terminal settings

**Solution:** Disable keepalive on client or reduce server timeout:
```bash
# Server side - reduce to 3 minutes for testing
ClientAliveInterval 30
ClientAliveCountMax 6
# = 30s × 6 = 180s (3 minutes)
```

#### ✅ Cause 4: Service not restarted properly
**Solution:**
```bash
# Check service name
systemctl list-units | grep ssh

# Restart the correct service
sudo systemctl restart sshd  # or
sudo systemctl restart ssh

# Verify
sudo systemctl status sshd --no-pager
```

### Step 3: Test timeout

**Test 1: Check if config is loaded**
```bash
sudo sshd -T | grep clientalive
```
Expected result:
```
clientaliveinterval 60
clientalivecountmax 5
```

**Test 2: Open a new session and wait**
1. Keep the current session open
2. Open a new terminal: `ssh user@server`
3. Do nothing for 5 minutes
4. The new session should auto disconnect

**Test 3: Check logs**
```bash
# View SSH log in realtime
sudo tail -f /var/log/auth.log | grep sshd

# Or
sudo journalctl -u ssh -f
```

### Step 4: Advanced troubleshooting

#### Check all related processes:
```bash
ps aux | grep sshd
sudo ss -tlnp | grep ssh
```

#### Check Drop-in configs:
```bash
ls -la /etc/ssh/sshd_config.d/
cat /etc/ssh/sshd_config.d/*.conf 2>/dev/null
```

#### Full reset:
```bash
# Backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Remove all ClientAlive
sudo sed -i '/ClientAlive/d' /etc/ssh/sshd_config

# Add fresh config
sudo tee -a /etc/ssh/sshd_config << 'EOF'

# Auto disconnect after 5 minutes idle
ClientAliveInterval 60
ClientAliveCountMax 5
EOF

# Restart everything
sudo systemctl stop ssh.socket 2>/dev/null
sudo systemctl disable ssh.socket 2>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart ssh
```

### Step 5: If still not working

Try with TCPKeepAlive (different from ClientAlive):
```bash
echo 'TCPKeepAlive yes' | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh
```

Or use a more aggressive configuration:
```bash
ClientAliveInterval 30
ClientAliveCountMax 3
# = 30s × 3 = 90s (1.5 minutes timeout)
```

### ⚠️ IMPORTANT NOTES

1. **Always keep the current session open** when testing to avoid locking yourself out
2. **Test with a new session** before closing the old one
3. **Firewall** may keep the connection alive, check with:
   ```bash
   sudo iptables -L -n -v | grep ESTABLISHED
   ```
4. **Client-side keepalive** may override server config

### Auto-fix script

Rerun the setup script with force:
```bash
sudo bash /path/to/setup/system/ssh_timeout.sh
```

Then verify:
```bash
bash /path/to/setup/system/verify-ssh-timeout.sh
```
