ARG HTTPD_BASE_IMAGE=httpd:2.4.68
FROM ${HTTPD_BASE_IMAGE}

COPY apache/httpd.conf /usr/local/apache2/conf/httpd.conf

RUN httpd -t
