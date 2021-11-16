#!/bin/bash

consul connect envoy \
  -register \
  -gateway mesh \
  -service "gateway-secondary" \
  -address "172.20.20.21:9000" \
  -wan-address "172.20.20.21:9000" \
  -expose-servers \
  -- \
  -l trace
