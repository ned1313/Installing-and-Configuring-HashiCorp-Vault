#!/usr/bin/env bash
set -e -o pipefail

# Terraform variables used: 
# vault_version - version of the Vault binary to download
# key_vault_secret_id - Id of the Key Vault secret holding the certificates
# leader_tls_servername - The servername used for the certificate and front end
# tenant_id - Azure tenant ID for autounseal
# key_vault_name - Name of Key Vault for autounseal
# key_vault_key_name - Name of Key in Key Vault for autounseal

# Get the instance name and local ipv4 address
export instance_name="$(curl -sH Metadata:true --noproxy '*' 'http://169.254.169.254/metadata/instance/compute/name?api-version=2020-09-01&format=text')"
export local_ipv4="$(curl -sH Metadata:true --noproxy '*' 'http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2020-09-01&format=text')"

# Get the Vault binary
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install python3-pip vault=${vault_version} -y

# Install Azure CLI
pip3 install --user 'azure-cli~=2.26.0' 'azure-mgmt-core~=1.2.0' 'cryptography~=3.3.2' 'urllib3[secure]~=1.26.5' 'requests~=2.25.1'

# configuring Azure CLI for use with VM managed identity
~/.local/bin/az login --identity --allow-no-subscriptions

# removing any default installation files from /opt/vault/tls/
rm -rf /opt/vault/tls/*

# set up the certificates
touch /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem,vault-full.pem}
chown vault:vault /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem,vault-full.pem}
chmod 0640 /opt/vault/tls/{vault-cert.pem,vault-ca.pem,vault-key.pem,vault-full.pem}

secret_result=$(~/.local/bin/az keyvault secret show --id "${key_vault_secret_id}" --query "value" --output tsv)

echo $secret_result | base64 -d | openssl pkcs12 -clcerts -nokeys -passin pass: | openssl x509 -out /opt/vault/tls/vault-cert.pem

echo $secret_result | base64 -d | openssl pkcs12 -cacerts -nokeys -chain -passin pass: | openssl x509 -out /opt/vault/tls/vault-ca.pem

echo $secret_result | base64 -d | openssl pkcs12 -nocerts -nodes -passin pass: | openssl pkcs8 -nocrypt -out /opt/vault/tls/vault-key.pem

echo $secret_result | base64 -d | openssl pkcs12 -nokeys -passin pass: -out /opt/vault/tls/vault-full.pem

# Create config file

cat <<EOF > /etc/vault.d/vault.hcl
# General parameters
cluster_name = "vault-vms"
log_level = "Info"
ui = true

# HA parameters
cluster_addr = "https://$local_ipv4:8201"
api_addr = "https://${leader_tls_servername}:8200"

listener "tcp" {
 address     = "0.0.0.0:8200"
 cluster_address = "0.0.0.0:8201"

 tls_disable = 0
 tls_cert_file      = "/opt/vault/tls/vault-full.pem"
 tls_key_file       = "/opt/vault/tls/vault-key.pem"
 tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
 tls_min_version = "tls12"
}

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "$instance_name"
  retry_join {
    leader_tls_servername = "${leader_tls_servername}"
    leader_api_addr = "https://${leader_tls_servername}:8200"
    leader_ca_cert_file = "/opt/vault/tls/vault-ca.pem"
    leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
    leader_client_key_file = "/opt/vault/tls/vault-key.pem"
  }
}

seal "azurekeyvault" {
  tenant_id = "${tenant_id}"
  vault_name = "${key_vault_name}"
  key_name = "${key_vault_key_name}"
}

EOF

chown -R vault:vault /etc/vault.d/*
chmod -R 640 /etc/vault.d/*

systemctl enable vault
systemctl start vault