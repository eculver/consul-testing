datacenter = "primary"
data_dir = "/opt/consul"
log_level = "TRACE"
client_addr = "0.0.0.0"
bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"172.20.20.0/24\" | attr \"address\" }}"
retry_join = [ "172.20.20.10" ]

verify_incoming = true
verify_outgoing = true
verify_server_hostname = true

ca_file = "/etc/ca-certificates/consul/consul-agent-ca.pem"

ports {
  grpc = 8502
}

auto_encrypt {
  tls = true
}
