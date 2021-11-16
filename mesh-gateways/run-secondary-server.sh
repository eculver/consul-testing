#!/bin/bash

consul agent \
  -server \
  -datacenter secondary \
  -bind 172.20.20.20 \
  -data-dir /opt/consul \
  -log-level trace \
  -bootstrap-expect 1 \
  -config-file /etc/consul.d/secondary-server-config.hcl
