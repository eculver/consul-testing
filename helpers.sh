#!/bin/bash

# helpers.sh is a collection of shell functions for managing test environments.
# Running `source helpers.sh` is all you need to do to use them.

# Necessary for finding our way back to the dependent configs
HELPERS_SH_HOME="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Cache for consul binaries so that we don't have to keep downloading them
CONSUL_BINS_HOME="${HELPERS_SH_HOME}/.consul-bins"

PRIMARY_DC=primary
SECONDARY_DC=secondary

# extracts all vm names from the associated Vagrantfile -- warning: this is a hack/throw-away
function _vm_names {
  local group="${1:-}"
  grep 'vm\.define' "${group}/Vagrantfile" | cut -d '"' -f2
}
# extracts all vms that are servers -- again, more hacky, throw-away code
function _server_vm_names {
  local group="${1:-}"
  _vm_names "${group}" | grep server
}

# extracts all vms that are not servers (thus clients) -- yep, more hacks.. on top of other hacks 
function _client_vm_names {
  local group="${1:-}"
  _vm_names "${group}" | grep -v server
}

# extracts all servers in primary DC

# extracts all 

# reloads systemd units on all VMs in the group
function vm_systemd_daemon_reload {
  local group="${1:-}"

  if [ -z "${group}" ]; then
    echo "error: group name is required"
    exit 1
  fi
  if [ ! -d "${group}" ]; then
    echo "error: group directory not found"
    exit 1
  fi

  pushd "${group}" > /dev/null
  for vm in $(_vm_names "."); do
    vagrant ssh -c "sudo systemctl daemon-reload" "${vm}"
  done
  popd > /dev/null
}

# Downloads a specific version of Consul to $CONSUL_BINS_HOME
function _download_consul {
  version="${1:-}"
  if [ -z "${version}" ]; then
    exit 1
  fi
  mkdir -p "${CONSUL_BINS_HOME}"
  bin_name="consul_${version}_linux_amd64"
  pkg_name="${bin_name}.zip"

  if [ ! -f "${CONSUL_BINS_HOME}/${bin_name}" ]; then
    echo "Fetching Consul version ${version} ..."
    pushd /tmp
    curl -s https://releases.hashicorp.com/consul/${version}/${pkg_name} -o consul.zip
    unzip consul.zip
    chmod +x consul
    mv consul "${CONSUL_BINS_HOME}/${bin_name}"
    popd
  fi
}

# Installs a specific version of consul to the given VM or group of VMs
function vm_install_consul {
  version="${1:-}"
  if [ -z "${version}" ]; then
    echo "error: version is required"
    echo
    echo "usage install_consul <version> <vm>..."
    exit 1
  fi

  # todo get VMs from args

  _download_consul "${version}"
  
  echo "Installing Consul ${version} to ... (todo)"
 
  # this is a pain to make work with vm args and vagrant from this top-level dir.. especially in bash
  # need to invent some way of resolving vm paths/names (eg. mesh-gateway/primary-server, group/name)
  # while also keeping the context of vagrant so we can do vagrant upload ...
  # I guess it's the thought that counts, might bail on this helpers idea...
}
