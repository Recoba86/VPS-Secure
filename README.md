# VPS-Secure

اسکریپت امنیت SSH برای سرورهای Ubuntu

## نصب و اجرای سریع

برای نصب و اجرای اسکریپت با یک دستور:

```bash
curl -fsSL https://raw.githubusercontent.com/Recoba86/VPS-Secure/main/secure-ssh.sh | sudo bash
```

یا اگر می‌خواهید فایل را دانلود کنید و بعداً اجرا کنید:

```bash
wget https://raw.githubusercontent.com/Recoba86/VPS-Secure/main/secure-ssh.sh
sudo chmod +x secure-ssh.sh
sudo ./secure-ssh.sh
```

## امکانات

این اسکریپت تنظیمات زیر را برای امن‌سازی SSH سرور شما انجام می‌دهد:

- ✅ تغییر پسورد یوزر `ubuntu`
- ✅ تغییر پورت SSH به `10808` (برای جلوگیری از اسکن‌های خودکار)
- ✅ غیرفعال کردن لاگین با یوزر `root`
- ✅ فعال کردن احراز هویت با پسورد و غیرفعال کردن کلید SSH
- ✅ محدود کردن دسترسی SSH فقط به یوزر `ubuntu`
- ✅ نصب و پیکربندی `fail2ban` برای محافظت در برابر حملات brute-force
- ✅ بکاپ خودکار از فایل کانفیگ SSH
- ✅ تنظیم fail2ban با محدودیت 3 تلاش ناموفق در 10 دقیقه (بن به مدت 1 ساعت)
- ✅ پاک کردن تمام قوانین فایروال (iptables)
- ✅ حذف netfilter-persistent
- ✅ (توجه) اسکریپت ریبوت خودکار انجام نمی‌دهد؛ در صورت نیاز خودتان ریبوت کنید

## هشدارها مهم

⚠️ **قبل از قطع اتصال SSH فعلی، حتماً با پورت جدید (10808) تست کنید!**

⚠️ **اسکریپت به صورت خودکار سرور را ریبوت نمی‌کند. در صورت نیاز بعد از بررسی، خودتان ریبوت کنید.**

⚠️ **بعد از (در صورت انجام ریبوت) ریبوت، باید با پورت 10808 و یوزر ubuntu وارد شوید.**

پس از اجرای اسکریپت:
- پورت جدید: `10808`
- یوزر مجاز: `ubuntu`
- روش احراز هویت: پسورد (که خودتان تعیین کردید)

مثال اتصال:
```bash
ssh -p 10808 ubuntu@YOUR_SERVER_IP
```

## نیازمندی‌ها

- سیستم عامل: Ubuntu
- دسترسی root یا sudo
- اتصال اینترنت فعال (برای نصب fail2ban)

## مشکلات رایج

اگر بعد از اجرای اسکریپت نتوانستید متصل شوید:

1. مطمئن شوید فایروال سرور پورت 10808 را باز کرده‌اید
2. در کنسول سرور (مثلاً از پنل هاست) وارد شوید
3. وضعیت SSH را چک کنید: `sudo systemctl status sshd`
4. لاگ‌ها را بررسی کنید: `sudo journalctl -u sshd -n 50`

---

## Quick Installation (English)

To install and run the script with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Recoba86/VPS-Secure/main/secure-ssh.sh | sudo bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/Recoba86/VPS-Secure/main/secure-ssh.sh
sudo chmod +x secure-ssh.sh
sudo ./secure-ssh.sh
```

## Features

- Changes `ubuntu` user password
- Changes SSH port to `10808`
- Disables root login
- Enables password authentication
- Restricts SSH access to `ubuntu` user only
- Installs and configures `fail2ban` for brute-force protection
- Cleans up firewall rules (iptables)
- Removes netfilter-persistent
- Does not reboot the server automatically — reboot manually if needed

## Important Warnings

⚠️ **Test the new port (10808) before closing your current SSH session!**

⚠️ **The script does not automatically reboot the server. If you want to reboot, do so after you verify access.**

⚠️ **After (if you reboot) reboot, you must connect using port 10808 and user ubuntu.**

Connection example:
```bash
ssh -p 10808 ubuntu@YOUR_SERVER_IP
```
