# OS & Web Hardening Lab — Debian 12

Lab latihan ini mensimulasikan target Debian 12 yang sengaja dibuat rentan. Jalankan hanya di VM atau Docker lokal, jangan pada server produksi.

## Prasyarat

- Docker Engine + Docker Compose plugin.
- Minimal 2 GB RAM kosong.
- Akses terminal.

Docker tidak tersedia di sandbox pembuatan ini, jadi jalankan paket ini di komputer/VM yang memiliki Docker.

## Menjalankan lab

```bash
docker compose build
docker compose up -d
docker compose ps
```

Target hanya dipublikasikan ke loopback host:

- SSH: `127.0.0.1:2222` → container port 22
- HTTP: `127.0.0.1:8080` → container port 80
- FTP: `127.0.0.1:2121` → container port 21
- MariaDB: `127.0.0.1:13306` → container port 3306

Masuk ke console target:

```bash
docker compose exec target bash
```

Akun latihan:

| Akun | Password | Keterangan |
|---|---|---|
| root | `LabRoot!2026` | Console container; login SSH root sengaja rentan |
| ubuntu | `UbuntuLab!2026` | Akun admin latihan |
| guest | `GuestLab!2026` | Seharusnya diperbaiki agar key-only |
| anonymous | `AnonLab!2026` | Akun pemicu aturan sudo berbahaya |
| MariaDB root | `MariaRoot!2026` | Password database awal |

## Aturan keselamatan

Lab ini memakai network Docker terpisah dan port host non-default. Jangan mengubah port lab menjadi port sistem utama. Jangan menjalankan perintah pembersihan pada host; semua perubahan dilakukan setelah masuk ke container.

## Tugas peserta

Gunakan `TASKS.md`. Kerjakan tanpa melihat `SOLUTION.md` terlebih dahulu. Setelah setiap tahap, lakukan verifikasi service.

## Reset

Untuk mengembalikan target ke kondisi awal:

```bash
docker compose down -v
./reset.sh
```

`reset.sh` akan membangun ulang image dan volume lab. Jangan menjalankannya jika ingin mempertahankan progres.

## Penghentian

```bash
docker compose down
```

Untuk menghapus data database dan state volume:

```bash
docker compose down -v
```

## Launcher satu perintah

Agar tidak perlu mengetik perintah Docker satu per satu, gunakan launcher:

```bash
chmod +x lab.sh
./lab.sh start
```

Perintah yang tersedia:

```bash
./lab.sh start       # build dan jalankan lab
./lab.sh shell       # masuk ke target
./lab.sh progress    # tampilkan jumlah dan persentase check yang lulus
./lab.sh status      # lihat status container
./lab.sh logs        # lihat log target
./lab.sh stop        # hentikan lab tanpa menghapus data
./lab.sh reset       # hapus data dan mulai dari awal
```

Setelah menjalankan `./lab.sh shell`, kerjakan tugas. Buka terminal kedua atau keluar dari target dengan `exit`, lalu jalankan:

```bash
./lab.sh progress
```

Progress tracker membaca konfigurasi aktual target, sehingga persentase berubah setelah hardening berhasil. Perintah `reset` meminta konfirmasi dengan mengetik `RESET` dan menghapus progres lab.
