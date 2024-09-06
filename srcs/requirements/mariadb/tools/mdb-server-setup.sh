#!/bin/bash
# MAKE the script exit if any ERROR occurs
set -e

# CHECK whether the ROOT can LOGIN to the DATABASE
rootLogin() {
	mysql -u root -p"$DB_ROOTPWD" -e ";" 2>/dev/null
}

# CHECK whether the DB can be used
dbUsable() {
	mysql -u root -p"$DB_ROOTPWD" -e "USE $DBNAME;" 2>/dev/null
}

# THE above two functions actually let it to CHECK if the database exists or NOT
# WRAP the two functions into one
dbExists() {
	rootLogin && dbUsable;
}

# EXECUTE (in the background) mysqld_safe script to which will safely start the server
mysqld_safe --verbose --skip-networking & # --skip-networking makes it to only available for local network connections
# SAVE the process ID of the mysql-server being started by the above command (script)
serverPID=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
until mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; do
    sleep 2
done

# CREATE the database and configure the settings if the DATABASE does not exist
if dbExists; then
	echo "THE DATABASE EXISTS"
else
	echo "INITIALIZING THE DATABASE"
	mysql -u root -p"$DB_ROOPWD" <<EOF
			CREATE DATABASE IF NOT EXISTS $DBNAME;
			CREATE USER IF NOT EXISTS '$DBUSER'@'%' IDENTIFIED BY '$DB_USRPWD';
			GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' IDENTIFIED BY '$DB_USRPWD';
			GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DB_ROOTPWD';
			ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOTPWD';
			ALTER USER 'root'@'%' IDENTIFIED BY '$DB_ROOTPWD';
			FLUSH PRIVILEGES;
EOF
fi

# SHUTDOWN  the previusly started DATABASE server
mysqladmin -u root -p"$DB_ROOTPWD" --socket=/run/mysqld/mysqld.sock shutdown


# WAIT for the process of the DATABASE server
wait $serverPID

# RESTART the SERVER as after configuring it (if the database was created)
exec mysqld_safe
