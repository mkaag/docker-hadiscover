#!/usr/bin/env bash
set -e

HADISCOVER="/opt/hadiscover/bin/hadiscover"
HAPROXY="/usr/sbin/haproxy"
CONFIG_TMPL="{CONFIG_TMPL:-/etc/haproxy/haproxy.cfg.tpl}"
ETCD_ENDPOINT="{ETCD_ENDPOINT:-http://172.17.42.1:4001}"
ETCD_KEY="${ETCD_KEY:-services}"

${HADISCOVER} --config ${CONFIG_TMPL} --etcd ${ETCD_ENDPOINT} --ha ${HAPROXY} --key ${ETCD_KEY}

