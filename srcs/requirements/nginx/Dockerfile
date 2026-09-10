FROM debian:bookworm

RUN apt update && apt install -y nginx

COPY ./tools/init.sh .
COPY ./tools/wordpress.conf /etc/nginx/conf.d/wordpress.conf

RUN chmod +x init.sh

ENTRYPOINT ["./init.sh"]
