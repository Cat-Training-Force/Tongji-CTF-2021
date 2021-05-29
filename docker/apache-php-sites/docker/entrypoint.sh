#!/bin/sh

chown www-data:www-data -R /var/log/apache2 && \
apache2ctl -k start && \
while true; do sleep 1000; done

