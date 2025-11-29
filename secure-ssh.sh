#!/bin/bash
set -e

# This script must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo or as root."
  exit 1
fi

echo "[-] Setting new password for ubuntu user"

read -s -p "New password for ubuntu: " UBUNTU_PASS
echo
read -s -p "Confirm password: " UBUNTU_PASS2
echo

if [ "$UBUNTU_PASS" != "$UBUNTU_PASS2" ]; then
  echo "[!] Passwords do not match. Script aborted."
  exit 1
fi

echo "ubuntu:$UBUNTU_PASS" | chpasswd
echo "[+] Password for ubuntu successfully set."

SSHD_CONF="/etc/ssh/sshd_config"

echo "[-] Backing up sshd_config file"
cp "$SSHD_CONF" "${SSHD_CONF}.$(date +%F-%H%M%S).bak"

echo "[-] Setting SSH port to 10808"

if grep -qE '^Port ' "$SSHD_CONF"; then
  sed -i 's/^Port .*/Port 10808/' "$SSHD_CONF"
elif grep -qE '^#Port ' "$SSHD_CONF"; then
  sed -i 's/^#Port .*/Port 10808/' "$SSHD_CONF"
else
  echo 'Port 10808' >> "$SSHD_CONF"
fi

echo "[-] Disabling root login"

if grep -qE '^PermitRootLogin ' "$SSHD_CONF"; then
  sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' "$SSHD_CONF"
else
  echo 'PermitRootLogin no' >> "$SSHD_CONF"
fi

echo "[-] Enabling password authentication and disabling key authentication"
if grep -qE '^PasswordAuthentication ' "$SSHD_CONF"; then
  sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONF"
else
  echo 'PasswordAuthentication yes' >> "$SSHD_CONF"
fi

if grep -qE '^PubkeyAuthentication ' "$SSHD_CONF"; then
  sed -i 's/^PubkeyAuthentication .*/PubkeyAuthentication no/' "$SSHD_CONF"
else
  echo 'PubkeyAuthentication no' >> "$SSHD_CONF"
fi

echo "[-] Restricting SSH access to ubuntu user only"

if grep -qE '^AllowUsers ' "$SSHD_CONF"; then
  sed -i 's/^AllowUsers .*/AllowUsers ubuntu/' "$SSHD_CONF"
else
  echo 'AllowUsers ubuntu' >> "$SSHD_CONF"
fi

echo "[-] Installing fail2ban"

apt update -y
apt install -y fail2ban

echo "[-] Configuring fail2ban for SSH on port 10808"

mkdir -p /etc/fail2ban/jail.d

cat >/etc/fail2ban/jail.d/ssh-hardening.conf <<EOF
[sshd]
enabled = true
port = 10808
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 1h
findtime = 10m
EOF

echo "[-] Checking sshd configuration"

sshd -t

echo "[-] Restarting sshd and fail2ban"

# On Ubuntu/Debian the service is named ssh, on RHEL/CentOS it's sshd
if systemctl list-units --type=service | grep -q 'ssh.service'; then
  systemctl restart ssh
elif systemctl list-units --type=service | grep -q 'sshd.service'; then
  systemctl restart sshd
else
  echo "[!] SSH service not found!"
  exit 1
fi

systemctl restart fail2ban

echo
echo "[+] All done."
echo "[+] From now on, use these SSH settings:"
echo "    User: ubuntu"
echo "    Port: 10808"
echo "    Authentication: password"
echo
echo "[!] Do not close your current session until you test the new port."

echo "[-] Clearing iptables firewall rules"

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

echo "[-] Removing netfilter-persistent"

apt-get purge -y netfilter-persistent 2>/dev/null || true
rm -rf /etc/iptables

echo
echo "[+] Firewall cleanup completed."
echo "[!] Note: This script does not reboot the server; reboot manually if needed."
echo
