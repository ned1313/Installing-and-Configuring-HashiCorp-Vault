# Now that we have a K8s cluster to work with, let's get Vault deployed with Helm

# First we will add the Helm repo for Vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Now we are going to prepare our alterations
# Some variables for the helm chart and certificate
id=$(((RANDOM%9999+1)))
location=eastus # Location of AKS cluster
dns_name=globovault${id}

# Add a namespace for the Vault cluster
kubectl create namespace vault

# Create the certificate request for the Kubernetes Cert Manager
SERVICE=vault
NAMESPACE=vault
SECRET_NAME=vault-server-tls

# Create a key for K8s to sign
openssl genrsa -out vault.key 2048

# Create a CSR for K8s
cat <<EOF >${TMPDIR}/csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${SERVICE}
DNS.2 = ${SERVICE}.${NAMESPACE}
DNS.3 = ${SERVICE}.${NAMESPACE}.svc
DNS.4 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
DNS.5 = ${SERVICE}-active
DNS.6 = ${dns_name}.${location}.cloudapp.azure.com
IP.1 = 127.0.0.1
EOF

openssl req -new -key vault.key \
  -subj "/CN=${SERVICE}.${NAMESPACE}.svc" \
  -out server.csr \
  -config csr.conf

export CSR_NAME=vault-csr
cat <<EOF > csr.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  groups:
  - system:authenticated
  request: $(cat server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

kubectl create -f csr.yaml

kubectl certificate approve ${CSR_NAME}

serverCert=$(kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}')
echo "${serverCert}" | openssl base64 -d -A -out vault.crt
kubectl config view --raw --minify --flatten \
  -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > vault.ca

kubectl create secret generic ${SECRET_NAME} \
  --namespace ${NAMESPACE} \
  --from-file=vault.key=vault.key \
  --from-file=vault.crt=vault.crt \
  --from-file=vault.ca=vault.ca

# Clean up
del vault.*


# Deploy Vault cluster to K8s using helm
helm install vault hashicorp/vault \
  --namespace vault \
  --values overrides.yaml

# Deploy Vault cluster to K8s using helm
helm install vault hashicorp/vault \
  --namespace vault \
  --set='ui.enabled=true' \
  --set='ui.serviceType=LoadBalancer' \
  --set='ui.annotations.service\.beta\.kubernetes\.io/azure-dns-label-name=tacovault-ui' \
  --set='server.service.type=LoadBalancer' \
  --set='server.service.annotations.service\.beta\.kubernetes\.io/azure-dns-label-name=tacovault' \
  --set='server.ha.enabled=true' \
  --set='server.ha.raft.enabled=true'

# We can monitor the install by doing a watch on the namespace
kubectl get pods -n vault -w

# Once they are all Running, we're in good shape
# Now get the LoadBalancer IP address for the UI
kubectl get service vault-ui -n vault

# You can check out the UI
# Next step is to initialize the Raft storage and the Vault cluster
