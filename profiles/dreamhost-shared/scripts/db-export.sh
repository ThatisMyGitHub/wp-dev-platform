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

# --no-tablespaces avoids requiring PROCESS, matching shared-host privilege limits.
# --set-gtid-purged=OFF avoids embedding server-specific GTID state in portable dumps.
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/compose.yaml" exec -T db \
  sh -ec 'exec mysqldump --single-transaction --quick --no-tablespaces --set-gtid-purged=OFF --skip-routines --skip-events --triggers --default-character-set=utf8mb4 -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
  > "$OUT"

echo "Database export written to: $OUT"
