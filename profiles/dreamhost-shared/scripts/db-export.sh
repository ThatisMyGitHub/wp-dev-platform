#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"
BACKUP_DIR="${BACKUP_DIR:-${ROOT_DIR}/backups}"
STAMP="$(date -u +%Y%m%d-%H%M%S)"
OUT="${1:-${BACKUP_DIR}/database-${STAMP}.sql}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/compose.yaml" exec -T db \
  sh -ec 'exec mysqldump --single-transaction --quick --skip-routines --skip-events --triggers -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
  > "$OUT"

echo "Database export written to: $OUT"
