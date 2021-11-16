#!/bin/bash

consul agent \
  -server \
  -bind 172.20.20.10 \
  -data-dir /opt/consul \
  -log-level trace \
  -bootstrap-expect 1 \
  -config-file /etc/consul.d/primary-server-config.hcl
