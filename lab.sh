#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

need_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker belum terpasang. Install Docker terlebih dahulu."
    exit 1
  fi
  docker compose version >/dev/null 2>&1 || {
    echo "Docker Compose plugin belum tersedia."
    exit 1
  }
}

start() {
  need_docker
  echo "[1/3] Build image lab..."
  docker compose build
  echo "[2/3] Menjalankan target..."
  docker compose up -d
  echo "[3/3] Status target:"
  docker compose ps
  echo
  echo "Lab aktif. Gunakan: $0 shell atau $0 progress"
}

reset_lab() {
  need_docker
  echo "PERINGATAN: seluruh progres dan database lab akan dihapus."
  read -r -p "Ketik RESET untuk melanjutkan: " answer
  [ "$answer" = "RESET" ] || { echo "Reset dibatalkan."; exit 0; }
  docker compose down -v --remove-orphans
  docker compose build --no-cache
  docker compose up -d
  docker compose ps
}

case "${1:-help}" in
  start|up)
    start
    ;;
  shell| masuk)
    need_docker
    docker compose exec target bash
    ;;
  progress|cek|check)
    need_docker
    docker compose exec target bash /opt/lab-seed/progress.sh
    ;;
  status)
    need_docker
    docker compose ps
    ;;
  logs|log)
    need_docker
    docker compose logs --tail=100 target
    ;;
  stop|down)
    need_docker
    docker compose down
    ;;
  reset)
    reset_lab
    ;;
  help|*)
    cat <<EOF
OS & Web Hardening Lab

Pemakaian:
  ./lab.sh start       Build dan jalankan lab
  ./lab.sh shell       Masuk ke target Debian latihan
  ./lab.sh progress    Lihat persentase tugas yang selesai
  ./lab.sh status      Lihat status container
  ./lab.sh logs        Lihat log target
  ./lab.sh stop        Hentikan lab tanpa menghapus data
  ./lab.sh reset       Hapus dan bangun ulang lab dari awal
EOF
    ;;
esac
