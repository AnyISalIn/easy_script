#!/bin/bash
#
# vaneq initialize script


widgets-dir='/tmp/widgets'
service-catalogs_dir='/tmp/service-catalog'
reports-dir='/tmp/reports'

function db_status_test {
  nc localhost 5432 &> /dev/null || (echo 'Sorry, Database Connection refused !!!!'; exit)
}

function import {
  for item in widgets service_catalogs reports; do
    miqimport $item `echo $item-dir` && echo "$item Import Success" || echo "$item Import Failed"
}

db_status_test
import
