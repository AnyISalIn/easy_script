#!/bin/bash
#
# vaneq cluster build script

nodes=('192.168.10.101' '192.168.10.202')
read -p 'please input master node ipaddress : ' master_node
APP_ROOT='/var/www/miq/vmdb'

function log {
  level=$1
  info=$2
  echo "${level}: ${info}"
}

function run_test {
  if [[ $? -eq 0 ]]; then
    log INFO $1
  else
    log ERROR $2
    exec $3
  fi
}

function connect_test {
  [ -x ${nodes[*]} ] || ( echo 'please input node'; exit 1 )
  for node in ${nodes[*]}; do
    ping  -W 3  -c 4  ${node} > /dev/null
    run_test "${node} is active" "${node} is inactive" "break"
  done
}

function ssh_trust {
  ssh-keygen -t rsa -P '' -f ~/.ssh/vaneq_rsa
  log INFO "Please input localhost password"
  ssh-copy-id ~/.ssh/id_rsa localhost 2> /dev/null
  if [[ $? -eq 0 ]]; then
     for node in ${nodes[*]}; do
       log INFO "Please input ${node} password"
       scp ~/.ssh/{authorized_keys,vaneq_rsa} $node:~/.ssh/
       run_test "${node} ssh trust!" "${node} ssh untrust!" "break"
      done
  else
    log ERROR "wrong password"
  fi
}

function sync_key {
  for node in ${nodes}; do
    scp ${APP_ROOT}/certs/* node:${APP_ROOT}/certs/
    run_test "${node} sync success" "${node} sync failed, please check network or ssh trust" "break"
  done
}

function encrypt {
  cd ${APP_ROOT}
  ENCRYPT_PG_PASSWORD=$(echo "require 'util/miq-password'; MiqPassword.encrypt('smartvm')" |rails c|grep 'v2.*}' -o)
  sed "24a\ \ \host: ${master_node}"  config/database.yml | \
  sed "25a\ \ \password: ${ENCRYPT_PG_PASSWORD}" > /tmp/tmp_db.settings
  run_test "Encrypt Database Config File Generate!" "Encrypt Database Config File Generate Failed!" "exit 1"
}

function sync_database_config {
  cd ${APP_ROOT}
  for node in ${nodes}; do
    scp /tmp/tmp_db.settings ${node}:${APP_ROOT}/config/
    run_test "${node} Database Config File Copy Success!" "${node} Database Config File Copy Failed!" "break"
  done
  rm -rf /tmp/tmp_db.settings
}

function start_evmserver {
  for node in ${nodes}; do
    ssh ${node} -- systemctl restart evmserverd
    run_test "${node} EVM Server Started Success!" "${node} EVM Server Started Failed!" "continue"
  done
}

for fun in connect_test ssh_trust sync_key encrypt sync_database_config start_evmserver; do
    exec $fun || echo 'failed'
done
