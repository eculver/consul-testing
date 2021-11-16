# Multi-DC Mesh Federation

VM-based service mesh with multiple datacenters federated via Mesh Gateways.

This is still a WIP so it could use a lot more refinement

##_TODO_ 

- refactor to use systemd units
- populate systemd units at provisioning step
- make it easier to install a dev version of consul
- add troubleshooting guide

## Setup

```
vagrant up
./populate-tls.sh
./upload.sh
```

All VMs should be configured at this point. Everything just needs to be started
and then services registered with Consul for everything to come to life.

## Run everything in a million terminal windows
Until this is reconfigured to use systemd or proper startup scripts, this is
going to involve a lot of terminals so buckle up:

### 1. Start the server on primary DC server VM:
```
vagrant ssh primary-server
sudo ./run-primary-server.sh
```

### 2. Start the agent on the primary DC gateway VM:
```
vagrant ssh primary-gateway
sudo ./run-primary-gateway-agent.sh
```

### 3. Start Envoy on the primary DC gateway VM:
```
vagrant ssh primary-gateway
sudo ./run-primary-gateway-envoy.sh
```

### 4. Start the server on the secondary DC server VM:
```
vagrant ssh secondary-server
sudo ./run-secondary-server.sh
```

### 5. Start the agent on the secondary DC gateway VM:
```
vagrant ssh primary-gateway
sudo ./run-primary-gateway-envoy.sh
```

### 6. Start Envoy on the secondary DC gateway VM:
```
vagrant ssh primary-gateway
sudo ./run-primary-gateway-envoy.sh
```

At this point the cluster and mesh federation should be set up.

Try running some services that communicate across DCs. This will consist of
running the counting service in the secondary DC that backs a dashboard service
running in the primary DC. Each will run on a separate VM and communicate
through a local Envoy sidecar.

### 7. Start the consul client on the primary DC services VM:
```
vagrant ssh primary-services
sudo ./run-primary-services-agent.sh
```

### 8. Start the consul client on the secondary DC services VM:
```
vagrant ssh secondary-services
sudo ./run-secondary-services-agent.sh
```

### 9. Register the counting service and start its sidecar on the secondary DC services VM:
```
vagrant ssh secondary-services
./run-secondary-services-envoy.sh
```

### 10. Start the counting service on the secondary DC services VM:
```
vagrant ssh secondary-services
PORT=9003 counting-service
```

### 11. Register the dashboard service and start its sidecar on the primary DC services VM:
```
vagrant ssh primary-services
./run-primary-services-envoy.sh
```

### 12. Start the dashboard service on the primary DC services VM:
```
vagrant ssh primary-services
PORT=9002 COUNTING_SERVICE_URL="http://localhost:5000" dashboard-service
```

If everything is working, you should be able to navigate to the dashboard UI
at: http://172.20.20.12:9002

If it's not working, then go to https://flights.google.com, book a flight to
Nepal and then immediately throw your computer in the trash and head to the
airport because you have failed as a human being and you need to reconsider the
meaning of life as a monk in Nepal.

## Troubleshooting

See note above. If you're still convinced you haven't failed as a human,
continue reading.

### Troubleshooting mesh gateway connection
_TODO_
- check Envoy config via admin interface


### Troubleshooting consul startup issues
_TODO_
