#!/bin/bash
# this is kubernetes and deis pre config script

# install docker-engine via offical script

function install_docker {
    curl -sSL https://get.daocloud.io/docker | sh
}

function pre_docker {
    curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://c2c14f16.m.daocloud.io
    grep -o  harbor /lib/systemd/system/docker.service
    if [[ $? -gt 0 ]]; then
      sed -i '11s/$/   --insecure-registry harbor.vanecloud.com/g' /lib/systemd/system/docker.service
    fi
    systemctl daemon-reload
    systemctl restart docker
}

install_docker
pre_docker
