ARG MYSQL_BASE_IMAGE=mysql:8.0.41
FROM ${MYSQL_BASE_IMAGE}

COPY mysql/10-restrict-app-user.sh /docker-entrypoint-initdb.d/10-restrict-app-user.sh
RUN chmod 0755 /docker-entrypoint-initdb.d/10-restrict-app-user.sh
