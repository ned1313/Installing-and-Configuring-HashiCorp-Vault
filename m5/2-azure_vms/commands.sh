# Terraform can use your login credentials from the Azure CLI
# Make sure you are logged into Azure with the CLI and have the 
# correct subscription selected.
az login
az account set -s SUBSCRIPTION_NAME

# First we are going to initialize the Terraform config
terraform init

# Next we are going to plan our deployment
# Make sure to change the YOUR_CERTIFICATE_CN to the fqdn on
# your TLS certificate. Ex. vault-vms.globomantics.xyz
certificate_cn=YOUR_CERTIFICATE_CN

terraform plan -var leader_tls_servername=$certificate_cn -out azurevm.tfplan

# Now we'll apply the plan to create the resources
terraform apply azurevm.tfplan

# Included in the output will be the public DNS name and IP address
# Take the public DNS name and add it as a CNAME entry in your public DNS service

# You can SSH into the Vault server by using SSH and port 22
# First we'll need to copy the SSH private key over to your home directory
# This should apply the proper permissions to the private key to make SSH happy
cp azure_vms_private_key.pem ~/.ssh/
chmod 600 ~/.ssh/azure_vms_private_key.pem

# Now we'll connect to the Vault server using SSH to install Vault
ssh -i ~/.ssh/azure_vms_private_key.pem azureuser@PUBLIC_IP_ADDRESS

# The initialization script can take up to 5 minutes to complete. If you don't see the expected files
# wait a few minutes and check again.

# Once you're connected we'll walk through the process of installing Vault server and raft cluster
# First let's check out what the installation created
ls /etc/vault.d
ls /opt/vault
cat /etc/passwd | grep vault

# The script also copied the pfx file from Key Vault and placed the contents 
# where we need them for Raft and Vault
sudo cat /opt/vault/tls/vault-ca.pem | openssl x509 -text -nocert

# The next step is to overwrite the existing HCL file with our actual config
sudo rm /etc/vault.d/vault.hcl

# Get local IPv4 address
ip a show eth0

sudo vi /etc/vault.d/vault.hcl

# Now we can enable the vault service and start it
sudo systemctl enable vault
sudo systemctl start vault

# Now we'll check the vault service status with journalctl
journalctl -u vault

# Assuming the Vault service is running, let's check the status
export VAULT_ADDR="https://YOUR_VAULT_FQDN:8200"

vault status

# Cool, the next step is to initialize the Vault server
# We will do that in the next module
# Do not destroy this Vault deployment!

