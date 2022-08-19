# Multi-DC Mesh Federation

VM-based service mesh with multiple datacenters federated via Mesh Gateways.

This is still a WIP; it can use a lot more refinement

##_TODO_ 

- DRY: separate fixtures
- Add tool for composing fixtures into 


## Setup

### CA Files
The clusters must first have the CA data populated. From repository root run:
```
./populate-tls.sh mesh-gateways
```
This generates a new root CA and places the files in a path that the VMs will
be provisioned with (`/etc/ca-certificates/consul`). It then generates certificates
for all servers and copies them to the right paths.

### Enterprise License

When using Consul Enterprise, the license needs to be populated. From the repository
root, run:

```
./populate-license.sh mesh-gateways /path/to/license.txt
```
This will copy the license from `/path/to/license.txt` to a path that Vagrant
will then sync to the VMs when provisioning (`/etc/consul.d/license.hclic`). This
path is then referenced in the systemd unit's `EnvironmentFile` to set
`CONSUL_LICENSE_PATH` when the agent is started.

### Consul Version

By default, the VMs will download the latest version of Consul. The version can
be explicitly set using the `CONSUL_VERSION` environment variable:

```
CONSUL_VERSION=1.11.0+ent-beta3 vagrant up
```

### Start VMs

Once the CA data and (optionally) license is populated, the cluster can be
provisioned by running Vagrant:

```
vagrant up
```

All VMs should be provisioned and running at this point. Consul clients, servers and 
mesh gateways will all be started and mesh federation should be enabled. This
can be verified by logging into the servers and checking:

```
vagrant ssh primary-server
consul members -wan
```

From here, services just need to be registered and started to verify the
end-to-end flows. Details are below.

## Running Services

Try running some services that communicate across DCs. This will consist of
running the counting service in one DC and a dashboard service in the other. All
of the accompanying configs are populated when the services VMs are provisioned so
it's just a matter of registering them and starting them and their sidecars.

Configuration for the services is located in `/etc/demo` on both the `primary-services`
and `secondary-services` VMs.

### Configure Requests from Primary to Secondary

To run the dashboard in the primary and the counting service in the secondary,
do the following:


1. Setup counting service in secondary
```
vagrant ssh secondary-services
consul services register /etc/demo/counting-service-config.hcl
sudo systemctl enable counting-sidecar
sudo systemctl start counting-sidecar
sudo systemctl start counting
```

2. Setup dashboard in the primary
```
vagrant ssh primary-services
consul services register /etc/demo/dashboard-service-config-primary.hcl
sudo systemctl enable dashboard-sidecar
sudo systemctl start dashboard-sidecar
sudo systemctl start dashboard 
```

If everything is working, you should be able to navigate to the dashboard UI
at: http://172.20.20.12:9002

### Configure Requests from Primary to Secondary

To run the dashboard in the secondary and the counting service in the primary,
do the following:

1. Setup counting service in primary
```
vagrant ssh primary-services
consul services register /etc/demo/counting-service-config.hcl
sudo systemctl enable counting-sidecar
sudo systemctl start counting-sidecar
sudo systemctl start counting
```

2. Setup dashboard in the secondary
```
vagrant ssh secondary-services
consul services register /etc/demo/dashboard-service-config-primary.hcl
sudo systemctl enable dashboard-sidecar
sudo systemctl start dashboard-sidecar
sudo systemctl start dashboard 
```

If everything is working, you should be able to navigate to the dashboard UI
at: http://172.20.20.12:9002


## Troubleshooting

See note above. If you're still convinced you haven't failed as a human,
continue reading.

### Troubleshooting mesh gateway connection
_TODO_
- check Envoy config via admin interface


### Troubleshooting consul startup issues
_TODO_
