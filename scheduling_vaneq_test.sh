#!/bin/bash

# Jenkins Scheduler VaneQ Update and Test Script


function update_vaneq {
    pushd /var/www/miq/vmdb
        systemctl stop evmserverd &> /dev/null || exit 1
        md5=`md5sum Gemfile|awk  '{print $1}'`
        git pull origin darga-vaneq || exit 1
        after_update_md5=`md5sum Gemfile|awk  '{print $1}'`
        if [[ ${md5} != ${after_update_md5} ]]; then
            echo -e 'gem file MD5 change, update gems\n'
            bundle update &> /dev/null || exit 1
        fi
        systemctl start evmserverd &> /dev/null || exit 1
    popd
}


function run_test {
    pushd /opt/manageiq/test_vaneq_api
        rake test
    popd
}


function api_state {
    while true; do
        ss -tanlp|grep 8080 -q
        if [ $? -eq 0 ]; then
            echo -e 'Found API Port\n'
            break
        else
            sleep 10
            continue
        fi
    done
}

source /etc/profile.d/evm.sh
update_vaneq || exit 1
sleep 60
api_state || exit 1
run_test || exit 1
