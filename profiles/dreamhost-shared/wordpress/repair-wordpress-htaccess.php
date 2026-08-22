<?php

declare(strict_types=1);

$path = $argv[1] ?? '/var/www/html/.htaccess';
$canonicalPath = $argv[2] ?? '/usr/local/share/wpdev/default.htaccess';

$existing = @file_get_contents($path);
$canonical = @file_get_contents($canonicalPath);

if ($existing === false || $canonical === false) {
    fwrite(STDERR, "Unable to read .htaccess or canonical WordPress rules.\n");
    exit(2);
}

$pattern = '/# BEGIN WordPress.*?# END WordPress/s';

if (!preg_match($pattern, $canonical, $canonicalMatch)) {
    fwrite(STDERR, "Canonical WordPress marker block is missing.\n");
    exit(3);
}

$count = 0;
$updated = preg_replace_callback(
    $pattern,
    static fn(array $match): string => $canonicalMatch[0],
    $existing,
    1,
    $count
);

if ($updated === null || $count !== 1) {
    fwrite(STDERR, "Existing .htaccess does not contain exactly one repairable WordPress marker block.\n");
    exit(4);
}

if (file_put_contents($path, $updated) === false) {
    fwrite(STDERR, "Unable to write repaired .htaccess.\n");
    exit(5);
}
