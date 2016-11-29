#!/bin/bash

## upadte code script
function update_frontend {
   cd /opt/manageiq/vaneq_static
   git pull && node build/build.js
   [[ $? -eq 0 ]] && return 0 || return 1
}

function update_vaneq {
  cd /var/www/miq/vmdb
  git pull && bundle exec rake evm:restart
  [[ $? -eq 0 ]] && return 0 || return 1
}

function print_log {
    echo "INFO: $(date +%F-%H:%M) update $1 $(ip a|grep eth0|grep 'inet\>'|awk -F' ' '{print $2}') code ${status}" >> /var/log/vaneq_update_script.log
}

function run {
  for i in update_vaneq update_frontend;do
    $i && status='success' || status='failed'
    print_log $i
  done
}

run
