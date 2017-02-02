#!/bin/sh
# See: https://github.com/phusion/baseimage-docker#running_startup_scripts
# http://phusion.github.io/baseimage-docker/#solution
# adds additional daemons (e.g. your own app) to the image by creating
# runit entries. You only have to write a small shell script which runs
# your daemon, and runit will keep it up and running for you,
# restarting it when it crashes, etc.
# The shell script must be called run, must be executable, and is to be placed
# in the directory /etc/service/<NAME>.


# Exit immediately if a command exits with a non-zero status.
set -e

#export LANG=C
export PATH=$PATH:"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TZ=Europe/Stockholm

cd /orientdb/bin
# change for dserver if need it
exec ./server.sh 2>&1
