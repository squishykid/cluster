#!/bin/bash

set -eux

SERVER_IP=${SERVER_IP}
DHCP_RANGE=${DHCP_RANGE}

echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/nfs \
	nfsroot=${SERVER_IP}:/share/root,vers=3 rw ip=dhcp rootwait elevator=deadline" > /opt/os/boot/cmdline.txt

echo "proc                           /proc           proc    defaults          0       0
"${SERVER_IP}":/nfsshare/boot   /boot           nfs     defaults          0       0" > /opt/os/root/etc/fstab

sed -i "s/{SERVER_IP}/${SERVER_IP}/" /etc/dnsmasq.conf
sed -i "s/{DHCP_RANGE}/${DHCP_RANGE}/" /etc/dnsmasq.conf

cat /opt/os/boot/cmdline.txt
cat /etc/dnsmasq.conf
cat /opt/os/root/etc/fstab

ls -la /share
cp -ar /opt/os/* /share
ls -la /share

dnsmasq --no-daemon --user=dnsmasq --group=dnsmasq &

#nfs things
trap "stop; exit 0;" SIGTERM SIGINT

stop()
{
  # We're here because we've seen SIGTERM, likely via a Docker stop command or similar
  # Let's shutdown cleanly
  echo "SIGTERM caught, terminating NFS process(es)..."
  /usr/sbin/exportfs -ua
  pid1=$(pidof rpc.nfsd)
  pid2=$(pidof rpc.mountd)
  kill -TERM $pid1 $pid2 > /dev/null 2>&1
  echo "Terminated."
  exit
}

echo 'fs.nfs.nlm_tcpport=32768' >> /etc/sysctl.conf
echo 'fs.nfs.nlm_udpport=32768' >> /etc/sysctl.conf
sysctl -p > /dev/null

mount -t nfsd nfds /proc/fs/nfsd

rpcbind -w
rpc.nfsd -N 2 -V 3 -N 4 -N 4.1 8
exportfs -arfv

rpc.statd -p 32765 -o 32766
rpc.mountd -N 2 -V 3 -N 4 -N 4.1 -p 32767 -F