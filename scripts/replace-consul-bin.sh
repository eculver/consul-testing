#!/bin/sh

set -euo pipefail

SCRIPT_HOME="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


function usage {
  echo "Usage: replace-consul-bin.sh [options] <path-to-consul-binary> <vm>"
  echo "Replaces the Consul binary inside a VM with the one given."
  echo ""
  echo "Example:"
  echo "./replace-consul-bin.sh ~/dev/src/github.com/hashicorp/consul/bin/consul ./mesh-gateways/primary-server"
  echo ""
  echo "Options:"
  echo "  -h, -help"
  echo "    Show usage information."
}

function main {
  local bin_path="${1:-}"
  local vm_path="${2:-}"
  local group
  local vm
  
  if [ -z "${bin_path}" ]; then
    echo "error: path to consul binary is required"
    usage
    exit 1
  fi
  if [ ! -f "${bin_path}" ]; then
    echo "error: ${bin_path} not found"
    exit 1
  fi
  if [ -z "${vm_path}" ]; then
    echo "error: VM directory is required"
    usage
    exit 1
  fi
  if [ ! -d "${vm_path}" ]; then
    echo "error: ${vm_path} VM directory not found"
    exit 1
  fi

  # we are about to change workdir so ensure it's an absolute path
  bin_path=$(realpath "${bin_path}")
  group="$(dirname "${vm_path}")"
  vm="$(basename "${vm_path}")"

  # in order to run Vagrant, we need to be in the context of a Vagrantfile
  if [ ! -f "${group}/Vagrantfile" ]; then
    echo "error: no Vagrantfile found in VM path given (${group})"
    exit 1
  fi
  pushd "${group}"

  # We have to stop Consul first in order to replace it so upload it and then
  # do all the remote commands at once so that we don't end up in a weird state
  # if the upload fails. It's also faster since there's only one SSH connection.
  vagrant upload "${bin_path}" /tmp/consul "${vm}"
  vagrant ssh -c "sudo systemctl stop consul; sudo mv /tmp/consul /usr/bin/consul; sudo systemctl start consul; sudo systemctl is-active consul || echo 'consul did not start'" "${vm}"
  popd
}

main "$@"
