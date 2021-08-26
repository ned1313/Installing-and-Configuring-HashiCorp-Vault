# We are going to update our deployment with Terraform
# to include the log analytics workspace and the 
# OMSLinuxAgent Azure VM extension

# First go into module 7 and copy the log_analytics.txt file
cd ../m7/1-azure_vms/
cp log_analytics.txt log_analytics.tf

# Now we'll update our deployment
# Make sure to change the YOUR_CERTIFICATE_CN to the fqdn on
# your TLS certificate. Ex. vault-vms.globomantics.xyz
$certificate_cn="YOUR_CERTIFICATE_CN"

terraform plan -var leader_tls_servername=$certificate_cn -out azurevm.tfplan

# Now we'll apply the plan to create the resources
terraform apply azurevm.tfplan

# The next step has to be done in the UI or by altering the 
# syslog config files. It's easier to go to the UI
# and update the agent settings to include facility LOCAL7

# The update can take up to 15 minutes to apply to the agents
# You can kickstart the process by restarting the agent or the VM
ssh -i ~/.ssh/azure_vms_private_key2.pem -p 2022 azureuser@PUBLIC_IP_ADDRESS

# Check on the config file
sudo cat /etc/rsyslog.d/95-omsagent.conf

# Restart agent if desired
sudo /opt/microsoft/omsagent/bin/service_control restart

# And the wa-agent as well
sudo systemctl restart walinuxagent