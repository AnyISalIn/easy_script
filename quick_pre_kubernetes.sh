#!/bin/bash


function pre_install {
    # curl my script,  run !
    curl -L https://raw.githubusercontent.com/AnyISalIn/easy_script/master/pre_kubernetes.sh | sh

    # install pip
    curl -L  http://112.64.137.178/get-pip.py|python
}


function py_pkg_install {
    pip install docker
}


function run_py_script {
    curl -L https://raw.githubusercontent.com/AnyISalIn/Python_Scripts/master/pull_local_image_and_tag.py|python
}

pre_install
py_pkg_install
run_py_script
