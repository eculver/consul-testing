#!/bin/bash

consul services register /etc/consul.d/counting-service-config.hcl
consul connect envoy -sidecar-for counting-1 -- -l trace
