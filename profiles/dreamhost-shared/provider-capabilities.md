# DreamHost Shared configurable capabilities

**Observed/confirmed:** 2026-08-22  
**Provider profile:** `dreamhost-shared`  
**Purpose:** record the configuration envelope available on the current DreamHost Shared plan separately from the Data Inspire values measured for compatibility.

## Why this document exists

The files under `reference/` describe **what Data Inspire currently runs**. This document describes **what the hosting plan allows us to change** when an application has a justified requirement.

A current production value is therefore not automatically a hard platform limit. For example, Data Inspire currently runs with `memory_limit=128M` and `max_execution_time=120`, but DreamHost exposes PHP configuration controls that may allow another supported value to be selected for a future solution. Any deviation must be validated against DreamHost resource limits and then reproduced in development/testing.

The reusable platform must distinguish:

1. **measured baseline** — the current Data Inspire production behavior;
2. **provider capability envelope** — settings DreamHost Shared exposes for configuration;
3. **project requirement** — a deliberate customer/application-specific override;
4. **validated effective value** — the value actually observed after applying the provider configuration.

## PHP version selection

DreamHost allows the PHP version of a fully hosted site to be selected from the panel. The Data Inspire site currently uses PHP 8.3 and was measured at PHP 8.3.30.

A future project may select another PHP version when supported/required, but the corresponding development profile must be updated and validated before deployment. Older/EOL PHP versions may be available through DreamHost Extended Support and must not be selected merely for convenience.

## General PHP settings exposed by the panel

The current Shared plan exposes the following PHP controls in **Manage Websites -> Settings -> PHP -> General**:

- `memory_limit`
- `upload_max_filesize`
- `post_max_size`
- `max_execution_time`
- `max_input_time`
- `max_input_vars`
- temporary PHP warnings

Current Data Inspire effective values are recorded in the runtime fingerprint; they are the RC1 compatibility defaults, not immutable provider limits.

DreamHost notes that excessively high settings may be constrained/reverted by the resources available on the Shared plan. A project must therefore verify the effective value after any change rather than assuming the requested value was accepted.

## PHP extensions

The panel exposes optional extension controls. At the time of this profile capture DreamHost documents panel toggles for:

- `gmp`
- `tidy`

The panel also lists extensions that are auto-enabled and not individually switchable. DreamHost supports additional extension/loader customization through its PHP configuration mechanisms where technically supported.

**Platform rule:** do not install/use an optional PHP extension in development unless the target hosting profile confirms it can be enabled in production. If a customer solution needs `gmp`, `tidy`, or another non-baseline extension, add it deliberately to the project/runtime overlay and validate it against DreamHost before release.

## OPcache

OPcache is enabled by default on DreamHost Shared and is enabled in the measured Data Inspire web runtime.

The PHP settings interface exposes OPcache information and an advanced-settings area. DreamHost documents the following OPcache values/controls in this area, with exact availability depending on PHP version/plan:

- `memory_consumption`
- `max_accelerated_files`
- `interned_strings_buffer`
- `file_cache_only`
- `file_update_protection`
- `force_restart_timeout`
- `max_file_size`
- `max_wasted_percentage`
- `revalidate_freq`
- `validate_timestamps`
- `huge_code_pages`

On Shared Hosting, DreamHost documents the primary displayed OPcache resource values as informational rather than freely editable. Advanced options and available controls can vary by PHP version. Therefore a specific OPcache change must be confirmed in the live panel before it is treated as a supported project requirement.

## Custom PHP configuration beyond panel controls

DreamHost supports custom PHP configuration through the user's PHP configuration (`phprc`) mechanism. This means the panel is not necessarily the complete configuration surface.

**Platform rule:** when a project needs a PHP setting not exposed directly by the panel, verify that DreamHost permits it through `phprc`, apply it in a controlled test, measure the effective web runtime, and reproduce the same behavior in the project's development overlay.

## Configuration scope: important multi-site/customer constraint

DreamHost's PHP Settings documentation states that changed PHP settings apply to **all websites assigned to the same SFTP/SSH user**, and when sites under that user have conflicting settings the most recently applied setting takes effect.

The PHP **version** itself is selected per hosted site, but general PHP tuning must be treated as potentially user-scoped.

### Architecture consequence

For future customer deployments, prefer a **dedicated DreamHost SFTP/SSH user per independent customer/site** when different PHP tuning, extensions or operational isolation may be required. Do not place unrelated customers under one Unix user merely to simplify account management.

For Data Inspire, any PHP-setting change must also be evaluated against other hosted domains sharing the same DreamHost user before applying it.

## Website directory mapping

DreamHost Shared permits the web directory assigned to a domain to be changed from the Website Settings panel. This can support application layouts where the public document root must point to a specific subdirectory.

The directory must exist under the assigned hosting user. Directory remapping is a provider capability, not a default requirement of the WordPress platform.

## Other website-level controls visible in the hosting panel

The current website-management interface also exposes provider-managed configuration/services such as:

- DNS management;
- SSL/security controls;
- Unique IP / IPv6 management where available;
- WordPress-specific management features when DreamHost recognizes the installation;
- logs and traffic views;
- file management and restore/migration functions.

These capabilities should be considered during solution design rather than assuming that every operational feature must be implemented inside WordPress or Docker. Their exact availability and commercial terms can vary by plan/account and should be verified before making them a customer requirement.

## How project-specific overrides should be handled

The base `dreamhost-shared` profile remains aligned with the measured Data Inspire baseline. Do not mutate the reusable baseline solely because one project needs a different setting.

For a justified project-specific requirement:

1. identify the DreamHost-supported configuration mechanism;
2. verify scope (site vs SFTP/SSH user vs account);
3. verify any resource/plan limitation;
4. reproduce the change in a project-specific development overlay;
5. measure/validate the effective value in development;
6. apply it to the target DreamHost site;
7. re-run a minimal web-runtime fingerprint to verify the effective production value;
8. record the requirement in the consumer project's configuration/status documentation.

This keeps the reusable profile portable while still exploiting DreamHost capabilities when they provide real product value.
