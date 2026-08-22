#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"
COMPOSE=(docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/compose.yaml")
FAIL=0

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*" >&2; FAIL=1; }

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

if "${COMPOSE[@]}" config -q; then
  pass "Compose configuration parses"
else
  fail "Compose configuration is invalid"
fi

PHP_VERSION="$("${COMPOSE[@]}" exec -T wordpress php -r 'echo PHP_VERSION;' 2>/dev/null || true)"
[[ "$PHP_VERSION" == 8.3.* ]] && pass "PHP runtime is $PHP_VERSION (expected 8.3.x)" || fail "PHP runtime is '$PHP_VERSION' (expected 8.3.x)"

PHP_LIMITS="$("${COMPOSE[@]}" exec -T wordpress php -r 'echo ini_get("memory_limit"),"|",ini_get("max_execution_time"),"|",ini_get("max_input_vars"),"|",ini_get("post_max_size"),"|",ini_get("upload_max_filesize");' 2>/dev/null || true)"
[[ "$PHP_LIMITS" == '128M|120|3000|512M|512M' ]] && pass "Measured DreamHost PHP limits are applied" || fail "PHP limits mismatch: $PHP_LIMITS"

DB_VERSION="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SELECT VERSION()" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
[[ "$DB_VERSION" == 8.0.41* ]] && pass "MySQL runtime is $DB_VERSION" || fail "MySQL runtime is '$DB_VERSION' (expected 8.0.41.x)"

DB_SETTINGS="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SELECT CONCAT(@@sql_mode,"'"'|"'"',@@max_allowed_packet,"'"'|"'"',@@lower_case_table_names)" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
[[ "$DB_SETTINGS" == 'NO_ENGINE_SUBSTITUTION|33554432|0' ]] && pass "DreamHost SQL mode/packet/case settings are applied" || fail "Database settings mismatch: $DB_SETTINGS"

GRANTS="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SHOW GRANTS FOR CURRENT_USER()" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
if grep -q 'TRIGGER' <<<"$GRANTS" && ! grep -q ' EVENT' <<<"$GRANTS"; then
  pass "Application grants include measured DreamHost privileges and omit EVENT"
else
  fail "Application grants do not match the intended DreamHost privilege model"
fi

WP_RUNTIME="$("${COMPOSE[@]}" --profile tools run --rm -T wpcli eval 'global $wpdb; echo $wpdb->charset,"|",$wpdb->collate;' 2>/dev/null || true)"
[[ "$WP_RUNTIME" == 'utf8mb4|utf8mb4_unicode_520_ci' ]] && pass "WordPress DB connection is utf8mb4 / unicode_520" || fail "WordPress DB connection mismatch: $WP_RUNTIME"

if (( FAIL )); then
  echo "Doctor detected compatibility failures." >&2
  exit 1
fi

echo "DreamHost Shared compatibility doctor passed."
