#!/usr/bin/env bash
set -u

# OS & Web Hardening Lab progress tracker.
# Run inside the target container as root: bash /opt/lab-seed/progress.sh

passed=0
total=10

ok() { printf '[OK]   %s\n' "$1"; passed=$((passed + 1)); }
fail() { printf '[----] %s\n' "$1"; }

printf '%s\n' '========================================'
printf '%s\n' ' OS & WEB HARDENING LAB - PROGRESS'
printf '%s\n' '========================================'
printf 'Host: '; hostname 2>/dev/null || printf 'unknown\n'
printf 'Time: '; date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || true
printf '\n'

# 1 SSH
if grep -Eq '^\s*PermitRootLogin\s+no\s*$' /etc/ssh/sshd_config 2>/dev/null \
  && grep -Eq '^\s*AllowUsers\s+.*ubuntu.*guest|^\s*AllowUsers\s+.*guest.*ubuntu' /etc/ssh/sshd_config 2>/dev/null \
  && grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config 2>/dev/null; then
  ok 'SSH hardening'
else
  fail 'SSH hardening'
fi

# 2 FTP
if grep -Eq '^\s*anonymous_enable\s*=\s*NO\s*$' /etc/vsftpd.conf 2>/dev/null; then
  ok 'FTP anonymous login disabled'
else
  fail 'FTP anonymous login disabled'
fi

# 3 Nginx version hiding
if nginx -T 2>/dev/null | grep -Eq '^\s*server_tokens\s+off\s*;'; then
  ok 'Nginx version hidden'
else
  fail 'Nginx version hidden'
fi

# 4 Nginx access log
if nginx -T 2>/dev/null | grep -Eq 'access_log\s+/var/log/nginx/access\.log'; then
  ok 'Nginx access log configured'
else
  fail 'Nginx access log configured'
fi

# 5 PHP settings and dangerous constructs
phpini=/etc/php/8.2/fpm/php.ini
if grep -Eq '^\s*display_errors\s*=\s*Off' "$phpini" 2>/dev/null \
  && grep -Eq '^\s*log_errors\s*=\s*On' "$phpini" 2>/dev/null \
  && ! grep -RqsE 'system\s*\(|shell_exec\s*\(|eval\s*\(' /var/www/html --include='*.php' 2>/dev/null; then
  ok 'PHP basic hardening'
else
  fail 'PHP basic hardening'
fi

# 6 Firewall. UFW may not work in an unprivileged init-less container; report clearly.
if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -qi 'Status: active' \
  && ufw status 2>/dev/null | grep -Eq '22/tcp|80/tcp' \
  && ufw status 2>/dev/null | grep -Eq '21/tcp'; then
  ok 'UFW active and service ports allowed'
else
  fail 'UFW active and service ports allowed'
fi

# 7 sudoers
if ! grep -RqsE '^\s*anonymous\s+.*NOPASSWD\s*:' /etc/sudoers /etc/sudoers.d 2>/dev/null; then
  ok 'Dangerous anonymous sudo rule removed'
else
  fail 'Dangerous anonymous sudo rule removed'
fi

# 8 backdoor artifacts
if [ ! -e /etc/systemd/system/lab-backdoor.service ] \
  && [ ! -e /opt/backdoor/maintenance.sh ]; then
  ok 'Training backdoor artifacts removed'
else
  fail 'Training backdoor artifacts removed'
fi

# 9 critical file permissions
secret_ok=0
[ ! -e /etc/secret-lab.conf ] && secret_ok=1
[ -e /etc/secret-lab.conf ] && [ "$(stat -c '%U:%a' /etc/secret-lab.conf 2>/dev/null)" = 'root:600' ] && secret_ok=1
if [ "$secret_ok" -eq 1 ] \
  && [ "$(stat -c '%a' /etc/ssh/sshd_config 2>/dev/null)" != '777' ]; then
  ok 'Critical file permissions hardened'
else
  fail 'Critical file permissions hardened'
fi

# 10 MariaDB local binding
if grep -RqsE '^\s*bind-address\s*=\s*127\.0\.0\.1\s*$' /etc/mysql 2>/dev/null \
  && ! ss -ltn 2>/dev/null | grep -qE '0\.0\.0\.0:3306|:::3306'; then
  ok 'MariaDB local-only binding'
else
  fail 'MariaDB local-only binding'
fi

percent=$((passed * 100 / total))
printf '\n========================================\n'
printf 'Progress: %d/%d checks passed (%d%%)\n' "$passed" "$total" "$percent"
printf '========================================\n'
printf 'Catatan: skor adalah indikator latihan, bukan audit keamanan menyeluruh.\n'
