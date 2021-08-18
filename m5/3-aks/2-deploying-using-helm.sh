# Now that we have a K8s cluster to work with, let's get Vault deployed with Helm
SECRET_NAME=vault-tls
NAMESPACE=vault
certificate_cn=YOUR_CERTIFICATE_CN

# First we will add the Helm repo for Vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Add a namespace for the Vault cluster
kubectl create namespace ${NAMESPACE}

# Create a secret with the Vault certificate info
# Extract the crt, key, and ca info from the PFX file
openssl pkcs12 -cacerts -nokeys -in ../1-cert-gen/aks-certificate-to-import.pfx -passin pass: | openssl x509 -out vault.ca
openssl pkcs12 -nokeys -in ../1-cert-gen/aks-certificate-to-import.pfx -passin pass: -out vault.crt
openssl pkcs12 -nocerts -nodes -in ../1-cert-gen/aks-certificate-to-import.pfx -passin pass: | openssl pkcs8 -nocrypt -out vault.key

kubectl create secret generic ${SECRET_NAME} \
  --namespace ${NAMESPACE} \
  --from-file=vault.key=vault.key \
  --from-file=vault.crt=vault.crt \
  --from-file=vault.ca=vault.ca

# Clean up
rm vault.*

# Deploy Consul to provide storage for Vault
helm install consul hashicorp/consul --namespace vault

# Deploy Vault cluster to K8s using helm
helm install vault hashicorp/vault \
  --namespace vault \
  --values overrides.yaml

# We can monitor the install by doing a watch on the namespace
kubectl get pods -n vault -w

# Once they are all Running, we're in good shape
# Now get the LoadBalancer IP address for the server
kubectl get service vault -n vault

# The address for the Vault server will be the dns label 
# plus the Azure region cloudapp.azure.com 
# Ex. vaultf-9f8a7a6.eastus.cloudapp.azure.com
# You'll need to add a CNAME entry for this to your public DNS
# Ex. vault-aks.globomantics.xyz

export VAULT_ADDR="https://${certificate_cn}:8200"

vault status
