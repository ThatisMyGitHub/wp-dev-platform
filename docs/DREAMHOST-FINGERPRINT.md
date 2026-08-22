# DreamHost environment fingerprint guide

This guide captures the production-relevant configuration of the existing Data Inspire DreamHost environment before we build the first `dreamhost-shared` platform profile.

The process deliberately avoids printing or storing passwords.

## Canonical administration interface

For this project, **MobaXterm Professional** is the canonical operator interface for DreamHost SSH/SFTP administration.

- SSH is used for shell commands and diagnostics.
- MobaXterm's integrated SFTP browser may be used to inspect/download generated fingerprint files.
- Commands remain standard POSIX shell commands and do not depend on MobaXterm-specific behavior.

## Why two captures are required

DreamHost separates the web server from the shared MySQL server, and the PHP version used by the shell can differ from the PHP version assigned to the website.

We therefore collect:

1. **Shell/runtime fingerprint** — operating-system information visible to the account, CLI PHP, installed PHP modules/config paths, WP-CLI, Git and MySQL client.
2. **Database fingerprint** — MySQL server version and production-relevant server/database settings.

A third confirmation is required for the **website PHP version**, because `php -v` reports the CLI default and is not sufficient by itself to prove what the hosted site executes.

## Security rules

Do not paste or commit:

- the DreamHost account password;
- SSH private keys;
- the database password;
- `wp-config.php` contents;
- output from `wp config get DB_PASSWORD`;
- raw database dumps;
- Cloudflare/SMTP/API credentials.

The two project repositories are currently public. Keep the raw fingerprint files outside Git. After review, only sanitized values will be copied into the provider profile.

---

## Part A — connect to the DreamHost shell

### A1. Find the SSH/Shell user and server

In the DreamHost panel, identify the **Shell user** that owns the Data Inspire site and the server/hostname assigned to that user.

The user must be configured as a Shell user rather than FTP-only.

### A2. Connect with MobaXterm

Create an SSH session using the host, username and port shown in DreamHost's **Login Info** panel.

Verify the account after login:

```bash
whoami
pwd
hostname
```

Do not continue if the account or home directory is not the expected site owner.

---

## Part B — Command 1: shell/runtime fingerprint

Once logged in over SSH, run the following block as the normal DreamHost user. It writes the result to a text file in the home directory and also shows it on screen.

```bash
OUT="$HOME/datainspire-dreamhost-shell-fingerprint-$(date +%Y%m%d-%H%M%S).txt"

{
  echo "=== DATA INSPIRE / DREAMHOST SHELL FINGERPRINT ==="
  echo "Captured (UTC): $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo

  echo "--- HOST / OS ---"
  hostname 2>/dev/null || true
  uname -a 2>/dev/null || true
  if [ -r /etc/os-release ]; then
    cat /etc/os-release
  fi
  echo

  echo "--- DEFAULT CLI PHP ---"
  command -v php 2>/dev/null || true
  php -v 2>/dev/null || true
  php --ini 2>/dev/null || true
  echo

  echo "--- DEFAULT CLI PHP MODULES ---"
  php -m 2>/dev/null || true
  echo

  echo "--- SELECTED CLI PHP SETTINGS ---"
  php -r '
    $keys = [
      "memory_limit",
      "max_execution_time",
      "max_input_time",
      "max_input_vars",
      "post_max_size",
      "upload_max_filesize",
      "max_file_uploads",
      "default_socket_timeout"
    ];
    foreach ($keys as $key) {
      printf("%s=%s\n", $key, ini_get($key));
    }
  ' 2>/dev/null || true
  echo

  echo "--- DREAMHOST PHP BINARIES PRESENT ---"
  for v in 82 83 84 85; do
    BIN="/usr/local/php${v}/bin/php"
    if [ -x "$BIN" ]; then
      "$BIN" -v | head -n 1
    fi
  done
  echo

  echo "--- WP-CLI ---"
  command -v wp 2>/dev/null || true
  wp --info 2>/dev/null || true
  echo

  echo "--- GIT ---"
  git --version 2>/dev/null || true
  echo

  echo "--- MYSQL CLIENT ---"
  mysql --version 2>/dev/null || true
  echo

  echo "--- APACHE BINARY, IF EXPOSED TO SHARED USER ---"
  apache2 -v 2>/dev/null || httpd -v 2>/dev/null || echo "Apache binary/version not exposed to this shell user"
} | tee "$OUT"

printf '\nFingerprint saved to: %s\n' "$OUT"
```

