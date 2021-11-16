#!/bin/bash

consul connect envoy \
  -register \
  -gateway mesh \
  -service "gateway-primary" \
  -address "172.20.20.11:9000" \
  -wan-address "172.20.20.11:9000" \
  -expose-servers \
  -- \
  -l trace
