FROM phusion/baseimage:latest

MAINTAINER Maurice Kaag <mkaag@me.com>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
# Workaround initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

# Workaround initscripts trying to mess with /dev/shm: <https://bugs.launchpad.net/launchpad/+bug/974584>
# Used by our `src/ischroot` binary to behave in our custom way, to always say we are in a chroot.
ENV FAKE_CHROOT 1
RUN mv /usr/bin/ischroot /usr/bin/ischroot.original
ADD build/ischroot /usr/bin/ischroot

# Configure no init scripts to run on package updates.
ADD build/policy-rc.d /usr/sbin/policy-rc.d

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Haproxy Installation
RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
    apt-get update -qqy; \
    apt-get install -qqy \
        haproxy \
        golang-go \
        git

WORKDIR /opt
RUN \
    mkdir hadiscover; cd hadiscover; \
    export GOPATH=`pwd`; \
    go get github.com/adetante/hadiscover

RUN sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy
ADD build/haproxy.cfg.tpl /etc/haproxy/haproxy.cfg.tpl

RUN mkdir /etc/service/hadiscover
ADD build/hadiscover.sh /etc/service/hadiscover/run
RUN chmod +x /etc/service/hadiscover/run

EXPOSE 80
# End Haproxy

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
