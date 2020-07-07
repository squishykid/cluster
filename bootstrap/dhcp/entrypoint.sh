#!/bin/bash

set -eux

SERVER_IP=${SERVER_IP}
DHCP_RANGE=${DHCP_RANGE}

echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/nfs \
	nfsroot=${SERVER_IP}:/opt/os/root,vers=3 rw ip=dhcp rootwait elevator=deadline" > /opt/os/boot/cmdline.txt

sed -i "s/{SERVER_IP}/${SERVER_IP}/" /etc/dnsmasq.conf
sed -i "s/{DHCP_RANGE}/${DHCP_RANGE}/" /etc/dnsmasq.conf

dnsmasq --no-daemon --user=dnsmasq --group=dnsmasq
