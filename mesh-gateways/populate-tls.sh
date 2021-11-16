#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# path to consul binary, points to source repo so that we're using a dev build
CONSUL_BIN=$SCRIPT_DIR/../../consul/bin/consul

# where all certs and keys will be generated to
TLS_ROOT=$SCRIPT_DIR/tls
# just the file names, dirname will be prepended at upload time, these should
# match the Consul defaults based on our inputs
CA_FILE=consul-agent-ca.pem
CA_KEY_FILE=consul-agent-ca-key.pem
PRIMARY_CERT_FILE=primary-server-consul-0.pem
PRIMARY_KEY_FILE=primary-server-consul-0-key.pem
SECONDARY_CERT_FILE=secondary-server-consul-0.pem
SECONDARY_KEY_FILE=secondary-server-consul-0-key.pem

# where all certs will be uploaded on VMs
REMOTE_CA_ROOT=/etc/ca-certificates/consul

function usage {
  echo "Usage: populate-tls.sh [options]"
  echo "Generates and uploads Consul CA certs to all the right places."
  echo "By default, when the certs already exist those will be used unless"
  echo "the -g/-generate flag is given."
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

  # create the directory for all our tls data if it doesn't exist
  mkdir -p $TLS_ROOT || true

  # generate root CA
  if [ ! -f $TLS_ROOT/$CA_FILE ]; then
    $CONSUL_BIN tls ca create
    mv $CA_FILE $CA_KEY_FILE $TLS_ROOT
  fi
  # generate primary server certs
  if [ ! -f $TLS_ROOT/$PRIMARY_CERT_FILE ]; then
    $CONSUL_BIN tls cert create \
      -server \
      -node primary-server \
      -dc primary \
      -ca $TLS_ROOT/$CA_FILE \
      -key $TLS_ROOT/$CA_KEY_FILE
    mv $PRIMARY_CERT_FILE $PRIMARY_KEY_FILE $TLS_ROOT
  fi

  # generate secondary server certs
  if [ ! -f $TLS_ROOT/$SECONDARY_CERT_FILE ]; then
    $CONSUL_BIN tls cert create \
      -server \
      -node secondary-server \
      -dc secondary \
      -ca $TLS_ROOT/$CA_FILE \
      -key $TLS_ROOT/$CA_KEY_FILE
    mv $SECONDARY_CERT_FILE $SECONDARY_KEY_FILE $TLS_ROOT
  fi

  # populate root CA everywhere
  vms=(
    primary-server
    primary-gateway
    primary-services
    secondary-server
    secondary-gateway
    secondary-services
  )

  for vm in ${vms[@]}; do
    vagrant upload \
      $TLS_ROOT/$CA_FILE \
      $REMOTE_CA_ROOT/$CA_FILE \
      $vm
    vagrant upload \
      $TLS_ROOT/$CA_KEY_FILE \
      $REMOTE_CA_ROOT/$CA_KEY_FILE \
      $vm
  done

  # populate primary tls
  vagrant upload \
    $TLS_ROOT/$PRIMARY_CERT_FILE \
    $REMOTE_CA_ROOT/$PRIMARY_CERT_FILE \
    primary-server
  vagrant upload \
    $TLS_ROOT/$PRIMARY_KEY_FILE \
    $REMOTE_CA_ROOT/$PRIMARY_KEY_FILE \
    primary-server

  # populate secondary tls
  vagrant upload \
    $TLS_ROOT/$SECONDARY_CERT_FILE \
    $REMOTE_CA_ROOT/$SECONDARY_CERT_FILE \
    secondary-server
  vagrant upload \
    $TLS_ROOT/$SECONDARY_KEY_FILE \
    $REMOTE_CA_ROOT/$SECONDARY_KEY_FILE \
    secondary-server
}



main "$@"
