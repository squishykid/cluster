FROM alpine

RUN mkdir -p /opt/os/boot /opt/os/root

ENV URL=https://downloads.raspberrypi.org/raspbian_lite/archive/2020-02-14-13:49

RUN wget ${URL}/boot.tar.xz -O- | tar -C /opt/os/boot -xJf -
RUN wget ${URL}/root.tar.xz -O- | tar -C /opt/os/root -xJf -
RUN apk --update --no-cache add bash unfs3
COPY entrypoint.sh /entrypoint.sh
COPY exports /etc/exports

EXPOSE 111/udp 111/tcp 2049/tcp 2049/udp

ENTRYPOINT ["/entrypoint.sh"]