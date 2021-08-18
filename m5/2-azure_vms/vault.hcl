# General parameters
cluster_name = "vault-vms"
log_level = "Info"
ui = true

# HA parameters
cluster_addr = "https://LOCAL_IPV4:8201"
api_addr = "https://LOCAL_IPV4:8200"

# Listener configuration
listener "tcp" {
 # Listener address
 address     = "0.0.0.0:8200"

 # TLS settings
 tls_disable = 0
 tls_cert_file      = "/opt/vault/tls/vault-full.pem"
 tls_key_file       = "/opt/vault/tls/vault-key.pem"
 tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
 tls_min_version = "tls12"
}

# Storage configuration
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-0"
  retry_join {
    leader_tls_servername = "LEADER_TLS_SERVERNAME"
    leader_api_addr = "https://LEADER_TLS_SERVERNAME:8200"
    leader_ca_cert_file = "/opt/vault/tls/vault-ca.pem"
    leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
    leader_client_key_file = "/opt/vault/tls/vault-key.pem"
  }
}