#!/bin/bash

MIRAI_STABLE_VER=""
MIRAI_DEV_VER=""

function get_mirai_version() {
    MIRAI_STABLE_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version?stable=1")
    MIRAI_DEV_VER=$(curl -L "https://botapi.dead-war.cn/mirai/version?stable=0")
}

function build_mirai() {
    rm -rf mirai
    git clone https://github.com/mamoe/mirai
    cd mirai
    git checkout $MIRAI_STABLE_VER
    curl https://a08381.github.io/patches/01_build.patch | git apply -
    ./gradlew shadowJar
    if $MIRAI_STABLE_VER != $MIRAI_DEV_VER; then
        git checkout $MIRAI_DEV_VER
        ./gradlew shadowJar
    fi
    cd mirai-core-all/build/libs
    ls *.jar | sed -r 's#mirai-core-all-(.*)-all.jar#mv & mirai-core-all-\1-without-bcprov.jar#' | bash
    # rename 's/-all./-without-bcprov./' *.jar
    cd ../../../..
}

get_mirai_version
build_mirai
