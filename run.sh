export ROOT=$(cd `dirname $0`;pwd)
export DAEMON=false
export LOG_LEVEL=1 # 1: trace 2: debug 3: info 4: warn 5: error
export LOG_LOCATION=true

# kill skynet process
pid=$(cat skynet.pid);
if [[ $pid != "" ]]; then
   	kill -9 $pid
	while kill -0 "$pid" 2>/dev/null; do
	    sleep 0.1
	done
else
    echo "skynet is not running"
fi;

# parse options
while getopts ":d" opt; do
    case $opt in
        d)
            DAEMON=true
            ;;
        \?)
            echo "unknow option $opt"
            exit 1
            ;;
    esac
done

if [[ $DAEMON == true ]]; then
	nohup ./skynet/skynet conf.ini > skynet.log 2>&1 &
else
	./skynet/skynet conf.ini
fi