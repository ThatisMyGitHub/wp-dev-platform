ARG WORDPRESS_BASE_IMAGE=wordpress:7.0.4-php8.3-fpm
FROM ${WORDPRESS_BASE_IMAGE}

ARG WP_CLI_VERSION=2.12.0
ARG PHP_BUILD_JOBS=1

LABEL org.opencontainers.image.source="https://github.com/ThatisMyGitHub/wp-dev-platform" \
      org.opencontainers.image.version="0.1.0" \
      org.opencontainers.image.description="DreamHost-compatible WordPress/PHP runtime for wp-dev-platform"

# The official WordPress image already provides the core WordPress extension set
# (including bcmath, exif, gd, intl, mysqli, zip and imagick). DreamHost Shared
# exposes a broader automatically-enabled PHP web baseline, so add the missing
# compatibility extensions that can materially affect plugins/migrations.
#
# Database diagnostics deliberately use PHP mysqli (the same client path used by
# WordPress). Do not install Debian's `default-mysql-client` here: on current
# Debian it is a MariaDB client and can introduce authentication/plugin behavior
# that does not match the DreamHost MySQL 8 CLI/runtime.
#
# Source builds default to one compiler job so low-resource hosts remain usable.
# Production/Portainer deployment does not build this image; CI publishes the
# exact validated AMD64 image to GHCR for Carida/QNAP consumption.
RUN set -eux; \
    case "${PHP_BUILD_JOBS}" in \
        ''|*[!0-9]*|0) echo "PHP_BUILD_JOBS must be a positive integer" >&2; exit 64 ;; \
    esac; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        less \
        libbz2-dev \
        libxml2-dev \
        libxslt1-dev \
    ; \
    docker-php-ext-install -j "${PHP_BUILD_JOBS}" \
        bz2 \
        calendar \
        ftp \
        gettext \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" -o /usr/local/bin/wp; \
    chmod 0755 /usr/local/bin/wp; \
    wp --allow-root --info; \
    php -m | sort

COPY php/zz-dreamhost.ini /usr/local/etc/php/conf.d/zz-dreamhost.ini
COPY wordpress/wpdev-doctor /usr/local/bin/wpdev-doctor
COPY wordpress/default.htaccess /usr/local/share/wpdev/default.htaccess
COPY wordpress/repair-wordpress-htaccess.php /usr/local/share/wpdev/repair-wordpress-htaccess.php
RUN chmod 0755 /usr/local/bin/wpdev-doctor \
    && chmod 0644 /usr/local/share/wpdev/default.htaccess \
    && chmod 0644 /usr/local/share/wpdev/repair-wordpress-htaccess.php
