#!/bin/bash

sleep 10

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION . "\n";')
FPM_COMMAND="php${PHP_VERSION}-fpm"

cp /www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/

echo "test"

if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "config doesnt exist"
	sed -i "s/^post_max_size = 8M/post_max_size = 999G/g" /etc/php/${PHP_VERSION}/fpm/php.ini
	sed -i "s/^upload_max_filesize = 2M/upload_max_filesize = 999G/g" /etc/php/${PHP_VERSION}/fpm/php.ini

	wp config create --skip-check --allow-root --dbname=$WP_DB_NAME --dbuser=$WP_DB_USER --dbpass="$(cat $WORDPRESS_DB_PASSWORD_FILE)" --dbhost=$DB_HOSTNAME

	wp core install --allow-root --admin_email="ibenne@student.codam.nl" --url="ibenne.42.fr" --title="Ismo's site" --admin_user=$WP_ADMIN_USER --admin_password=$(cat $WORDPRESS_ADMIN_PASSWORD_FILE)
fi

exec "php-fpm$PHP_VERSION" -F
