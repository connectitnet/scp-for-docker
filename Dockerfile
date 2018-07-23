FROM alpine

RUN apk add --update-cache bash openssh rssh \
 && rm -f /etc/ssh/ssh_host_*

ARG DEFAULT_USER=data

ENV SCP_DEFAULT_USER=${DEFAULT_USER}
ENV SCP_USERS ${DEFAULT_USER}
ENV AUTHORIZED_KEYS_FILE /home/${DEFAULT_USER}/.ssh/authorized_keys

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd \
 && echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config \
 && echo "allowscp" >> /etc/rssh.conf \
 && echo "allowsftp" >> /etc/rssh.conf

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME [ "/etc/ssh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD netstat -an | grep -q :22 || exit 1

EXPOSE 22
CMD ["/entrypoint.sh"]