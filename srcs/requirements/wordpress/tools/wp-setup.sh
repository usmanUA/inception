#!/bin/bash
set -e

mariaDB_start() {
	echo "Waiting for MariaDB to start..."
	local total=25
	local ticks=0
	local wait=1

	until nc -z -v mariadb port 3306; do
	{
		ticks=$((ticks + 1))
		if ["$ticks" -ge "$total"]; then
			echo "\nMariaDB server did not respond. Exiting..."
			exit 1
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
	wp create config --dbname="$DBNAME" --dbuser="$DBUSER" --dbpass="$DB_USERPASSWORD" --dbhost="mariadb" --allow-root --skip-check
}

wordpressInstall() {
	echo "Installing wordpress..."
	wp core install --url="$DOMAIN" --title="$WP_TITLE" --admin_user="$WP_ADMINUSR" \
		--admin_password="$WP_ADMINPWD" --admin_email="$WP_ADMINEMAIL" --allow-root
}

wordpressUser_create() {
	echo "Creating WordPress User..."
	if ! wp user get "$USER" --field=ID --allow-root > /dev/null 2>$1; then
		wp user create "$WP_USER" "$WP_EMAIL" --role=author --user_pass="$WP_USRPWD" --allow-root
	else
		echo "User already exists!"
	fi
}

wordpressConfig_setup() {
	echo "Setting up WordPress Config..."
	wp config set WP_CACHE true --allow-root
	wp config set WP_DEBUG --allow-root
	wp config set FORCE_SSL_ADMIN false --allow-root
}

main() {
	# WAIT for mariadb server to start
	mariaDB_start()
	# CONFIGURE wordpress if the config file does not exist
	if [! -f /var/www/html/wp-config.php ]; then
		echo "Configuring WordPress\n"
		# CREATE wordpress config file (wp-config.php)
		wordpressConfig_create
		# INSTALL wordpress
		wordpressInstall
		# CREATE wordpress user
		wordpressUser_create
	else
		echo "Wordpress is already is configured.\n"
	fi
	echo -e "Starting PHP-FMP...\n"
	/usr/sbin/php-fpm7.4 -F
}

main
