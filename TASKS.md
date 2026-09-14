# Tugas Praktik

> Tujuan lab: memperbaiki konfigurasi target dan membuktikan setiap perubahan. Jangan mengedit image atau compose untuk menyelesaikan tugas.

## 0. Baseline

Di dalam target, catat:

- service yang aktif;
- port listening;
- akun dan grup;
- aturan sudo;
- file SUID;
- proses, systemd unit, cron, dan file di `/opt/backdoor`;
- konfigurasi Nginx, vsftpd, SSH, MariaDB, dan PHP.

## 1. SSH

- Tolak login SSH langsung sebagai root.
- Batasi SSH ke akun yang memang diperlukan: `ubuntu` dan `guest`; pahami bahwa root tetap ditolak oleh aturan root-login.
- Untuk `guest`, izinkan public-key authentication tetapi tolak password authentication.
- Validasi konfigurasi sebelum reload dan uji dari sesi kedua.

## 2. FTP

- Matikan anonymous login pada vsftpd.
- Pastikan port 21 tetap hidup dan login lokal tidak rusak.

## 3. Nginx/PHP

- Sembunyikan nomor versi Nginx pada response header.
- Pastikan access log diarahkan ke `/var/log/nginx/access.log`.
- Audit `/var/www/html/index.php` dan perbaiki SQL injection, XSS, file inclusion, dan command execution.
- Pastikan error tidak ditampilkan ke browser.

## 4. Firewall

- Terapkan default deny incoming dan default allow outgoing.
- Izinkan hanya 22/tcp, 80/tcp, 443/tcp, dan 21/tcp pada firewall internal lab.
- Jangan membuka 3306 ke jaringan.

## 5. Sudo/SUID

- Hapus aturan sudo `NOPASSWD` untuk `anonymous`.
- Inventarisasi SUID dan bedakan binary paket resmi dari file tambahan.
- Hapus bit SUID pada binary latihan yang tidak dibutuhkan, bukan binary sistem sembarangan.

## 6. Backdoor/file kritis

- Temukan dan nonaktifkan unit systemd, cron, proses, atau file yang dibuat sebagai backdoor latihan.
- Amankan permission konfigurasi kritis sehingga tidak dapat dibaca/diubah user biasa.

## 7. MariaDB

- Ubah password root database menjadi `4nT1pwn3dserv3r` untuk meniru modul.
- Bind MariaDB hanya ke `127.0.0.1`.
- Uji login lokal dan pastikan listener bukan `0.0.0.0`.

## 8. Management user

- Ubah password `root`, `anonymous`, dan `guest` menjadi `4nT1pwn3dserv3r` di dalam lab.
- Ingat: password contoh ini tidak cocok untuk sistem nyata.

## 9. Laporan

Buat tabel sebelum/sesudah, perintah verifikasi, hasil pengujian, dan kendala. Setelah selesai, jalankan `docker compose down -v` bila ingin menghapus state latihan.
