FROM debian:12
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server vsftpd nginx php-fpm php-mysql mariadb-server mariadb-client \
    ufw sudo net-tools iproute2 procps lsof cron curl ca-certificates nano \
    && rm -rf /var/lib/apt/lists/*
COPY lab-entrypoint.sh /usr/local/sbin/lab-entrypoint.sh
COPY seed/ /opt/lab-seed/
COPY progress.sh /opt/lab-seed/progress.sh
RUN chmod 755 /usr/local/sbin/lab-entrypoint.sh
EXPOSE 21 22 80 3306
ENTRYPOINT ["/usr/local/sbin/lab-entrypoint.sh"]
