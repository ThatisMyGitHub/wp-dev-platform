ARG WORDPRESS_BASE_IMAGE=wordpress:7.0.4-php8.3-fpm
FROM ${WORDPRESS_BASE_IMAGE}

ARG WP_CLI_VERSION=2.12.0

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl default-mysql-client less; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" -o /usr/local/bin/wp; \
    chmod 0755 /usr/local/bin/wp; \
    wp --allow-root --info
