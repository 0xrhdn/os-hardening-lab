#!/usr/bin/env bash
set -euo pipefail
mkdir -p /run/sshd /run/mysqld /var/log/nginx /var/www/html /etc/systemd/system /opt/backdoor
chown mysql:mysql /run/mysqld
for spec in 'root:LabRoot!2026' 'ubuntu:UbuntuLab!2026' 'guest:GuestLab!2026' 'anonymous:AnonLab!2026'; do
  user="${spec%%:*}"; pass="${spec#*:}"
  if ! id "$user" >/dev/null 2>&1; then useradd -m -s /bin/bash "$user"; fi
  echo "$user:$pass" | chpasswd
done
usermod -aG sudo ubuntu || true
mkdir -p /home/guest/.ssh
chown -R guest:guest /home/guest/.ssh
chmod 700 /home/guest/.ssh
cat > /etc/ssh/sshd_config <<'EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication yes
UsePAM yes
AllowUsers ubuntu guest root
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
cat > /etc/vsftpd.conf <<'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
xferlog_enable=YES
EOF
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;
    index index.php index.html;
    access_log /var/log/nginx/access.log;
    location / { try_files $uri $uri/ /index.php?$query_string; }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }
}
EOF
cp /opt/lab-seed/index.php /var/www/html/index.php
cp /opt/lab-seed/secret.conf /etc/secret-lab.conf
chmod 644 /etc/secret-lab.conf
cat > /etc/sudoers.d/anonymous-lab <<'EOF'
anonymous ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/anonymous-lab
cat > /etc/systemd/system/lab-backdoor.service <<'EOF'
[Unit]
Description=Training backdoor service
[Service]
Type=simple
ExecStart=/bin/sh -c 'while true; do sleep 3600; done'
[Install]
WantedBy=multi-user.target
EOF
chmod 777 /opt/backdoor
printf '#!/bin/sh\necho training-backdoor\n' > /opt/backdoor/maintenance.sh
chmod 4755 /opt/backdoor/maintenance.sh
# Initialize MariaDB on first run.
if [ ! -d /var/lib/mysql/mysql ]; then mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null; fi
mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0 >/tmp/mariadb.log 2>&1 &
for i in $(seq 1 30); do mariadb-admin ping >/dev/null 2>&1 && break || sleep 1; done
if [ ! -f /var/lib/mysql/.lab-initialized ]; then
  mariadb -uroot <<'SQL'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MariaRoot!2026';
CREATE DATABASE IF NOT EXISTS labdb;
CREATE USER IF NOT EXISTS 'labapp'@'localhost' IDENTIFIED BY 'LabApp!2026';
GRANT ALL ON labdb.* TO 'labapp'@'localhost';
FLUSH PRIVILEGES;
SQL
  touch /var/lib/mysql/.lab-initialized
fi
sed -i 's/^;\?display_errors\s*=.*/display_errors = On/' /etc/php/8.2/fpm/php.ini
php-fpm8.2 -D
nginx
/usr/sbin/sshd
vsftpd /etc/vsftpd.conf &
cron
# Keep container alive and expose service logs.
tail -F /var/log/nginx/access.log /var/log/auth.log /tmp/mariadb.log 2>/dev/null
