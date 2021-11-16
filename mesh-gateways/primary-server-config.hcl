datacenter = "primary"

verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
ca_file = "/etc/ca-certificates/consul/consul-agent-ca.pem"
cert_file = "/etc/ca-certificates/consul/primary-server-consul-0.pem"
key_file = "/etc/ca-certificates/consul/primary-server-consul-0-key.pem"

acl = {
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

