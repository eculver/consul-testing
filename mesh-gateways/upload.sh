#!/bin/bash

# primary server config + startup script
vagrant upload primary-server-config.hcl /etc/consul.d/primary-server-config.hcl primary-server
vagrant upload run-primary-server.sh /home/vagrant/run-primary-server.sh primary-server

# primary gateway config + startup scripts
vagrant upload primary-gateway-config.hcl /etc/consul.d/primary-gateway-config.hcl primary-gateway
vagrant upload run-primary-gateway-agent.sh /home/vagrant/run-primary-gateway-agent.sh primary-gateway
vagrant upload run-primary-gateway-envoy.sh /home/vagrant/run-primary-gateway-envoy.sh primary-gateway

# primary services config + startup scripts
vagrant upload primary-services-agent-config.hcl /etc/consul.d/primary-services-agent-config.hcl primary-services
vagrant upload dashboard-service-config.hcl /etc/consul.d/dashboard-service-config.hcl primary-services
vagrant upload run-primary-services-agent.sh /home/vagrant/run-primary-services-agent.sh primary-services
vagrant upload run-primary-services-envoy.sh /home/vagrant/run-primary-services-envoy.sh primary-services

# secondary server config + startup script
vagrant upload secondary-server-config.hcl /etc/consul.d/secondary-server-config.hcl secondary-server
vagrant upload run-secondary-server.sh /home/vagrant/run-secondary-server.sh secondary-server

# secondary gateway config + startup script
vagrant upload secondary-gateway-config.hcl /etc/consul.d/secondary-gateway-config.hcl secondary-gateway
vagrant upload run-secondary-gateway-agent.sh /home/vagrant/run-secondary-gateway-agent.sh secondary-gateway
vagrant upload run-secondary-gateway-envoy.sh /home/vagrant/run-secondary-gateway-envoy.sh secondary-gateway

# secondary services config + startup scripts
vagrant upload secondary-services-agent-config.hcl /etc/consul.d/secondary-services-agent-config.hcl secondary-services
vagrant upload counting-service-config.hcl /etc/consul.d/counting-service-config.hcl secondary-services
vagrant upload run-secondary-services-agent.sh /home/vagrant/run-secondary-services-agent.sh secondary-services
vagrant upload run-secondary-services-envoy.sh /home/vagrant/run-secondary-services-envoy.sh secondary-services
