#!/bin/bash

export ROOT=$(cd "$(dirname "$0")"; pwd)
export LOG_LEVEL=1 # 1: trace 2: debug 3: info 4: warn 5: error
export DAEMON=false
export LOG_LOCATION=true

# Stop skynet process
if [[ -f skynet.pid ]]; then
    pid=$(cat skynet.pid)
    kill -9 "$pid" && rm -f skynet.pid
    echo "skynet is stopped"
fi

# Parse options
while getopts ":d" opt; do
    [[ $opt == "d" ]] && DAEMON=true || { echo "unknown option $opt"; exit 1; }
done

# Start skynet
if $DAEMON; then
    nohup ./skynet/skynet conf.ini > skynet.log 2>&1 &
    echo "skynet is started"
else
    ./skynet/skynet conf.ini
fi
