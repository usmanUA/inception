# Pulls base image (Application layer from debian OS)
FROM	debian:bullseye

# Updates the packages on pulled debian OS (not the whole OS but Application Layer without the Kernel)
# Installs NGINX and openssl on debian's Application Layer
RUN	<<EOF
	apt-get update
	apt-get upgrade -y
	apt-get install -y \
	nginx openssl curl iputils-ping
EOF

EXPOSE 443

RUN	mkdir -p /etc/ssl/certs /etc/ssl/private
COPY	./tools/configNginx.sh	/configNginx.sh
RUN	chmod +x /configNginx.sh

COPY	./conf/nginx.conf	/etc/nginx/nginx.conf
RUN	chmod 644 /etc/nginx/nginx.conf

ENTRYPOINT	["sh", "/configNginx.sh"]
