datacenter = "primary"
data_dir = "/opt/consul"
log_level = "TRACE"
server = true
bootstrap_expect = 1
bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"172.20.20.0/24\" | attr \"address\" }}"

verify_incoming = true
verify_outgoing = true
verify_server_hostname = true

use_streaming_backend = false

ca_file = "/etc/ca-certificates/consul/consul-agent-ca.pem"
cert_file = "/etc/ca-certificates/consul/primary-server-consul-0.pem"
key_file = "/etc/ca-certificates/consul/primary-server-consul-0-key.pem"

rpc {
  enable_streaming = false
}

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
      mesh_gateway {
        mode = "local"
      }
    },
    {
      kind = "terminating-gateway"
      name = "secondary-terminating-gateway"
      services = [
        {
          name = "counting"
        }
      ]
    }
  ]
}
