git submodule init
git submodule update

OS=`uname`

if [[ $OS == 'Linux' ]]; then
    PLAT="linux"
elif [[ $OS == 'Darwin' ]]; then
    PLAT="macosx"
else
    echo "unknown OS"
    exit 1
fi

# skynet
cd skynet && make clean && make ${PLAT} && cd -

# clibs
cd luaclib && cargo build --release
ln -s ./target/release/libjson.dylib ./bin/json.so
cd -