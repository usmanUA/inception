#!/bin/bash

set -e

# Generate the SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FI/L=HEL/O=Hive/OU=Helsinki/CN=uahmed.42.fr"

chmod 600 /etc/ssl/private/nginx-selfsigned.key

nginx -t

nginx -c /etc/nginx/nginx.conf -g "daemon off;"
