#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$ROOT_DIR/data"
LOCAL_DATA_DIR="$ROOT_DIR/local_data"
GENERATOR_IMAGE="docker-bi-generator"
REPORTER_IMAGE="docker-bi-reporter"

mkdir -p "$DATA_DIR" "$LOCAL_DATA_DIR"

usage() {
  cat <<'HELP'
Использование: ./run.sh <команда>

Команды:
  build_generator    собрать образ генератора
  run_generator      создать data/data.csv через контейнер
  create_local_data  создать local_data/data.csv локально
  build_reporter     собрать образ аналитика
  run_reporter       создать data/report.html через контейнер
  structure          вывести структуру проекта
  clear_data         удалить .csv и .html из data/
  inside_generator   показать /data из контейнера генератора
  inside_reporter    показать /data из контейнера аналитика
HELP
}

case "${1:-}" in
  build_generator)
    docker build -t "$GENERATOR_IMAGE" "$ROOT_DIR/generator"
    ;;
  run_generator)
    docker run --rm \
      -v "$DATA_DIR:/data" \
      "$GENERATOR_IMAGE"
    ;;
  create_local_data)
    python3 "$ROOT_DIR/generator/generate.py" "$LOCAL_DATA_DIR"
    echo "Создан файл: $LOCAL_DATA_DIR/data.csv"
    ;;
  build_reporter)
    docker build -t "$REPORTER_IMAGE" "$ROOT_DIR/reporter"
    ;;
  run_reporter)
    if [[ ! -f "$DATA_DIR/data.csv" ]]; then
      echo "Ошибка: сначала создайте data/data.csv командой ./run.sh run_generator" >&2
      exit 1
    fi
    docker run --rm \
      -v "$DATA_DIR:/data" \
      "$REPORTER_IMAGE"
    ;;
  structure)
    if command -v tree >/dev/null 2>&1; then
      (
        cd "$ROOT_DIR"
        tree -a -I '.git|node_modules' .
      )
    else
      (
        cd "$ROOT_DIR"
        find . -not -path './.git/*' -not -path './node_modules/*' | sort
      )
    fi
    ;;
  clear_data)
    find "$DATA_DIR" -maxdepth 1 -type f \( -name '*.csv' -o -name '*.html' \) -delete
    echo "Папка data очищена"
    ;;
  inside_generator)
    docker run --rm \
      -v "$DATA_DIR:/data" \
      --entrypoint sh \
      "$GENERATOR_IMAGE" \
      -c 'echo "Содержимое /data:"; ls -la /data'
    ;;
  inside_reporter)
    docker run --rm \
      -v "$DATA_DIR:/data" \
      --entrypoint sh \
      "$REPORTER_IMAGE" \
      -c 'echo "Содержимое /data:"; ls -la /data'
    ;;
  -h|--help|help|'')
    usage
    ;;
  *)
    echo "Неизвестная команда: $1" >&2
    usage >&2
    exit 1
    ;;
esac
