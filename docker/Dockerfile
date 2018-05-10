FROM       debian:stretch-slim


ENV FSTYPE nfs4
ENV MOUNT_OPTIONS nfsvers=4
ENV MOUNTPOINT /mnt/nfs-1

RUN apt-get update -qq -y && apt-get install -qq -y nfs-client && rm -rf /var/tmp/*

ADD nfs-entry.sh /usr/local/bin/entry.sh

ENTRYPOINT ["/usr/local/bin/entry.sh"]
