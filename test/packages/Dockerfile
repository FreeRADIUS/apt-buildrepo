ARG from=debian:12
FROM ${from}

ENV debian_frontend=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	gnupg2 \
	procps

COPY test/packages/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
