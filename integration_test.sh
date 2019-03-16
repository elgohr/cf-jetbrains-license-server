#!/bin/sh
set -e

/home/jetbrains/entrypoint.sh &
sleep 30s
wget http://localhost:8111 2>&1 | grep Location | grep -q /login
echo "Server is registered. Everything ok!"