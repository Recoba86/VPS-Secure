#!/bin/bash
set -e

# این اسکریپت باید با روت اجرا بشه
if [ "$EUID" -ne 0 ]; then
  echo "لطفا اسکریپت را با sudo یا به عنوان root اجرا کن."
  exit 1
fi

echo "[-] ست کردن پسورد جدید برای یوزر ubuntu"

read -s -p "پسورد جدید برای ubuntu: " UBUNTU_PASS
echo
read -s -p "تکرار پسورد: " UBUNTU_PASS2
echo

if [ "$UBUNTU_PASS" != "$UBUNTU_PASS2" ]; then
  echo "[!] پسوردها یکی نیستن. اسکریپت متوقف شد."
  exit 1
fi

echo "ubuntu:$UBUNTU_PASS" | chpasswd
echo "[+] پسورد ubuntu با موفقیت ست شد."

SSHD_CONF="/etc/ssh/sshd_config"

echo "[-] بکاپ گرفتن از فایل sshd_config"
cp "$SSHD_CONF" "${SSHD_CONF}.$(date +%F-%H%M%S).bak"

echo "[-] تنظیم پورت SSH روی 10808"

if grep -qE '^Port ' "$SSHD_CONF"; then
  sed -i 's/^Port .*/Port 10808/' "$SSHD_CONF"
elif grep -qE '^#Port ' "$SSHD_CONF"; then
  sed -i 's/^#Port .*/Port 10808/' "$SSHD_CONF"
else
  echo 'Port 10808' >> "$SSHD_CONF"
fi

echo "[-] بستن لاگین با root"

if grep -qE '^PermitRootLogin ' "$SSHD_CONF"; then
  sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' "$SSHD_CONF"
else
  echo 'PermitRootLogin no' >> "$SSHD_CONF"
fi

echo "[-] فعال کردن لاگین با پسورد و غیرفعال کردن کی"
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

echo "[-] محدود کردن ssh فقط برای ubuntu"

if grep -qE '^AllowUsers ' "$SSHD_CONF"; then
  sed -i 's/^AllowUsers .*/AllowUsers ubuntu/' "$SSHD_CONF"
else
  echo 'AllowUsers ubuntu' >> "$SSHD_CONF"
fi

echo "[-] نصب fail2ban"

apt update -y
apt install -y fail2ban

echo "[-] تنظیم fail2ban برای ssh روی پورت 10808"

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

echo "[-] چک کردن کانفیگ sshd"

sshd -t

echo "[-] ریستارت sshd و fail2ban"

systemctl restart sshd
systemctl restart fail2ban

echo
echo "[+] همه چیز انجام شد."
echo "[+] از این به بعد برای ssh از این تنظیمات استفاده کن:"
echo "    یوزر: ubuntu"
echo "    پورت: 10808"
echo "    احراز هویت: پسورد"
echo
echo "[!] تا وقتی با پورت جدید تست نکردی، سشن فعلی‌ات رو نبند."

echo "[-] پاک کردن قوانین فایروال iptables"

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

echo "[-] حذف netfilter-persistent"

apt-get purge -y netfilter-persistent 2>/dev/null || true
rm -rf /etc/iptables

echo
echo "[+] سرور در حال ریبوت است..."
echo "[!] بعد از ریبوت، با پورت 10808 و یوزر ubuntu وارد شوید."
echo

sleep 3
reboot
