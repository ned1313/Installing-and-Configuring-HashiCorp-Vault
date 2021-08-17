# We're done with our single server Vault environment
# Go ahead and destroy the Azure VM environment

# Go to the module 5 2-azure-vms directory
cd ../../m5/2-azure_vms/

# Now we can run a Terraform destory
$certificate_cn="YOUR_CERTIFICATE_CN"

terraform destroy -var leader_tls_servername=$certificate_cn -auto-approve