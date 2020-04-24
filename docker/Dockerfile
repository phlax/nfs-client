ARG BUILD_FROM=debian:buster-slim

FROM $BUILD_FROM
ARG DEBIAN_FRONTEND=noninteractive

ENV MOUNTPOINT /mnt/nfs-1

RUN apt-get update -qq -y \
	&& apt-get install -qq -y \
              --no-install-recommends \
              --no-install-suggests \
         	nfs-client \
	&& rm -rf /var/tmp/*

ADD nfs-entry.sh /usr/local/bin/entry.sh

ENTRYPOINT ["/usr/local/bin/entry.sh"]
