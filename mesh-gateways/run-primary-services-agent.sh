#!/bin/bash

consul agent \
  -datacenter primary \
  -bind 172.20.20.12 \
  -retry-join 172.20.20.10 \
  -grpc-port 8502 \
  -log-level trace \
  -data-dir /opt/consul \
  -config-file /etc/consul.d/primary-services-agent-config.hcl
