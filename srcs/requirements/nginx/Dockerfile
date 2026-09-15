FROM debian:bookworm

RUN apt update && apt install -y nginx \
	openssl

RUN mkdir -p /etc/ssl/private /etc/ssl/certs

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/ibenne.key \
	-out /etc/ssl/certs/ibenne.crt \
	-subj "/C=NL/O=42/OU=42/CN=ibenne"

RUN chmod 600 /etc/ssl/private/ibenne.key

COPY ./tools/init.sh .
COPY ./tools/wordpress.conf /etc/nginx/conf.d/wordpress.conf

RUN chmod +x init.sh

ENTRYPOINT ["./init.sh"]
