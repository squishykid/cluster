FROM alpine

RUN mkdir -p /opt/os/boot /opt/os/root

ENV URL=https://downloads.raspberrypi.org/raspbian_lite/archive/2020-02-14-13:49

RUN wget ${URL}/boot.tar.xz -O- | tar -C /opt/os/boot -xJf -
RUN wget ${URL}/root.tar.xz -O- | tar -C /opt/os/root -xJf -
RUN apk --update --no-cache add bash dnsmasq nfs-utils
COPY entrypoint.sh /entrypoint.sh
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY exports /etc/exports

EXPOSE 53/tcp 53/tcp 67/udp \
    111 111/udp 2049 2049/udp \
    32765 32765/udp 32766 32766/udp \
    32767 32767/udp 32768 32768/udp

ENTRYPOINT ["/entrypoint.sh"]