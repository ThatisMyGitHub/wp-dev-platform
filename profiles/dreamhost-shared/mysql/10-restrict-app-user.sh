#!/usr/bin/env bash
set -euo pipefail

# The stock MySQL image creates MYSQL_USER with broad database-level privileges.
# Restrict it to the privilege set measured on the Data Inspire DreamHost account.

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"

case "$MYSQL_DATABASE" in
  *[!A-Za-z0-9_]*|'') echo "MYSQL_DATABASE must contain only A-Z, a-z, 0-9 and underscore" >&2; exit 1 ;;
esac

case "$MYSQL_USER" in
  *[!A-Za-z0-9_]*|'') echo "MYSQL_USER must contain only A-Z, a-z, 0-9 and underscore" >&2; exit 1 ;;
esac

mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${MYSQL_USER}'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER,
      CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, SHOW VIEW,
      CREATE ROUTINE, ALTER ROUTINE, TRIGGER
ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
