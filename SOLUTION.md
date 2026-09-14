# Kunci Verifikasi — buka setelah mencoba

Jalankan semua perintah dari dalam target dengan `docker compose exec target bash`. Perintah di bawah adalah arah verifikasi; sesuaikan dengan hasil baseline dan jangan menyalin membabi buta ke mesin produksi.

## SSH

Di `/etc/ssh/sshd_config`, hasil akhir minimal harus memuat `PermitRootLogin no`, `AllowUsers ubuntu guest`, dan `PasswordAuthentication yes`. Tambahkan blok `Match User guest` dengan `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, serta `AuthenticationMethods publickey` setelah memahami aturan `Match`. Uji sintaks menggunakan `sshd -t`, lalu reload SSH dan uji dari sesi kedua. Untuk latihan key-only, buat key dari mesin latihan dan masukkan public key ke `/home/guest/.ssh/authorized_keys`.

## vsftpd

Ubah `anonymous_enable=YES` menjadi `anonymous_enable=NO`. Validasi dengan membaca konfigurasi, restart layanan, lalu coba login `anonymous` ke port host 2121. Login harus gagal dan port tetap listening.

## Nginx/PHP

Tambahkan `server_tokens off;` dalam blok `http` Nginx. Pastikan access log menunjuk ke `/var/log/nginx/access.log`. Jalankan `nginx -t`, reload, lalu periksa `curl -I http://127.0.0.1` dan access log. Pada PHP, ganti interpolasi input menjadi prepared statement, escape output dengan `htmlspecialchars`, gunakan allow-list untuk file yang dapat di-include, dan hapus penggunaan `system` untuk input pengguna. Set `display_errors=Off` serta `log_errors=On` pada PHP-FPM.

## Sudo/SUID/backdoor

Hapus `/etc/sudoers.d/anonymous-lab` atau aturan `anonymous ... NOPASSWD`. Validasi dengan `visudo -c`. Inventarisasi SUID memakai `find / -xdev -type f -perm -4000 -ls`. File latihan ada di `/opt/backdoor/maintenance.sh`; setelah menyimpan catatan baseline, hapus bit SUID dengan `chmod u-s` dan rapikan permission/direktorinya. Periksa unit `lab-backdoor.service`, cron, proses, serta `/opt/backdoor`; hapus/disable artefak latihan setelah identifikasi.

## File kritis

Konfigurasi SSH, sudoers, vsftpd, MariaDB, dan file rahasia harus dimiliki root. Gunakan permission minimum yang masih memungkinkan service bekerja, lalu verifikasi dengan `stat` dan uji service. Untuk `/etc/secret-lab.conf`, target latihan adalah `root:root` dan mode `600`.

## MariaDB

Masuk ke MariaDB dengan password awal `MariaRoot!2026`, ubah password root menjadi `4nT1pwn3dserv3r`, lalu ubah `bind-address` di konfigurasi server menjadi `127.0.0.1`. Restart MariaDB dan verifikasi `ss -ltnp | grep 3306`; listener harus berada di loopback, bukan `0.0.0.0`.

## User dan firewall

Ubah password akun `root`, `anonymous`, dan `guest` hanya di dalam container latihan. Untuk UFW, gunakan default deny incoming dan izinkan 22, 80, 443, dan 21. Container memakai network namespace sendiri; jika UFW tidak berjalan normal karena init system container, catat keterbatasan tersebut dan lakukan bagian firewall pada VM Debian 12 terpisah. Jangan mematikan firewall host.

## Kriteria selesai

Semua service tetap aktif, root tidak dapat login SSH langsung, anonymous FTP gagal, Nginx tidak menampilkan versi, access log bertambah, PHP tidak mengeksekusi input pengguna, anonymous tidak memiliki sudo NOPASSWD, MariaDB hanya listen lokal, dan file latihan tidak lagi memiliki permission berbahaya.
