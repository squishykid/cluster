# bootstrap

Minimum collection of services to PXE/Netboot a Raspberry Pi via DHCP/TFTP and NFS

## Run this

`docker-compose up --build --force-recreate`

## Services

### dhcp

Dnsmasq DHCP server which serves the initial boot files (kernel, firmware, boot config etc)

This container must be able to receive broadcast UDP packets. This can be achieved by running the container in priveleged mode with host networking. This is spicy- beware.

#### Config

- SERVER_IP - IP address of the interface to bind to. Serve the spicy LAN-destroying DHCP packets out of one interface to limit the blast radius
- DHCP_RANGE- Bequeath some IPs upon your cluster. Choose some non-rfc1918 addresses if you are feeling adventurous.

### nfs

Userspace NFS3 file server which serves up the rest of the OS after the kernel boots.

Userspace NFS has a number of benefits, including:
- Not requiring the container to run in privileged mode
- Not requiring host netowrking
- Not nuking your dev box when the container goes tits-up
- Generally behaving more like a container should and less like a kernel config file in disguise

Downsides include it being a tad slower. However- `Make It Work Make It Right Make It Fast`.

#### Config

none

