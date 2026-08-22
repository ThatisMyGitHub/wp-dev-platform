# WordPress `.htaccess` self-healing invariant

The `dreamhost-shared` profile seeds the canonical root WordPress rewrite block on a fresh volume.

On an existing volume, the initializer preserves arbitrary `.htaccess` content. If — and only if — the file contains the standard `# BEGIN WordPress` / `# END WordPress` marker block but that block lacks the canonical front-controller rewrite rule, RC1 replaces that single marker block with the versioned canonical block while preserving content before and after it.

A file with no standard WordPress marker block is not rewritten automatically.

This behavior exists because WP-CLI running in the split PHP-FPM container cannot be relied on to regenerate Apache `.htaccess` rules with `wp rewrite flush --hard`. The initializer owns the development-runtime Apache baseline instead.