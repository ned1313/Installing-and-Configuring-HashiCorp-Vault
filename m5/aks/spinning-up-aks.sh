# We are going to use the Azure CLI to spin up an AKS cluster

# NOTE: You do not have to use AKS for the demo. You could use another
# hosted option like EKS or GKE, or run this locally using KinD.
# These rest of the demo will assume AKS, but feel free to map it to
# your preferred K8s environment.

# Log into Azure
az login

# Select the proper subscription
az account set -s SUBSCRIPTION_NAME

# Set some variables
# Change these values as needed
location=eastus
resource_group_name=VaultCluster
cluster_name=VaultCluster
node_count=3
node_size=Standard_B2ms
kubernetes_version=1.20.7

# Create the resource group for AKS
az group create --name $resource_group_name --location $location

# Create an AKS cluster
az aks create --resource-group $resource_group_name \
  --name $cluster_name \
  --node-count $node_count \
  --node-vm-size $node_size \
  --generate-ssh-keys \
  --kubernetes-version $kubernetes_version \
  --enable-addons monitoring

# Retrieve the credentials
az aks get-credentials \
  --resource-group $resource_group_name \
  --name $cluster_name