ARG HTTPD_BASE_IMAGE=httpd:2.4.68
FROM ${HTTPD_BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/ThatisMyGitHub/wp-dev-platform" \
      org.opencontainers.image.version="0.1.0" \
      org.opencontainers.image.description="Apache FastCGI frontend for wp-dev-platform"

COPY apache/httpd.conf /usr/local/apache2/conf/httpd.conf

# The runtime WordPress volume is mounted at /var/www/html. Create the path in
# the image as well so Apache's build-time syntax check can validate the config.
RUN mkdir -p /var/www/html && httpd -t
