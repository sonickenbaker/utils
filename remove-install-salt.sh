#!/bin/bash

remove_salt() {
    for service in "salt-master.service" "salt-minion.service" "salt-api.service"
      do
        systemctl stop "$service"
        systemctl disable "$service"
        rm /lib/systemd/system/"$service"
    done

    systemctl daemon-reload
    systemctl reset-failed

    cp /etc/salt/grains /tmp/grains_backup

    rm -rf /etc/salt
    rm -rf /var/cache/salt
    rm -rf usr/bin/salt-cloud
    rm -rf usr/bin/salt-run
    rm -rf usr/bin/salt-syndic
    rm -rf usr/bin/salt-call
    rm -rf usr/bin/salt-api
    rm -rf usr/bin/salt-ssh
    rm -rf usr/bin/salt-proxy
    rm -rf usr/bin/salt
    rm -rf usr/bin/salt-master
    rm -rf usr/bin/salt-minion
    rm -rf usr/bin/salt-unity
    rm -rf usr/bin/salt-cp
    rm -rf usr/bin/salt-key

    pip uninstall -y salt
}

install_salt(){
    local -r salt_version="$1"
    # re-install salt
    curl -L https://bootstrap.saltstack.com -o /tmp/saltstack_bootstrap.sh
    bash /tmp/saltstack_bootstrap.sh -M -X -F -P git v"$salt_version"

    echo "Configuring salt-master"
    sed -i '/#auto_accept: False/c\auto_accept: True' /etc/salt/master

    echo "Configuring salt-minion"
    echo "master: localhost" >> /etc/salt/minion

    mv /tmp/grains_backup /etc/salt/grains

    service salt-master restart
    service salt-minion restart
}

main() {
    local -r salt_version="${1}"
    if [ -z ${salt_version:+x} ]
    then
        echo "Salt version not specified"
        exit 1
    fi
    remove_salt
    install_salt "$salt_version"
}

main "$@"
