#!/bin/sh
set -e

/home/jetbrains/entrypoint.sh &

tries=0
while [ $tries -lt 60 ]
do
    if wget http://localhost:8111 2>&1 | grep Location | grep -q /login ; then
        echo "Server is registered. Everything ok!"
        exit 0
    fi
    tries=`expr $tries + 1`
    sleep 1s
done

echo "Server is not registered."
exit 1
