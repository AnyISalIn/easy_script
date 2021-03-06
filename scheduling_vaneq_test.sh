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


function db_setup_and_restore {
    pushd /var/www/miq/vmdb
        export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
        rake db:setup > /dev/null
        if [ $? -eq 0 ]; then
            ps -ef|grep MIQ|grep -v grep|awk -F' ' '{print $2}'|xargs kill -9
            rake evm:db:restore:local -- --local-file /opt/manageiq/test_vaneq_api/test.sql
        fi
    popd
}

source /etc/profile.d/evm.sh
update_vaneq || exit 1
sleep 60
api_state || exit 1
run_test || exit 1
db_setup_and_restore || exit 1
rm -rf {.*,*}
exit 0
