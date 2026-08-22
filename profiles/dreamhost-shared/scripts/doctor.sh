#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"
COMPOSE=(docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/compose.yaml")
FAIL=0
SMOKE_FILE=""

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*" >&2; FAIL=1; }

cleanup() {
  if [[ -n "$SMOKE_FILE" ]]; then
    "${COMPOSE[@]}" exec -T wordpress rm -f "/var/www/html/$SMOKE_FILE" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT HUP INT TERM

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

PHP_LIMITS="$("${COMPOSE[@]}" exec -T wordpress php -r 'echo ini_get("memory_limit"),"|",ini_get("max_execution_time"),"|",ini_get("max_input_time"),"|",ini_get("max_input_vars"),"|",ini_get("post_max_size"),"|",ini_get("upload_max_filesize"),"|",ini_get("max_file_uploads"),"|",ini_get("default_socket_timeout"),"|",ini_get("opcache.enable");' 2>/dev/null || true)"
[[ "$PHP_LIMITS" == '128M|120|-1|3000|512M|512M|20|60|1' ]] && pass "Measured DreamHost PHP limits/OPcache are applied" || fail "PHP settings mismatch: $PHP_LIMITS"

PHP_MODULES="$("${COMPOSE[@]}" exec -T wordpress php -m 2>/dev/null || true)"
REQUIRED_MODULES=(
  bcmath bz2 calendar curl dom exif fileinfo ftp gd gettext imagick intl mbstring
  mysqli mysqlnd pcntl PDO pdo_mysql pdo_sqlite SimpleXML soap sockets sodium sqlite3
  xml xmlreader xmlwriter xsl zip "Zend OPcache"
)
MISSING_MODULES=()
for module in "${REQUIRED_MODULES[@]}"; do
  if ! grep -Fxq "$module" <<<"$PHP_MODULES"; then
    MISSING_MODULES+=("$module")
  fi
done
if (( ${#MISSING_MODULES[@]} == 0 )); then
  pass "DreamHost-compatible PHP extension baseline is present"
else
  fail "Missing PHP modules: ${MISSING_MODULES[*]}"
fi

DB_VERSION="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SELECT VERSION()" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
[[ "$DB_VERSION" == 8.0.41* ]] && pass "MySQL runtime is $DB_VERSION" || fail "MySQL runtime is '$DB_VERSION' (expected 8.0.41.x)"

DB_SETTINGS="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SELECT CONCAT(@@sql_mode,"'"'|"'"',@@max_allowed_packet,"'"'|"'"',@@lower_case_table_names,"'"'|"'"',@@character_set_server,"'"'|"'"',@@collation_server,"'"'|"'"',@@default_storage_engine)" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
[[ "$DB_SETTINGS" == 'NO_ENGINE_SUBSTITUTION|33554432|0|utf8mb4|utf8mb4_unicode_520_ci|InnoDB' ]] && pass "DreamHost SQL settings and clean reusable schema defaults are applied" || fail "Database settings mismatch: $DB_SETTINGS"

GRANTS="$("${COMPOSE[@]}" exec -T db sh -ec 'mysql -Nse "SHOW GRANTS FOR CURRENT_USER()" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' 2>/dev/null || true)"
if grep -q 'TRIGGER' <<<"$GRANTS" && grep -q 'CREATE ROUTINE' <<<"$GRANTS" && ! grep -Eq '(^|[, ])EVENT([, ]|$)' <<<"$GRANTS" && ! grep -q 'GRANT OPTION' <<<"$GRANTS"; then
  pass "Application grants match the measured DreamHost privilege envelope"
else
  fail "Application grants do not match the intended DreamHost privilege model"
fi

if "${COMPOSE[@]}" --profile tools run --rm -T wpcli core is-installed >/dev/null 2>&1; then
  pass "WordPress is installed"
else
  fail "WordPress is not installed; complete installation before running the full doctor"
fi

WP_RUNTIME="$("${COMPOSE[@]}" --profile tools run --rm -T wpcli eval 'global $wpdb; echo $wpdb->charset,"|",$wpdb->collate;' 2>/dev/null || true)"
[[ "$WP_RUNTIME" == 'utf8mb4|utf8mb4_unicode_520_ci' ]] && pass "WordPress DB connection is utf8mb4 / unicode_520" || fail "WordPress DB connection mismatch: $WP_RUNTIME"

# Exercise the actual development request boundary: wordpress -> Apache -> FastCGI -> PHP-FPM.
SMOKE_FILE="wpdev-runtime-$RANDOM-$$.php"
if "${COMPOSE[@]}" exec -T wordpress php -r 'file_put_contents("/var/www/html/'"$SMOKE_FILE"'", "<?php header(\"Content-Type: text/plain\"); echo PHP_VERSION, \"|\", PHP_SAPI;");' >/dev/null 2>&1; then
  WEB_RUNTIME="$("${COMPOSE[@]}" exec -T wordpress php -r '$ctx=stream_context_create(["http"=>["timeout"=>5]]); $v=@file_get_contents("http://web/'"$SMOKE_FILE"'", false, $ctx); if ($v === false) { exit(1); } echo trim($v);' 2>/dev/null || true)"
  if [[ "$WEB_RUNTIME" == 8.3.*'|fpm-fcgi' ]]; then
    pass "Apache -> FastCGI -> PHP request path works ($WEB_RUNTIME)"
  else
    fail "Apache/FastCGI request path failed or returned unexpected runtime: $WEB_RUNTIME"
  fi
else
  fail "Could not create temporary FastCGI smoke-test file"
fi

cleanup
SMOKE_FILE=""
trap - EXIT HUP INT TERM

if (( FAIL )); then
  echo "Doctor detected compatibility failures." >&2
  exit 1
fi

echo "DreamHost Shared compatibility doctor passed."
