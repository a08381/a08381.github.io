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
    git checkout $MIRAI_STABLE_VER
    curl https://a08381.github.io/patches/01_build.patch | git apply -
    chmod +x gradlew
    ./gradlew shadowJar
    if [ $MIRAI_STABLE_VER != $MIRAI_DEV_VER ]; then
        git checkout $MIRAI_DEV_VER
        chmod +x gradlew
        ./gradlew shadowJar
    fi
    cd mirai-core-all/build/libs
    ls *.jar | sed -r 's#mirai-core-all-(.*)-all.jar#mv & mirai-core-all-\1-without-bcprov.jar#' | bash
    # rename 's/-all./-without-bcprov./' *.jar
    cd ../../../..
}

get_mirai_version
build_mirai
