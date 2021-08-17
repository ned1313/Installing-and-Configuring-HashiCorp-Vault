# We already have an Azure Key Vault for our certificates
# Let's add a key to the Azure Key Vault
# We'll do this with Terraform

#Log into Azure with CLI
az login
az account set --subscription "SUB_NAME"

# Go to the module 5 2-azure-vms directory
cd ../../m5/2-azure_vms/

# Copy the auto_unseal_key file
cp auto_unseal_key.txt auto_unseal_key.tf

# Now we can run a Terraform plan and apply with the same values as before
$certificate_cn="YOUR_CERTIFICATE_CN"

terraform plan -var leader_tls_servername=$certificate_cn -out azurevm.tfplan

# Now we'll apply the plan to create the resources
terraform apply azurevm.tfplan

# Next step is to update the Vault server configuration to use Key Vault for the seal
# Connect to the Azure VM via SSH to update the HCL file
ssh -i ~/.ssh/azure_vms_private_key.pem azureuser@PUBLIC_IP_ADDRESS

# Edit the vault.hcl file
sudo vi /etc/vault.d/vault.hcl

# Paste in the seal stanza

# Now we will restart Vault to seal it and update the loaded config
# then unseal with the migrate flag
sudo systemctl restart vault

# We're going to need our GPG keys to complete the operation
# Decrypt the first two keys if you don't have them anymore
echo "FIRST_KEY" | base64 --decode | gpg -u vaultadmin1 -dq
echo "SECOND_KEY" | base64 --decode | gpg -u vaultadmin2 -dq

vault operator unseal -migrate

# Our keys become recovery keys



