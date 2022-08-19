#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# where license file will live on VMs
VM_CONSUL_ENVIRONMENT_FILE=/etc/consul.d/consul.env
VM_CONSUL_LICENSE_PATH=/etc/consul.d/license.hclic

source $SCRIPT_DIR/helpers.sh

function usage {
  echo "Usage: populate-license.sh <group> <local-license-path>"
  echo "Populates Consul Enterpise license to environment file where systemd will be looking for it."
}

function main {
  local group="${1:-}"
  local license_path="${2:-}"

  if [ -z "${group}" ]; then
    echo "error: group name is required"
    exit 1
  fi
  if [ ! -d "${group}" ]; then
    echo "error: ${group} directory not found"
    exit 1
  fi
  if [ -z "${license_path}" ]; then
    echo "error: local license file path is required"
    exit 1
  fi
  if [ ! -f "${license_path}" ]; then
    echo "error: ${license_path} not found"
    exit 1
  fi

  # all VMs get the same license file
  for s in $(_vm_names "${group}"); do
    if [ ! -f "${group}/${s}/$VM_CONSUL_LICENSE_PATH" ]; then
      echo "populating license file for $s"
      cp ${license_path} "${group}/${s}/${VM_CONSUL_LICENSE_PATH}"
    fi
    if [ ! -f "${group}/${s}/$VM_CONSUL_ENVIRONMENT_FILE" ]; then
      touch "${group}/${s}/$VM_CONSUL_ENVIRONMENT_FILE"
    fi
    if [ ! $(grep -q CONSUL_LICENSE_PATH "${group}/${s}/$VM_CONSUL_ENVIRONMENT_FILE") ]; then
      echo "CONSUL_LICENSE_PATH=/etc/consul.d/license.hclic" > "${group}/${s}/$VM_CONSUL_ENVIRONMENT_FILE"
    fi
  done
}

main "$@"
