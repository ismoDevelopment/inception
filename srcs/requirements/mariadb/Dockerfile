FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY ./tools/init.sh .

RUN chmod +x init.sh

RUN sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["./init.sh"]
