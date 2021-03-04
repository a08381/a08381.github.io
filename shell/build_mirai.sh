#!/bin/bash

MIRAI_STABLE_VER=""
MIRAI_DEV_VER=""

function get_mirai_version() {
    MIRAI_STABLE_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version/stable")
    MIRAI_DEV_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version/dev")
}

function build_mirai() {
    rm -rf mirai
    git clone https://github.com.cnpmjs.org/mamoe/mirai
    cd mirai
    curl https://a08381.github.io/patches/01_build.patch | git apply -
    git stash
    git checkout $MIRAI_STABLE_VER
    git stash apply
    chmod +x gradlew
    ./gradlew shadowJar
    git checkout .
    git checkout $MIRAI_DEV_VER
    git stash apply
    chmod +x gradlew
    ./gradlew shadowJar
    git stash clear
    if [ -d "mirai-core-all/build/libs" ]; then
        cd mirai-core-all/build/libs
        ls *.jar | sed -r 's#mirai-core-all-(.*)-all.jar#mv & mirai-core-all-\1-without-bcprov.jar#' | bash
        cd ../../../..
    else
        cd ..
    fi
}

function copy_file() {
    if [ ! -d "mirai_files" ]; then
        mkdir mirai_files
    fi
    if [ ! -d "mirai_files/stable" ]; then
        mkdir mirai_files/stable
    fi
    if [ ! -d "mirai_files/dev" ]; then
        mkdir mirai_files/dev
    fi
    ls mirai/mirai-core-all/build/libs/ | grep dev | sed -r 's#mirai-core-all-(.*)-without-bcprov.jar#cp mirai/mirai-core-all/build/libs/& mirai_files/dev/#' | bash
    ls mirai/mirai-core-all/build/libs/ | grep -v dev | sed -r 's#mirai-core-all-(.*)-without-bcprov.jar#cp mirai/mirai-core-all/build/libs/& mirai_files/stable/#' | bash
}

get_mirai_version
build_mirai
# copy_file
