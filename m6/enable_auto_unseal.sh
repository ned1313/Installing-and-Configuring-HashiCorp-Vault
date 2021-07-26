# We are going to create an Azure Key Vault to hold the unseal key

#Log into Azure with CLI
az login
az account set --subscription "SUB_NAME"

# And we'll need a service principal with access to the Key Vault

# First let's set some variables
id=$(((RANDOM%9999+1)))
location=eastus
resource_group_name=VaultCluster
key_vault_name=VaultCluster${id}
sp_name=VaultClusterKV

# Create the service principal
sp_info=$(az ad sp create-for-rbac \
  -n $sp_name --skip-assignment)

client_id=$(echo $sp_info | jq .appId -r)
client_secret=$(echo $sp_info | jq .password -r)
tenant_id=$(echo $sp_info | jq .tenant -r)

# Create the Key Vault
az keyvault create -n $key_vault_name -g $resource_group \
  -l $location --sku Standard

az keyvault set-policy --name "vault-keyvault" --spn VaultClusterKV \ 
  --key-permissions get list create delete update wrapKey unwrapKey

# Create a Key in the Key Vault
az keyvault key create --vault-name $key_vault_name \
  --name "vault-key" --protection software --kty RSA \
  --size 2048 --ops decrypt encrypt sign unwrapKey verify wrapKey

# Now we'll create a K8s secret with all the info we need
kubectl create secret -n vault AzureKeyVault \
  --from-literal=TenantId=$tenant_id \
  --from-literal=ClientId-$client_id \
  --from-literal=ClientSecret=$client_secret \
  --from-literal=Environment=AZUREPUBLICCLOUD \
  --from-literal=KeyVaultName=$key_vault_name \
  --from-literal=KeyVaultKeyName=vault-keyvault

# Next we can update the Helm install with our new info

# Finally, we can migrate the seal to Azure Key Vault
# Seal the Vault on all nodes
kubectl exec -it vault-0 -n vault -- \
  vault operator seal

kubectl exec -it vault-1 -n vault -- \
  vault operator seal

kubectl exec -it vault-2 -n vault -- \
  vault operator seal

kubectl exec -it vault-0 -n vault -- \
  vault operator unseal -migrate

# Kill the other two pods
kubectl delete pod vault-1 -n vault
kubectl delete pod vault-2 -n vault

# Validate all is well



