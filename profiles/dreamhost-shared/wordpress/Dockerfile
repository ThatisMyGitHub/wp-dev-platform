ARG WORDPRESS_BASE_IMAGE=wordpress:7.0.4-php8.3-fpm
FROM ${WORDPRESS_BASE_IMAGE}

ARG WP_CLI_VERSION=2.12.0

# The official WordPress image already provides the core WordPress extension set
# (including bcmath, exif, gd, intl, mysqli, zip and imagick). DreamHost Shared
# exposes a broader automatically-enabled PHP web baseline, so add the missing
# compatibility extensions that can materially affect plugins/migrations.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        default-mysql-client \
        less \
        libbz2-dev \
        libxml2-dev \
        libxslt1-dev \
    ; \
    docker-php-ext-install -j "$(nproc)" \
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
    curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" -o /usr/local/bin/wp; \
    chmod 0755 /usr/local/bin/wp; \
    wp --allow-root --info; \
    php -m | sort

COPY php/zz-dreamhost.ini /usr/local/etc/php/conf.d/zz-dreamhost.ini
COPY wordpress/wpdev-doctor /usr/local/bin/wpdev-doctor
RUN chmod 0755 /usr/local/bin/wpdev-doctor
