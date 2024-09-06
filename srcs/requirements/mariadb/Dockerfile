# Pull OS (debian with its Application Layer to install mariadb-server on)
FROM debian:bullseye

# Update apt-get and install mariadb-server on debian's application layer
RUN <<EOF
	apt-get update
	apt-get upgrade -y
	apt-get install -y mariadb-server
	mkdir -p /var/lib/mysq
	mkdir -p /run/mysqld
	chown -R mysql:mysql /var/lib/mysql
	chown -R mysql:mysql /run/mysqld
EOF


COPY	./conf/mdb-server.cnf	/etc/mysql/mariadb.conf
RUN	chmod 644 /etc/mysql/mariadb.conf

COPY	./tools/mdb-server-setup.sh	/bin/mdb-server-setup.sh
RUN	chmod +x /bin/mdb-server-setup.sh

RUN mariadb-install-db --user=mysql --ldata=/var/lib/mysql

EXPOSE 3306

ENTRYPOINT	["/bin/mdb-server-setup.sh"]

