FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y python3 python3-pip
COPY ./src /var/www/webapp
WORKDIR /var/www/webapp
RUN pip3 install -r requirements.txt
ENTRYPOINT ["python3"]
CMD ["webApp.py"]

