#!/bin/bash

set -e

echo "Starting NFS clients ===================================="

STOP_TIMEOUT=30

function stop_nfs_import () {
    IMPORT=$1
    local NFS_CONFIG_LINE=${!IMPORT}
    local NFS_CONFIG
    read -r -a NFS_CONFIG <<< "$NFS_CONFIG_LINE"
    local NFS_SERVER=${NFS_CONFIG[1]}
    local NFS_MOUNT=${NFS_CONFIG[2]}
    echo "Unmounting $MOUNTPOINT/$NFS_SERVER$NFS_MOUNT..."
    timeout $STOP_TIMEOUT umount "$MOUNTPOINT/$NFS_SERVER$NFS_MOUNT" || umount -v -f "$MOUNTPOINT/$NFS_SERVER$NFS_MOUNT"
    ! $(mount -t "$NFS_TYPE" | grep -E  "^$NFS_SERVER:([/]*)$NFS_MOUNT" || false) || stop_nfs_import $IMPORT
    echo "Unmounted $MOUNTPOINT/$NFS_SERVER$NFS_MOUNT"
}


function stop_imports () {
    echo "Stopping NFS clients ===================================="
    local NFS_IMPORTS=$(compgen -A variable | grep -E 'NFS_[0-9]$' | sort)
    for IMPORT in $NFS_IMPORTS; do
        stop_nfs_import $IMPORT
    done
    exit 143;
}

function mount_nfs_import () {
    local NFS_TYPE=$1
    local NFS_SERVER=$2
    local NFS_MOUNT=$3
    local NFS_OPTIONS=$4
    local RESOLVED=$(getent hosts $NFS_SERVER | awk '{ print $1 }')
    if [ -z "$RESOLVED" ];then
       echo "Unable to resolve server '$NFS_SERVER', waiting..."
       until [ ! -z "$(getent hosts $NFS_SERVER | awk '{ print $1 }')" ]; do
           sleep 0.1;
       done
    fi
    RESOLVED=$(getent hosts $NFS_SERVER | awk '{ print $1 }')
    if [ -z "$NFS_OPTIONS"  ]; then
        if [ $NFS_TYPE = 'nfs4' ]; then
            NFS_OPTIONS='nfsvers=4'
        fi
    fi
    # rpc.statd & rpcbind -f &
    mkdir -p "$MOUNTPOINT/$NFS_SERVER$NFS_MOUNT"

    echo "Mounting $NFS_SERVER($RESOLVED):$NFS_MOUNT to $MOUNTPOINT/$NFS_SERVER$NFS_MOUNT with $NFS_OPTIONS"
    mount -t "$NFS_TYPE" -o "$NFS_OPTIONS" "$NFS_SERVER:$NFS_MOUNT" "$MOUNTPOINT/$NFS_SERVER$NFS_MOUNT"
    mount -t "$NFS_TYPE" | grep -E  "^$NFS_SERVER:([/]*)$NFS_MOUNT"
}


function init_nfs_import () {
    IMPORT=$1
    local NFS_CONFIG_LINE=${!IMPORT}
    local NFS_CONFIG
    read -r -a NFS_CONFIG <<< "$NFS_CONFIG_LINE"
    local NFS_TYPE=${NFS_CONFIG[0]}
    local NFS_SERVER=${NFS_CONFIG[1]}
    local NFS_MOUNT=${NFS_CONFIG[2]}
    local NFS_OPTIONS=${NFS_CONFIG[3]}
    mount_nfs_import $NFS_TYPE $NFS_SERVER $NFS_MOUNT $NFS_OPTIONS
}

function init_imports () {
    local NFS_IMPORTS=$(compgen -A variable | grep -E 'NFS_[0-9]$' | sort)
    for IMPORT in $NFS_IMPORTS; do
        init_nfs_import $IMPORT
    done
}

trap 'stop_imports' SIGTERM SIGINT
init_imports

while true
do
  tail -f /dev/null & wait ${!}
done

exit 0
