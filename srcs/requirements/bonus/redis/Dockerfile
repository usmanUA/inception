FROM debian:bullseye


RUN <<EOF
	apt-get update
	apt-get upgrade -y
	apt-get install -y redis-server php-redis
EOF

COPY ./tools/setup-redis.sh /tmp/setup-redis.sh

RUN	chmod +x /tmp/setup-redis.sh

ENTRYPOINT	["/tmp/setup-redis.sh"]

CMD	['usr/bin/redis-server', '--protected-mode no']
