#!/bin/bash

set -e

mkdir -p "$MOUNTPOINT"

echo "Starting NFS client ====================================="


function term_handler () {
    echo "Stopping NFS client ====================================="
    echo "Unmounting $MOUNTPOINT ($SERVER:$SHARE)"
    umount -t "$FSTYPE" "$MOUNTPOINT"
    exit 143;
}


function mount_nfs_share () {
    # check if we can resolve the server address, if not wait until we can
    RESOLVED=$(getent hosts $SERVER | awk '{ print $1 }')

    if [ -z "$RESOLVED" ];then
       echo "Unable to resolve server '$SERVER', waiting..."
       until [ ! -z "$(getent hosts $SERVER | awk '{ print $1 }')" ]; do
           sleep 0.1;
       done
    fi
    RESOLVED=$(getent hosts $SERVER | awk '{ print $1 }')
    echo "Mounting $SERVER($RESOLVED):$SHARE to $MOUNTPOINT"
    rpc.statd & rpcbind -f &
    mount -t "$FSTYPE" -o "$MOUNT_OPTIONS" "$SERVER:$SHARE" "$MOUNTPOINT"
}

if [ $SERVER == "" ]; then
    rpc.statd & rpcbind -f & echo "docker NFS client with rpcbind ENABLED... if you wish to mount the mountpoint in this container USE THE FOLLOWING SYNTAX instead:
    $ docker run -itd --privileged=true --net=host -v vol:/mnt/nfs-1:shared -e SERVER= X.X.X.X -e SHARE=shared_path d3fk/nfs-client" & more
else
    mount_nfs_share;
fi

trap 'term_handler' SIGTERM

while true
do
  tail -f /dev/null & wait ${!}
done
