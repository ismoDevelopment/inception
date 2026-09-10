FROM debian:bookworm

RUN apt update

RUN apt install -y php-fpm \
	php-mysql \
	php-curl \
	php-dom \
	php-imagick \
	php-mbstring\
	php-zip \
	php-gd \
	php-intl \
	curl \
	unzip

COPY ./tools/www.conf .

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

RUN wp core download --allow-root

COPY ./tools/init.sh .

RUN chmod +x init.sh

ENTRYPOINT ["./init.sh"]
