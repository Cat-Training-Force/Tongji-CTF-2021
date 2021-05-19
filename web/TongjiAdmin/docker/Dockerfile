FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y php
COPY ./src /var/www/html
COPY ./entrypoint.sh /tmp/
RUN rm /var/www/html/index.html && chmod +x /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]
