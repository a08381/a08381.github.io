#!/bin/bash

MIRAI_STABLE_VER=""

function get_mirai_version() {
    MIRAI_STABLE_VER=$(git tag | grep "^v[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+$" | sed -n '$p')
    echo "the latest version is $MIRAI_STABLE_VER"
}

function build_mirai() {
    git clone https://github.com/mamoe/mirai
    cd mirai
    curl https://a08381.github.io/patches/01_build.patch | git apply -
    git stash
    git checkout $MIRAI_STABLE_VER
    git stash apply
    chmod +x gradlew
    ./gradlew shadowJar
    git checkout .
    if [ -d "mirai-core-all/build/libs" ]; then
        cd mirai-core-all/build/libs
        ls *.jar | sed -r 's#mirai-core-all-(.*)-all.jar#mv & mirai-core-all-\1-without-bcprov.jar#' | bash
    fi
}

get_mirai_version
build_mirai
