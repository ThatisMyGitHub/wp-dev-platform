# DreamHost PHP runtime identification

**Status:** canonical provider-profile guidance  
**Observed/reconfirmed:** 2026-10-02  
**Profile:** dreamhost-shared

## Why this matters

DreamHost Shared can expose multiple PHP execution contexts at the same time. Operators and migration tooling must not collapse them into a single PHP version field.

A hosted website may be configured for PHP 8.3 in the DreamHost panel while the SSH shell default remains PHP 8.2. Plain WP-CLI can inherit that shell PHP unless an explicit interpreter is selected.

This distinction is required to avoid false environment drift, false plugin requirement failures and unnecessary provider-side PHP changes.

## Execution contexts

### Provider-configured website PHP

The DreamHost control panel selects the PHP family for each fully hosted website.

This is control-plane evidence for the intended HTTP runtime family.

### Effective web/FastCGI PHP

The actual HTTP request path executes PHP through DreamHost's FastCGI environment. This is the authoritative application compatibility context.

When exact effective identity matters, validate it through a bounded web-runtime diagnostic or another accepted provider-realistic fingerprint. Do not infer it from SSH shell output.

### Default shell PHP

The command:

~~~bash
php -v
~~~

reports the default CLI interpreter available to the SSH session.

On the current measured DreamHost host:

~~~text
DEFAULT_CLI_PHP=8.2.30
~~~

That observation does not mean a site configured for PHP 8.3 is serving web requests through PHP 8.2.

### WP-CLI PHP

DreamHost's wp executable is a shell wrapper. By default it selects the php executable found on PATH, so a plain wp command may run under the default shell PHP rather than the site's configured web PHP.

For a PHP 8.3-governed project, use:

~~~bash
WP_CLI_PHP=/usr/local/php83/bin/php wp --path="$ROOT" <command>
~~~

On 2026-10-02 the current host exposed:

~~~text
/usr/local/php82/bin/php = 8.2.30
/usr/local/php83/bin/php = 8.3.30
plain wp PHP             = 8.2.30
WP_CLI_PHP=php83 wp PHP  = 8.3.30
~~~

## Wrapper trap

Do not run:

~~~bash
/usr/local/php83/bin/php "$(command -v wp)" ...
~~~

The DreamHost wp executable is a shell wrapper, not the PHP entrypoint. Passing it directly to the PHP interpreter can print the wrapper source and exit successfully without executing WP-CLI.

A gate that checks only exit status can therefore produce a false PASS.

Use the wrapper-supported WP_CLI_PHP environment variable and assert expected semantic output markers.

## Migration and parity rule

Environment inventory should record separate fields:

~~~text
PROVIDER_CONFIGURED_WEB_PHP
EFFECTIVE_WEB_PHP
DEFAULT_CLI_PHP
WPCLI_DEFAULT_PHP
WPCLI_GOVERNED_PHP
~~~

Comparison rules:

1. web runtime must be compared with web runtime;
2. shell runtime must be compared with shell runtime only when shell tooling itself matters;
3. WP-CLI compatibility checks must record the PHP interpreter used;
4. plugin Requires PHP checks should run under the governed project PHP family;
5. a CLI/web mismatch is not automatically provider drift;
6. provider PHP settings should not be changed merely to align the shell default.

## Current provider-profile implication

The reusable dreamhost-shared application target remains PHP 8.3.x.

The shell's PHP 8.2 default is an operational characteristic of the host and must not drive the application runtime baseline.

Consumer repositories should pin or explicitly select the intended PHP interpreter for remote WP-CLI release tooling when application requirements depend on the PHP family.
