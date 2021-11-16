#!/bin/bash

consul agent \
  -datacenter secondary \
  -bind 172.20.20.22 \
  -retry-join 172.20.20.20 \
  -grpc-port 8502 \
  -log-level trace \
  -data-dir /opt/consul \
  -config-file /etc/consul.d/secondary-services-agent-config.hcl
