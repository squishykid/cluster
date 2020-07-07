FROM alpine

RUN mkdir -p /opt/os/boot

ENV URL=https://downloads.raspberrypi.org/raspbian_lite/archive/2020-02-14-13:49

RUN wget ${URL}/boot.tar.xz -O- | tar -C /opt/os/boot -xJf -
RUN apk --update --no-cache add dnsmasq bash
COPY entrypoint.sh /entrypoint.sh
COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 53/tcp 53/tcp 67/udp

ENTRYPOINT ["/entrypoint.sh"]