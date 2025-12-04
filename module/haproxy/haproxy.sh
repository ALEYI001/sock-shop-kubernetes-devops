#!/bin/bash
set -e

apt-get update -y
apt-get upgrade -y

apt-get install -y --no-install-recommends software-properties-common
add-apt-repository ppa:vbernat/haproxy-2.4 -y
apt-get update -y
apt-get install -y haproxy=2.4.*

cat <<CONFIG > /etc/haproxy/haproxy.cfg
frontend fe-apiserver
    bind 0.0.0.0:6443
    mode tcp
    option tcplog
    default_backend be-apiserver

backend be-apiserver
    mode tcp
    option tcplog
    option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

    server master1 ${master_ip_1}:6443 check
    server master2 ${master_ip_2}:6443 check
    server master3 ${master_ip_3}:6443 check
CONFIG

systemctl restart haproxy
systemctl enable haproxy

hostnamectl set-hostname ha-lb-$(hostname | tail -c 2)

