export ROOT=$(cd `dirname $0`;pwd)
export DAEMON=false
export LOG_LEVEL=1 # 1: trace 2: debug 3: info 4: warn 5: error
export LOG_COLOR=true
export LOG_LOCATION=true

./skynet/skynet conf.ini