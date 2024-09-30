# PULL base image (debian's application layer)
FROM	debian:bullseye

# make debian non-interactive while installing requirements
ENV DEBIAN_FRONTEND=noninteractive

RUN	<<EOF
		apt-get update
		apt-get upgrade -y
		apt-get install -y \
		php7.4 php7.4-mysql php7.4-fpm php7.4-curl php7.4-gd iproute2 \
		php7.4-intl php7.4-mbstring php7.4-soap php7.4-xml netcat \
		php7.4-xmlrpc php7.4-zip wget mariadb-client php7.4-redis curl iputils-ping\
EOF

# CONFIGURE php-fpm
RUN	<<EOF
	    mkdir -p /run/php
	    chown -R www-data:www-data /run/php
EOF
COPY	./conf/wordpress.conf	/etc/php/7.4/fpm/pool.d/www.conf

EXPOSE 9000
# CONFIGURE wordpress
WORKDIR	/var/www/html
RUN chown -R www-data:www-data /var/www/html

RUN	<<EOF
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
		chmod +x wp-cli.phar
		mv wp-cli.phar	/usr/local/bin/wp
		wp core download --allow-root
EOF

COPY ./tools/wp-setup.sh /usr/local/bin/

ENTRYPOINT  ["sh", "/usr/local/bin/wp-setup.sh"]
