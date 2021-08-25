# First we are going to initialize the Terraform config
terraform init

# Next we'll copy over the certificate file we'll use for the deployment
cp ../../m5/1-cert-gen/vm-certificate-to-import.pfx vm-certificate-to-import.pfx

# Next we are going to plan our deployment
# Make sure to change the YOUR_CERTIFICATE_CN to the fqdn on
# your TLS certificate. Ex. vault-vms.globomantics.xyz
certificate_cn=YOUR_CERTIFICATE_CN

terraform plan -var leader_tls_servername=$certificate_cn -out azurevm.tfplan

# Now we'll apply the plan to create the resources
terraform apply azurevm.tfplan

# Included in the output will be the public DNS name and IP address
# Take the public DNS name and add it as a CNAME entry in your public DNS service

# You can SSH into the first Vault server by using SSH and port 2022
# First we'll need to copy the SSH private key over to your home directory
# This should apply the proper permissions to the private key to make SSH happy
cp azure_vms_private_key.pem ~/.ssh/azure_vms_private_key2.pem
chmod 600 ~/.ssh/azure_vms_private_key2.pem

ssh -i ~/.ssh/azure_vms_private_key2.pem -p 2022 azureuser@PUBLIC_IP_ADDRESS

# Once you're connected we'll initialize the Vault server and raft cluster using the UI

# We can also view the cluster information using vault status
export VAULT_ADDR="https://$certificate_cn:8200"

vault status

# And check on the raft cluster as well
vault login

vault operator raft list-peers

