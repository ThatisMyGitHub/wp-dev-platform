# DreamHost Shared runtime baseline — 2026-08-22

Sanitized reference captured from the Data Inspire DreamHost Shared Unlimited environment.

This file intentionally excludes usernames, server hostnames, login IP addresses, database names, database hosts, credentials and other account-specific identifiers.

## Host runtime

- Distribution: Ubuntu 24.04.4 LTS (Noble Numbat)
- Kernel family: Linux 6.18.39, DreamHost grsecurity build
- Architecture: x86_64
- Apache: 2.4.58 (Ubuntu)

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

Important: these are shell/CLI observations. They must not be treated as authoritative web/FastCGI values until the website-assigned PHP version and web runtime are verified.

### PHP modules observed

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

## Validation state

Completed:

- [x] Shell access verified
- [x] OS/runtime fingerprint captured
- [x] Apache version captured
- [x] CLI PHP version/modules/settings captured
- [x] WP-CLI version captured
- [x] Git version captured
- [x] MySQL client version captured

Pending:

- [ ] Website-assigned PHP version from DreamHost panel
- [ ] Web/FastCGI PHP runtime confirmation
- [ ] Database server fingerprint
- [ ] Database effective grants/restrictions
- [ ] Optional WordPress core/plugin/theme inventory

## Design implication

The first runnable `dreamhost-shared` profile must emulate the measured production characteristics that materially affect application behavior, while avoiding unnecessary coupling to DreamHost-internal host details. The development stack should therefore reproduce compatibility constraints, not server identity.
