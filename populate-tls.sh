#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# path to consul binary, points to source repo so that we're using a dev build
CONSUL_BIN=$SCRIPT_DIR/../consul/bin/consul

PRIMARY_DC=primary
SECONDARY_DC=secondary

# just the file names, dirname will be prepended upon distributing to VM paths,
# these match the Consul defaults based on our inputs to `consul tls ...`.
CA_FILE=consul-agent-ca.pem
CA_KEY_FILE=consul-agent-ca-key.pem
CERT_FILE_SUFFIX=-consul-0.pem
KEY_FILE_SUFFIX=-consul-0-key.pem

# where all certs will live on VMs, must match sync'd path in Vagrantfile
VM_CA_ROOT=/etc/ca-certificates/consul

source $SCRIPT_DIR/helpers.sh

function usage {
  echo "Usage: populate-tls.sh [options] <group>"
  echo "Generates Consul CA certs to all the right places."
  echo "Existing certs will be used unless the -g/-generate flag is given."
  echo ""
  echo "populate-tls.sh"
  echo ""
  echo "Options:"
  echo "  -g, -generate"
  echo "    Always generate new keys and certificates."
  echo "  -h, -help"
  echo "    Show usage information."
}

function main {
  # TODO: support flags mentioned above
  # TODO: rewrite this all in Go as part of a dev/test env scaffolding thingo

  local group="${1:-}"

  if [ -z "${group}" ]; then
    echo "error: group name is required"
    exit 1
  fi
  if [ ! -d "${group}" ]; then
    echo "error: ${group} directory not found"
    exit 1
  fi

  # generate root CA
  if [ ! -f $CA_FILE ]; then
    $CONSUL_BIN tls ca create
  fi

  # generate server certs
  for s in $(_server_vm_names "${group}"); do
    cert_file="${s}${CERT_FILE_SUFFIX}"
    key_file="${s}${KEY_FILE_SUFFIX}"
    if [ ! -f "${group}/${s}/${VM_CA_ROOT}/${cert_file}" ]; then
      echo "generating server cert for $s"
      $CONSUL_BIN tls cert create \
        -server \
        -node "${s}" \
        -dc $(cut -d '-' -f1 <<< "${s}") \
        -ca $CA_FILE \
        -key $CA_KEY_FILE
      # populate server cert files
      cert_file="${s}${CERT_FILE_SUFFIX}"
      key_file="${s}${KEY_FILE_SUFFIX}"
      mkdir -p "${group}/${s}/${VM_CA_ROOT}"
      mv ${cert_file} "${group}/${s}/${VM_CA_ROOT}"
      mv ${key_file} "${group}/${s}/${VM_CA_ROOT}"
    fi
  done

  # populate root CA everywhere
  for vm in $(_vm_names "${group}"); do
    mkdir -p "${group}/${vm}/${VM_CA_ROOT}"
    cp $CA_FILE "${group}/${vm}${VM_CA_ROOT}"
    cp $CA_KEY_FILE "${group}/${vm}${VM_CA_ROOT}"
  done

  rm $CA_FILE $CA_KEY_FILE
}

main "$@"
