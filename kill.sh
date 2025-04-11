#!/bin/bash

if [[ -f skynet.pid ]]; then
	pid=$(cat skynet.pid)
	kill -9 "$pid" 2>/dev/null && rm -f skynet.pid
	echo "skynet is stopped"
else
	echo "skynet is not running"
fi
