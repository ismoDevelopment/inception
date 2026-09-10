#!/bin/bash

service mariadb start

mariadb -e "CREATE DATABASE IF NOT EXISTS $WP_DB_NAME;"
mariadb -e "CREATE USER $WP_DB_USER@'%' IDENTIFIED BY '$(cat $WORDPRESS_DB_PASSWORD_FILE)';"
mariadb -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'%';"
mariadb  -u "$WP_DB_ROOTUSER" -e "ALTER USER '$WP_DB_ROOTUSER'@'localhost' IDENTIFIED BY '$(cat $WORDPRESS_DB_ROOT_PASSWORD_FILE)';"
mysql --user="${mysql_root_user}" --password="$(cat $WORDPRESS_DB_ROOT_PASSWORD_FILE)" -e "FLUSH PRIVILEGES;"

mysqladmin --user="${mysql_root_user}" --password="$(cat $WORDPRESS_DB_ROOT_PASSWORD_FILE)" shutdown

exec mariadbd-safe
