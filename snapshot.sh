#!/bin/bash

case "$1" in
  "create" ) 
    KEY="-c";;
  "revert" ) 
    KEY="-a";;
  "list" ) 
    KEY="-l";;
  *) echo >&2 "Invalid option: $@"; exit 1;;
esac

for node in 1 2 3
do
  /opt/qemu/bin/qemu-img snapshot $KEY /opt/unetlab/tmp/0/63750953-43df-4294-b4b2-38dd6524ea9d/$node/virtioa.qcow2
done
