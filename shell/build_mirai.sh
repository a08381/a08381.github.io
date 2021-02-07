#!/bin/bash

MIRAI_STABLE_VER=""
MIRAI_DEV_VER=""

function get_mirai_version() {
    MIRAI_STABLE_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version/stable")
    MIRAI_DEV_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version/dev")
}

function build_mirai() {
    rm -rf mirai
    HTTP_PROXY=http://192.168.0.2:8080 HTTPS_PROXY=http://192.168.0.2:8080 git clone https://github.com/mamoe/mirai
    cd mirai
    curl https://a08381.github.io/patches/01_build.patch | git apply -
    if [ -e "mirai_files/mirai-core-all-${MIRAI_STABLE_VER}-without-bcprov.jar" ]; then
        git checkout $MIRAI_STABLE_VER
        chmod +x gradlew
        ./gradlew shadowJar
    fi
        git checkout $MIRAI_DEV_VER
        chmod +x gradlew
        ./gradlew shadowJar
    cd mirai-core-all/build/libs
    ls *.jar | sed -r 's#mirai-core-all-(.*)-all.jar#mv & mirai-core-all-\1-without-bcprov.jar#' | bash
    # rename 's/-all./-without-bcprov./' *.jar
    cd ../../../..
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
    find mirai/mirai-core-all/build/libs -name "mirai-core-all-*-without-bcprov.jar" -a ! -name "*dev*" -exec cp {} mirai_files/stable/
    find mirai/mirai-core-all/build/libs -name "mirai-core-all-*-without-bcprov.jar" -a -name "*dev*" -exec cp {} mirai_files/dev/
}

get_mirai_version
build_mirai
copy_file
