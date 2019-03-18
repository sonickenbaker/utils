#!/bin/bash

shrink_size() {
    local count=""
    local -r skip_this=51200 # 51200*1024=50MB

    echo "[shrink-size] Removing apt cache"
    apt-get clean -y
    apt-get autoclean -y

    echo "[shrink-size] Removing temporary files"
    rm -rf /tmp/*

    echo "[shrink-size] Whiteout root"
    count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
    count=$(( count - skip_this )) # be sure to not saturate disk
    dd if=/dev/zero of=/tmp/whitespace bs=1024 count="$count"
    rm /tmp/whitespace
}
