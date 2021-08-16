# We are going to use the Terraform to spin up an AKS cluster

# NOTE: You do not have to use AKS for the demo. You could use another
# hosted option like EKS or GKE, or run this locally using KinD.
# These rest of the demo will assume AKS, but feel free to map it to
# your preferred K8s environment.

# Log into Azure
az login

# Select the proper subscription
az account set -s SUBSCRIPTION_NAME

# Initialize terraform and run a plan
terraform init

terraform plan -out aks.tfplan

# Create the AKS cluster
terraform apply aks.tfplan

# Set the resource group name and cluster name
rg_name=
c_name=

# Retrieve the credentials
az aks get-credentials --resource-group $rg_name --name $c_name

# Verify kubectl credentials
kubectl get nodes