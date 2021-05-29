FROM php:7.2-apache
COPY ./sites-enabled /etc/apache2/sites-enabled
COPY ./src /var/www

EXPOSE 20080
EXPOSE 20081
EXPOSE 20000
 
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
