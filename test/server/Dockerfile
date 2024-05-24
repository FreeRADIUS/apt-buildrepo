FROM debian:12

ENV debian_frontend=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	bzip2 \
	curl \
	gnupg2 \
	nginx \
	procps

COPY test/server/entrypoint.sh /entrypoint.sh
COPY test/server/nginx-default /etc/nginx/sites-available/default
COPY apt-buildrepo /usr/local/bin/apt-buildrepo

EXPOSE 80

CMD ["/entrypoint.sh"]
