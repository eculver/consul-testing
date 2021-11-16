datacenter = "secondary"

primary_datacenter = "primary"
primary_gateways = ["172.20.20.11:9000"]

verify_incoming = true
verify_outgoing = true
verify_server_hostname = true

ca_file = "/etc/ca-certificates/consul/consul-agent-ca.pem"
cert_file = "/etc/ca-certificates/consul/secondary-server-consul-0.pem"
key_file = "/etc/ca-certificates/consul/secondary-server-consul-0-key.pem"

acl {
  enabled = false    
}

connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}

auto_encrypt {
  allow_tls = true
}

config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"
      config {
        protocol = "http"
      }
    }
  ]
}

