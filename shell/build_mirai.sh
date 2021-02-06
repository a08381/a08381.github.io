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
    wget https://a08381.github.io/patches/01_build.patch
    git checkout $MIRAI_STABLE_VER
    patch mirai-core-all/build.gradle.kts < 01_build.patch
    ./gradlew shadowJar
    git checkout $MIRAI_DEV_VER
    ./gradlew shadowJar
    cd mirai-core-all/build/libs
    rename 's/-all./-without-bcprov./' *.jar
    cd ../../../..
}

get_mirai_version
build_mirai