The command does **not** request or print passwords. It intentionally avoids dumping the process environment because environment variables can contain secrets.

### Important PHP interpretation

`php -v` reports the default **command-line PHP** version. Do not use that result alone as the Data Inspire web-runtime version.

---

## Part C — confirm the PHP version actually assigned to Data Inspire

### Preferred method: DreamHost panel

Open the DreamHost website-management page for the Data Inspire domain and record the PHP version currently selected for that site.

Record only the version, for example:

```text
Website PHP: 8.4
```

### Optional technical confirmation

If we later need to compare specific web-runtime PHP settings, use a temporary deliberately limited diagnostic endpoint rather than leaving a full `phpinfo()` page publicly reachable.

---

## Part D — locate the existing WordPress installation

From the DreamHost user's home directory, locate WordPress configuration files without displaying their contents:

```bash
find "$HOME" -maxdepth 3 -type f -name wp-config.php -print 2>/dev/null
```

Identify the path belonging to `datainspire.com`, then change into that WordPress document root.

Example only:

```bash
cd "$HOME/datainspire.com"
```

Verify WP-CLI sees the installation:

```bash
wp core version
```

Do **not** display `wp-config.php` and do not run `wp config get DB_PASSWORD`.

---

## Part E — Command 2: database fingerprint

### Preferred method: WP-CLI

Because DreamHost provides WP-CLI and the existing WordPress installation already contains the database connection configuration, the preferred method is to query MySQL through WP-CLI. This avoids displaying, copying or manually entering the database password.

Run this from the Data Inspire WordPress document root:

```bash
DB_OUT="$HOME/datainspire-dreamhost-db-fingerprint-$(date +%Y%m%d-%H%M%S).txt"

wp db query "
SELECT 'mysql_version' AS item, VERSION() AS value;
SELECT 'version_comment' AS item, @@version_comment AS value;
SELECT 'character_set_server' AS item, @@character_set_server AS value;
SELECT 'collation_server' AS item, @@collation_server AS value;
SELECT 'sql_mode' AS item, @@sql_mode AS value;
SELECT 'time_zone' AS item, @@time_zone AS value;
SELECT 'max_allowed_packet' AS item, @@max_allowed_packet AS value;
SELECT 'lower_case_table_names' AS item, @@lower_case_table_names AS value;
SELECT 'current_database' AS item, DATABASE() AS value;
SELECT 'current_user' AS item, CURRENT_USER() AS value;
SHOW GRANTS FOR CURRENT_USER();
" | tee "$DB_OUT"

printf '\nDatabase fingerprint saved to: %s\n' "$DB_OUT"
```

The raw output may contain the database name and account identity. Keep the file outside Git; those identifiers will be removed from the normalized public profile.

### Fallback method: direct MySQL prompt

If `wp db query` is unavailable or fails, obtain `DB_HOST`, `DB_NAME` and `DB_USER` from the DreamHost panel or individually through WP-CLI:

```bash
wp config get DB_HOST
wp config get DB_NAME
wp config get DB_USER
```

Then run the equivalent query with the `mysql` client using `-p` **without putting the password on the command line**.

---

## Part F — WordPress inventory

From the Data Inspire WordPress document root, run:

```bash
wp core version
wp plugin list --fields=name,status,version,update --format=table
wp theme list --fields=name,status,version,update --format=table
```

This inventory is useful for migration planning. Review plugin/theme names before sharing if any are considered private.

---

## Part G — what to send back for analysis

Provide the following through a private conversation/upload rather than committing it to either public repository:

1. `datainspire-dreamhost-shell-fingerprint-*.txt`
2. `datainspire-dreamhost-db-fingerprint-*.txt`
3. the PHP version shown for the Data Inspire website in the DreamHost panel;
4. optionally, the WordPress/plugin/theme inventory.

Before sending, you may redact shell username, server hostname, database hostname, database username and database name.

Do not redact version numbers, PHP settings, SQL mode, character set/collation or grant privilege names.

## Part H — expected output of this phase

After reviewing the capture, the platform project maintains sanitized provider information under:

```text
profiles/
└── dreamhost-shared/
    ├── README.md
    ├── compatibility.md
    ├── php/
    ├── mysql/
    └── reference/
```

Raw fingerprint files remain outside Git.
