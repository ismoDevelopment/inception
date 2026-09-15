#!/bin/bash

sed -i "s/MY_DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/conf.d/wordpress.conf
nginx -s reload
exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"
