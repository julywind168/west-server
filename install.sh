#!/bin/bash
OS=`uname`

if [[ $OS == 'Linux' ]]; then
    PLAT="linux"
elif [[ $OS == 'Darwin' ]]; then
    PLAT="macosx"
else
    echo "unknown OS"
    exit 1
fi

# do action
action=$1

if [ "$action" = "skynet" ]; then
    git submodule init
    git submodule update
    cd skynet && make clean && make ${PLAT} && cd -
    echo "done"
elif [ "$action" = "libs" ]; then
    cd luaclib
    cargo build --release
    cd bin
    ln -sf ../target/release/libjson.dylib ./json.so
    ln -sf ../target/release/libuuid.dylib ./uuid.so
    cd ../..
    echo "done"
else
    echo "Usage: $0 {skynet|libs}"
    exit 1
fi