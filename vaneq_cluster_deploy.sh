#!/bin/bash
#
# vaneq cluster build script

nodes=('192.168.10.101' '192.168.10.202')
ask "please input master node ipaddress" master_node
APP_ROOT='/var/www/miq/vmdb'
function ask {
  description=$1
  variable=$2
  read -p ${description} ${variable}
}

function log {
  level=$1
  info=$2
  echo "${level}: ${info}"
}

function connect_test {
  [ -x ${nodes[*]} ] || ( echo 'please input node'; exit 1 )
  for node in ${nodes[*]}; do
    ping  -W 3  -c 4  ${node} > /dev/null
    if [[ $? -eq 0 ]]; then
      log INFO "${node} is active"
    else;
      log ERROR "${node} is inactive"
      break
    fi
  done
}

function ssh_trust {
  ssh-keygen -t rsa -P '' -f ~/.ssh/vaneq_rsa
  log INFO "Please input localhost password"
  ssh-copy-id ~/.ssh/id_rsa localhost 2> /dev/null
  if [[ $? -eq 0 ]]; then
     for node in ${nodes[*]}; do
       log INFO "Please input ${node} password"
       scp ~/.ssh/{authorized_keys,id_rsa} $node:~/.ssh/
       if [[ $? -eq 0 ]]; then
         log INFO "${node} ssh trust!"
       else;
         log ERROR "${node} ssh untrust!"
         break
       fi
      done
  else;
    log ERROR "wrong password"
  fi
}

function sync_key {
  for node in ${nodes}; do
    scp ${APP_ROOT}/certs/* node:${APP_ROOT}/certs
    if [[ $? -eq 0 ]]; then
      log INFO "${node} sync success"
    else;
      log ERROR "${node} sync failed, please check network or ssh trust"
    fi
  done
}

function decrypt_key {
  pass
}

function sync_database_config {
  pass
}

function start_evmserver {
  pass
}
