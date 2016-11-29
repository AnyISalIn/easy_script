#!/bin/bash

### update github to gitlab
directory=(
'/repodb/github/vaneq'
'/repodb/github/vaneqStatic'
)

function pull_github {
  git pull origin
}

function push_gitlab {
  git push gitlab
}


function run {
  for i in ${directory[*]};do
    cd $i && pull_github && push_gitlab
  done
}

run
