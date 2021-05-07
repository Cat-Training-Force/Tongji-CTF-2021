FROM alpine:edge
LABEL Author "Nemo Xiong <nemo@anzupop.com>"
# copy motd
COPY ./res/motd /etc/motd
# change to tuna
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# add openssh and clean
RUN apk add --update openssh bash && \
    rm  -rf /tmp/* /var/cache/apk/*
# make sure we get fresh host keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
COPY ./res/generate_host_key.sh /
RUN bash /generate_host_key.sh
# sshd config
COPY ./res/sshd_config /etc/ssh/sshd_config
# before ssh session, show banner
COPY ./res/banner /etc/ssh/sshd-banner
# add chall user
RUN addgroup -S chall && adduser -S chall -G chall -h /home/chall/ -s /bin/bash
COPY ./res/welcome.txt /home/chall
RUN chmod 444 /home/chall/welcome.txt
# Alpine: make password hash section in shadow not '!'
RUN echo "chall:$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)" | chpasswd
# switch to chall
USER chall
# prepare publickey
COPY --chown=chall:chall ./res/id_rsa.pub /home/chall/.ssh/authorized_keys
RUN chmod 600 /home/chall/.ssh/authorized_keys
RUN chmod 700 /home/chall/.ssh/
# expose 22
EXPOSE 22
# secret!
COPY ./res/secret.txt /lib
# entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
