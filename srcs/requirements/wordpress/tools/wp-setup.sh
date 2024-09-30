#!/bin/bash
set -e

mariaDB_start() {
	echo "Waiting for MariaDB to start..."
	local total=25
	local ticks=0
	local wait=1

	until mysql -h"$DBHOST" -u"$WP_DBUSR" -p"$WP_DBPWD" "$DBNAME" ; do
	{
		ticks=$((ticks + 1))
		if [ "$ticks" -ge "$total" ]; then
			echo "\nMariaDB server did not respond. Exiting..."
		fi
		sleep "$wait"
		echo -n "."
	}
	done
	sleep 10
	echo -e "\nMariaDB server started..."
}

wordpressConfig_create() {
	echo "Creating wp-config.php"
	wp config create --dbname="$DBNAME" --dbuser="$WP_DBUSR" --dbpass="$WP_DBPWD" --dbhost="$DBHOST" --allow-root --skip-check
}

wordpressInstall() {
	echo "Installing wordpress..."
	wp core install --url="$DOMAIN" --title="$WP_TITLE" --admin_user="$WP_ADMINUSR" \
		--admin_password="$WP_ADMINPWD" --admin_email="$WP_ADMINEMAIL" --allow-root
}

wordpressUser_create() {
	echo "Creating WordPress User..."
	if ! wp user get "$WP_DBUSR" --field=ID --allow-root > /dev/null 2>&1; then
		wp user create "$WP_DBUSR" "$WP_EMAIL" --role=author --user_pass="$WP_USRPWD" --allow-root
	else
		echo "User $WP_DBUSR already exists!"
	fi
}

wordpressConfig_setup() {
	echo "Setting up WordPress Config..."
	wp config set WP_CACHE true --allow-root
	wp config set WP_DEBUG true --allow-root
	wp config set FORCE_SSL_ADMIN false --allow-root
}

# NOTE: bonus config - redis cache
wordpress_install_redis() {
	echo "Installing redis plugins..."
	wp plugin install redis-cache --allow-root
	wp plugin activate redis-cache --allow-root
	wp config set WP_REDIS_HOST "redis" --allow-root
	wp config set WP_REDIS_PORT 6379 --allow-root
	wp redis enable --allow-root
}

# NOTE: set permissions for wordpress
wordpress_setPermissions() {
	echo "Setting up permissions for wordpress..."
	chwon -R www-data:www-data /var/www/html
	find /var/www/html -type d -exec chown 755 {} \;
	find /var/www/html -type f -exec chown 644 {} \;

}

# NOTE: set permissions for wordpress
wordpress_installThemes() {
	echo "Setting up permissions for wordpress..."
	wp theme install astra --allow-root
	wp theme activate astra --allow-root
	wp theme update astra --allow-root
}

main() {
	# WAIT for mariadb server to start
	mariaDB_start
	rm -rf wp-config.php
	# CONFIGURE wordpress if the config file does not exist
	if [ ! -f /var/www/html/wp-config.php ]; then
		echo "Configuring WordPress\n"
		# CREATE wordpress config file (wp-config.php)
		wordpressConfig_create
		# INSTALL wordpress
		wordpressInstall
		# CREATE wordpress user
		wordpressUser_create

		# NOTE: bonus config - redis cache
		# install redis plugin
		# wordpress_install_redis
		#
		# # NOTE: set permissions for the WP website
		# wordpress_setPermissions
		#
		# # NOTE: install theme(s) for the WP website
		# wordpress_installThemes
		
	else
	 	echo "Wordpress is already configured.\n"
	fi
	echo -e "Starting PHP-FMP...\n"
	/usr/sbin/php-fpm7.4 -F
}

main
