#!/bin/bash

consul agent \
  -bind 172.20.20.21 \
  -retry-join 172.20.20.20 \
  -grpc-port 8502 \
  -log-level trace \
  -data-dir /opt/consul \
  -config-file /etc/consul.d/secondary-gateway-config.hcl
