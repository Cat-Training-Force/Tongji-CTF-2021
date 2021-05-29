FROM debian:latest

RUN apt update && apt upgrade -y && apt install -y python3 python3-pip
COPY ./src /var/www/webapp
WORKDIR /var/www/webapp
RUN pip3 install -r requirements.txt
RUN useradd flask && chown flask:flask .
USER root
ENV FLASK_APP=webApp:app
ENTRYPOINT ["flask"]
CMD ["run", "--host=0.0.0.0", "--port=80"]
