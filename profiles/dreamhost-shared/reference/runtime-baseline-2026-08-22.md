# DreamHost Shared runtime baseline — 2026-08-22

Sanitized reference captured from the Data Inspire DreamHost Shared Unlimited environment.

This file intentionally excludes usernames, server hostnames, login IP addresses, database names, database hosts, credentials and other account-specific identifiers.

## Host runtime

- Distribution: Ubuntu 24.04.4 LTS (Noble Numbat)
- Kernel family: Linux 6.18.39, DreamHost grsecurity build
- Architecture: x86_64
- Apache: 2.4.58 (Ubuntu)

## PHP — production web/FastCGI runtime

The DreamHost panel reports the active website as assigned to PHP 8.3. A short-lived HTTPS diagnostic executed through the actual hosted site confirmed the effective runtime precisely:

- PHP: **8.3.30**
- SAPI: **`cgi-fcgi`**
- `memory_limit`: `128M`
- `max_execution_time`: `120`
- `max_input_time`: `-1`
- `max_input_vars`: `3000`
- `post_max_size`: `512M`
- `upload_max_filesize`: `512M`
- `max_file_uploads`: `20`
- `default_socket_timeout`: `60`
- `opcache.enable`: `1`

The temporary diagnostic file was removed immediately after the successful request. It contained no credentials, environment dump, filesystem paths, database information or full `phpinfo()` output.

This web/FastCGI result is the authoritative PHP compatibility target for the production website.

## PHP — shell/CLI baseline

- Default CLI PHP: 8.2.30 NTS
- Default CLI binary: `/usr/bin/php`
- CLI php.ini path: `/etc/php82/php.ini`
- Additional user configuration observed: `$HOME/.php/8.2/phprc`
- Zend OPcache: available

### Relevant CLI PHP settings observed

- `memory_limit`: 128M
- `max_execution_time`: 0
- `max_input_time`: -1
- `max_input_vars`: 3000
- `post_max_size`: 512M
- `upload_max_filesize`: 512M
- `max_file_uploads`: 20
- `default_socket_timeout`: 60

The CLI and web runtimes are intentionally treated as separate contexts. The production application compatibility target is PHP 8.3.30 FastCGI; DreamHost's default shell interpreter remains PHP 8.2.30 unless an operator explicitly selects another CLI binary.

### PHP modules observed from CLI

`bcmath`, `bz2`, `calendar`, `ctype`, `curl`, `dom`, `exif`, `fileinfo`, `ftp`, `gd`, `gettext`, `imagick`, `imap`, `intl`, `mbstring`, `mysqli`, `mysqlnd`, `openssl`, `pcntl`, `PDO`, `pdo_mysql`, `pdo_sqlite`, `posix`, `pspell`, `session`, `SimpleXML`, `soap`, `sockets`, `sodium`, `sqlite3`, `xml`, `xmlreader`, `xmlwriter`, `xsl`, `Zend OPcache`, `zip`, `zlib` and standard PHP core modules.

### PHP binaries present on host

The host exposes CLI binaries from PHP 5.6 through PHP 8.5. Current observed versions include:

- PHP 8.2.30
- PHP 8.3.30
- PHP 8.4.20
- PHP 8.5.5

Older compatibility binaries are present but are not candidates for the new platform baseline.

## Tooling

- WP-CLI: 2.12.0
- Git: 2.43.0
- MySQL client: 8.0.46 (Ubuntu package)

## Reference WordPress application

The active Data Inspire WordPress installation has been positively identified and queried through WP-CLI.

- WordPress core: 7.0.4
- `home` and `siteurl`: HTTPS canonical production URL confirmed
- `DB_CHARSET`: `utf8`
- `DB_COLLATE`: empty / not explicitly forced in `wp-config.php`
- Effective WordPress database connection: `utf8mb4` / `utf8mb4_unicode_520_ci`

The project-specific document root and URL are intentionally not required by the reusable provider profile.

## Database runtime

The active WordPress database has been queried successfully through WP-CLI without exposing credentials. Separate sanitized references record the database and schema details.

Confirmed:

- MySQL server 8.0.41 (Ubuntu);
- server/database default `utf8mb3` / `utf8mb3_unicode_ci`;
- SQL mode `NO_ENGINE_SUBSTITUTION`;
- 32 MiB `max_allowed_packet`;
- database-scoped application grants captured and sanitized;
- 47 base tables, of which 45 are `utf8mb4`;
- 46 InnoDB tables and one legacy MyISAM table;
- no triggers, routines or events in the active schema;
- reusable baseline selected as InnoDB + `utf8mb4`, with WordPress-oriented connection collation `utf8mb4_unicode_520_ci`.

## Validation state

Completed:

- [x] Shell access verified
- [x] OS/runtime fingerprint captured
- [x] Apache version captured
- [x] CLI PHP version/modules/settings captured
- [x] DreamHost website PHP family captured
- [x] Exact web/FastCGI PHP patch version captured
- [x] Effective web-runtime limits captured
- [x] SAPI confirmed as `cgi-fcgi`
- [x] OPcache confirmed enabled in web runtime
- [x] WP-CLI version captured
- [x] Git version captured
- [x] MySQL client version captured
- [x] Active WordPress installation verified
- [x] WordPress core version captured
- [x] Database server fingerprint and effective grants captured
- [x] Database/table charset, collation and engine inventory captured
- [x] Effective WordPress database connection charset/collation captured
- [x] Existing trigger/routine/event inventory captured

Optional follow-up:

- [ ] WordPress plugin/theme inventory
- [ ] Determine provenance/current dependency status of the legacy `feeds` table during Data Inspire migration analysis

## Design implication

The DreamHost discovery phase now provides a sufficient measured baseline to build `wp-dev-platform v0.1.0-rc1`.

The application runtime should target **PHP 8.3.30 compatibility**, Apache-hosted PHP behavior, web execution limits matching the measured FastCGI environment where materially relevant, MySQL 8 compatibility, and the selected clean InnoDB + `utf8mb4` database policy.

The platform should reproduce compatibility constraints rather than DreamHost server identity. The shell's PHP 8.2 default is an operational characteristic and should not drive the application container runtime.