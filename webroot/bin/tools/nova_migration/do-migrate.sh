#!/bin/sh
# jilw1@lenovo.com
# This script is to migrate vms from a designated hypervisor, provide by 1st parameter
# Thisiscript will be invoked by uus, when ras migration occurs, in RASEngine.py
. /root/openrc;nova host-servers-migrate $1
