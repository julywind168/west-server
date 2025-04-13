#!/bin/bash

export ROOT=$(cd "$(dirname "$0")"; pwd)
export DAEMON=false
export DISTRIBUTED=false 
export NODE_NAME=""
export THREAD=4

export LOG_LEVEL=1 # 1: trace 2: debug 3: info 4: warn 5: error
export LOG_LOCATION=true

# Stop skynet process
if [[ -f skynet.pid ]]; then
    pid=$(cat skynet.pid)
    kill -9 "$pid" && rm -f skynet.pid
    echo "skynet is stopped"
fi

usage() {
  echo "usage: $0 [-t thread_num] [-d]"
  echo "eg:"
  echo "  $0 -t 8 -d"
  exit 1
}

# Parse options
while getopts ":n:t:d:h" opt; do
    case $opt in
        n)
            DISTRIBUTED=true
            NODE_NAME=$OPTARG
            ;;
        t)
            if ! [[ $OPTARG =~ ^[1-9]+$ ]]; then
                echo "error: invalid thread num $OPTARG" >&2
                usage
            fi
            THREAD=$OPTARG
            ;;
        d)
            DAEMON=true
            ;;
        h)
            usage
            ;;
        \?)
            echo "unknow option $opt"
            usage
            ;;
    esac
done

# Start skynet
if $DAEMON; then
    nohup ./skynet/skynet conf.ini > skynet.log 2>&1 &
    echo "skynet is started"
else
    ./skynet/skynet conf.ini
fi
