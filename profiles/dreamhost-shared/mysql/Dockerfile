ARG MYSQL_BASE_IMAGE=mysql:8.0.41
FROM ${MYSQL_BASE_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/ThatisMyGitHub/wp-dev-platform" \
      org.opencontainers.image.version="0.1.0-rc1" \
      org.opencontainers.image.description="DreamHost-compatible MySQL runtime for wp-dev-platform"

COPY mysql/10-restrict-app-user.sh /docker-entrypoint-initdb.d/10-restrict-app-user.sh
RUN chmod 0755 /docker-entrypoint-initdb.d/10-restrict-app-user.sh
