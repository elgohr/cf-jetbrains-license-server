#!/bin/sh
set -e

/home/jetbrains/entrypoint.sh &

tries=0
while [ $tries -lt 60 ]
do
    status_code=$(wget --spider -S "http://localhost:8111/health" 2>&1 | grep "HTTP/" | awk '{print $2}')
    if [ "${status_code}" == "200" ] ; then
        echo "Server is registered. Everything ok!"
        exit 0
    fi

    echo "Health endpoint is returning error"
    wget -qO- --content-on-error http://localhost:8111/health || true
    echo " " # for new line

    tries=`expr $tries + 1`
    sleep 1s
done

echo "Server is not registered."
wget -qO- --content-on-error http://localhost:8111/health
exit 1
