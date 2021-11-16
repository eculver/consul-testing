#!/bin/bash

consul services register /etc/consul.d/dashboard-service-config.hcl
consul connect envoy -sidecar-for dashboard -- -l trace
