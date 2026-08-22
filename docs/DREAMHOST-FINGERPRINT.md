# DreamHost environment fingerprint guide

This guide captures the production-relevant configuration of the existing Data Inspire DreamHost environment before we build the first `dreamhost-shared` platform profile.

The process deliberately avoids printing or storing passwords.

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

### A2. Connect over SSH

From macOS/Linux/WSL/PowerShell with OpenSSH:

```bash
ssh YOUR_SHELL_USER@YOUR_DREAMHOST_SERVER
```

Use the real shell username and server hostname shown by DreamHost.

If your SSH client asks whether to trust the server host key on the first connection, verify the hostname before accepting it.

---

## Part B — Command 1: shell/runtime fingerprint

Once logged in over SSH, run the following block exactly as a normal DreamHost user. It writes the result to a text file in your home directory and also shows it on screen.

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

echo
echo "Fingerprint saved to: $OUT"
```

### What this command does not expose

It does **not** request or print passwords. It also intentionally avoids dumping the process environment, because environment variables can contain secrets.

### Important PHP interpretation

The result of:

```bash
php -v
```

is the default **command-line PHP** version. DreamHost allows multiple PHP versions and the hosted website can be configured to use a different one.

Do not use the CLI result alone as the Data Inspire web-runtime version.

---

## Part C — confirm the PHP version actually assigned to Data Inspire

### Preferred method: DreamHost panel

Open the DreamHost website-management page for the Data Inspire domain and record the PHP version currently selected for that site.

Record only the version, for example:

```text
Website PHP: 8.4
```

### Optional technical confirmation

If we later need to compare specific web-runtime PHP settings, use a temporary, deliberately limited diagnostic file rather than publishing a full `phpinfo()` page for an extended period.

Do not leave a `phpinfo.php` diagnostic endpoint on the public site.

For the first fingerprint, the panel-selected website PHP version plus the shell/module capture is sufficient.

---

## Part D — identify database connection values safely

DreamHost Shared MySQL is on a separate database server, so do not assume `localhost`.

Obtain these three non-password values from the DreamHost panel:

```text
DB_HOST
DB_NAME
DB_USER
```

If WP-CLI is working from the existing WordPress document root, you may also verify them individually:

```bash
wp config get DB_HOST
wp config get DB_NAME
wp config get DB_USER
```

**Do not run or share:**

```bash
wp config get DB_PASSWORD
```

The password will be entered only at the MySQL password prompt in the next step.

---

## Part E — Command 2: database fingerprint

Replace only the three placeholders below:

- `YOUR_DB_HOST`
- `YOUR_DB_USER`
- `YOUR_DB_NAME`

Then run:

```bash
DB_OUT="$HOME/datainspire-dreamhost-db-fingerprint-$(date +%Y%m%d-%H%M%S).txt"

mysql \
  -h YOUR_DB_HOST \
  -u YOUR_DB_USER \
  -p \
  YOUR_DB_NAME \
  --batch --raw \
  -e "
SELECT 'mysql_version' AS item, VERSION() AS value;
SELECT 'character_set_server' AS item, @@character_set_server AS value;
SELECT 'collation_server' AS item, @@collation_server AS value;
SELECT 'sql_mode' AS item, @@sql_mode AS value;
SELECT 'time_zone' AS item, @@time_zone AS value;
SELECT 'max_allowed_packet' AS item, @@max_allowed_packet AS value;
SELECT 'lower_case_table_names' AS item, @@lower_case_table_names AS value;
SELECT 'current_database' AS item, DATABASE() AS value;
SHOW GRANTS FOR CURRENT_USER();
" | tee "$DB_OUT"

echo
echo "Database fingerprint saved to: $DB_OUT"
```

MySQL will display:

```text
Enter password:
```

Type the database password and press Enter. The password is not displayed and is not placed directly in the shell command/history.

### Why we use `-p` without the password

Do **not** write this:

```bash
mysql -pYOUR_PASSWORD ...
```

Putting a password directly on the command line can expose it through shell history or process inspection.

---

## Part F — check WordPress itself

From the Data Inspire WordPress document root, run:

```bash
wp core version
wp plugin list --fields=name,status,version,update --format=table
wp theme list --fields=name,status,version,update --format=table
```

This inventory is useful for migration planning. It does not need to be included in the raw server fingerprint if you prefer to collect it separately.

Before sharing the output, review plugin/theme names for anything you consider private.

---

## Part G — what to send back for analysis

Provide the following through a private conversation/upload rather than committing it to either public repository:

1. `datainspire-dreamhost-shell-fingerprint-*.txt`
2. `datainspire-dreamhost-db-fingerprint-*.txt`
3. The PHP version shown for the Data Inspire website in the DreamHost panel.
4. Optionally, the WordPress/plugin/theme inventory.

Before sending, you may redact:

- shell username;
- server hostname;
- database hostname;
- database username;
- database name.

Do not redact version numbers, PHP settings, SQL mode, character set/collation, or grant privilege names. Those are the values we need for compatibility analysis.

## Part H — expected output of this phase

After reviewing the capture, the platform project will create a sanitized provider profile such as:

```text
profiles/
└── dreamhost-shared/
    ├── README.md
    ├── compatibility.md
    ├── php/
    ├── mysql/
    └── reference/
        └── sanitized-profile.json
```

The raw fingerprint files remain outside Git.

## DreamHost references

- PHP versions: https://help.dreamhost.com/hc/en-us/articles/215082337-What-versions-of-PHP-are-available-at-DreamHost
- Command-line PHP: https://help.dreamhost.com/hc/en-us/articles/214202238-Command-line-PHP-overview
- MySQL overview: https://help.dreamhost.com/hc/en-us/articles/215099117-MySQL-overview
- Connect to MySQL via SSH: https://help.dreamhost.com/hc/en-us/articles/214882998-Connect-to-a-database-via-SSH
- Shared MySQL limitations: https://help.dreamhost.com/hc/en-us/articles/115000263911-MySQL-limitations-due-to-shared-hosting
