
FROM debian:buster-slim

RUN apt update && apt install -y -qq --no-install-recommends --no-install-suggests socat
COPY ./start-nfs-proxy /usr/local/bin/start-nfs-proxy

CMD ["/usr/local/bin/start-nfs-proxy"]
