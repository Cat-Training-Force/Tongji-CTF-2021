FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y php
COPY ./src /var/www
COPY ./sites-enabled /etc/apache2/sites-enabled
COPY ./entrypoint.sh /tmp/
RUN chmod +x /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]
