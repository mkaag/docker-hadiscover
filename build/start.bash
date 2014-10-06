#!/bin/bash

#
# start.bash
#

HAPROXY="/etc/haproxy"
OVERRIDE="/haproxy-override"
PIDFILE="/var/run/haproxy.pid"

CONFIG="haproxy.cfg"
ERRORS="errors"

cd "$HAPROXY"

# Symlink errors directory
if [[ -d "$OVERRIDE/$ERRORS" ]]; then
  mkdir -p "$OVERRIDE/$ERRORS"
  rm -fr "$ERRORS"
  ln -s "$OVERRIDE/$ERRORS" "$ERRORS"
fi

# Symlink config file.
if [[ -f "$OVERRIDE/$CONFIG" ]]; then
  rm -f "$CONFIG"
  ln -s "$OVERRIDE/$CONFIG" "$CONFIG"
fi

# Set backend IP address to machine's private IP address
PRIVATE_IPV4=$(curl -sw "\n" http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
sed -i -e "s/server nginx private_ipv4:80 check/server nginx ${PRIVATE_IPV4}:80 check/g" $HAPROXY/$CONFIG

haproxy -f /etc/haproxy/haproxy.cfg -p "$PIDFILE"
