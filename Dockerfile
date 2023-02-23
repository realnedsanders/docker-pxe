FROM docker.io/alpine:3.17.1

LABEL maintainer "ferrari.marco@gmail.com"

# Install the necessary packages
RUN apk add --no-cache \
  dnsmasq \
  wget

ENV MEMTEST_VERSION 5.31b
ENV TFTPBOOT_PATH /var/lib/tftpboot

WORKDIR /tmp
RUN \
  mkdir -p $TFTPBOOT_PATH \
  && (for i in ipxe.efi snponly.efi undionly.kpxe ipxe.pxe; do wget -O $TFTPBOOT_PATH/$i http://boot.ipxe.org/$i; done) \
  && wget -q http://www.memtest.org/download/archives/"$MEMTEST_VERSION"/memtest86+-"$MEMTEST_VERSION".bin.gz \
  && gzip -d memtest86+-"$MEMTEST_VERSION".bin.gz \
  && mkdir -p /var/lib/tftpboot/images \
  && mv memtest86+-$MEMTEST_VERSION.bin /var/lib/tftpboot/images/memtest86+

# Configure PXE and TFTP
COPY tftpboot/ /var/lib/tftpboot

# Configure DNSMASQ
COPY etc/ /etc

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.56.2,proxy"]
