#!/bin/bash
# MAKE the script exit if any ERROR occurs
set -e

# CHECK whether the ROOT can LOGIN to the DATABASE
rootLogin() {
	echo "Can the root login?"
	mysql -u root -p"$DB_ROOTPWD" -e ";" 2>/dev/null
}

# CHECK whether the DB can be used
dbUsable() {
	echo "Can the DB be used?"
	mysql -u root -p"$DB_ROOTPWD" -e "USE $DBNAME;" 2>/dev/null
}

# THE above two functions actually let it to CHECK if the database exists or NOT
# WRAP the two functions into one
dbExists() {
	echo "Checking DB availability..."
	rootLogin && dbUsable;
}

# EXECUTE (in the background) mysqld_safe script to which will safely start the server
echo "mysqld_safe..."
mysqld_safe --verbose --skip-networking & # --skip-networking makes it to only available for local network connections
# SAVE the process ID of the mysql-server being started by the above command (script)
serverPID=$!

sleep 5
# # Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
	echo "successful?"
	sleep 2
done

# REMOVE database if exists
if mysql -u root -p"$DB_ROOTPWD" -e "SHOW DATABASES LIKE '$DBNAME';" | grep "$DBNAME"; then
	echo "Removing database $DBNAME"
	mysql -u root -p"$DB_ROOTPWD" <<EOF
	DROP DATABASE IF EXISTS $DBNAME;
EOF
fi

# CREATE the database and configure the settings if the DATABASE does not exist
# if dbExists; then
# 	echo "THE DATABASE EXISTS"
# else
if mysql -u root -p"$DB_ROOTPWD" -e ";" 2>/dev/null && dbUsable; then
 	echo "THE DATABASE EXISTS"
else
	echo "INITIALIZING THE DATABASE"
	#mysql -u root <<EOF
	mysql -u root -p"$DB_ROOTPWD" <<EOF
		USE mysql;
		FLUSH PRIVILEGES;

		DELETE FROM mysql.user WHERE User='';
		CREATE DATABASE $DBNAME CHARACTER SET utf8 COLLATE utf8_general_ci;
		CREATE USER IF NOT EXISTS '$WP_DBUSR'@'%' IDENTIFIED BY '$WP_DBPWD';
		GRANT ALL PRIVILEGES ON $DBNAME.* TO '$WP_DBUSR'@'%';
		GRANT ALL PRIVILEGES ON *.* TO '$WP_DBUSR'@'%' IDENTIFIED BY '$WP_DBPWD';
		GRANT SELECT ON mysql.* TO '$WP_DBUSR'@'%';
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DB_ROOTPWD';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOTPWD';
		ALTER USER 'root'@'%' IDENTIFIED BY '$DB_ROOTPWD';
		FLUSH PRIVILEGES;
EOF
fi

# SHUTDOWN  the previously started DATABASE server
echo "SHUTDOWN mysql"
mysqladmin -u root -p"$DB_ROOTPWD" shutdown
#mysqladmin -u root -p"$DB_ROOTPWD" --socket=/run/mysqld/mysqld.sock shutdown


# WAIT for the process of the DATABASE server
wait $serverPID

# RESTART the SERVER as after configuring it (if the database was created)
echo "restart mysql"
exec mysqld_safe
