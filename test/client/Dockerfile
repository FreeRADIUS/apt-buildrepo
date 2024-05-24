ARG from=debian:12
FROM ${from}

ENV debian_frontend=noninteractive

COPY test/client/entrypoint.sh /entrypoint.sh

RUN install -d -m 0755 -o root -g root /etc/apt/keyrings

CMD ["/entrypoint.sh"]
