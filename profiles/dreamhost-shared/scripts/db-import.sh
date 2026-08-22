#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"
SQL_FILE="${1:-}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

if [[ -z "$SQL_FILE" || ! -f "$SQL_FILE" ]]; then
  echo "Usage: CONFIRM_IMPORT=1 $0 /path/to/database.sql" >&2
  exit 1
fi

if [[ "${CONFIRM_IMPORT:-0}" != "1" ]]; then
  echo "Refusing database import without CONFIRM_IMPORT=1" >&2
  exit 1
fi

cat "$SQL_FILE" | docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/compose.yaml" exec -T db \
  sh -ec 'exec mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'

echo "Database import completed from: $SQL_FILE"
