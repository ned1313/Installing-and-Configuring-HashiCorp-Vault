# Configuring local file auditing
# Head back to this folder
cd ../../m10

# Set your Vault address environment variable
# Ex. vault-vms.globomantics.xyz
export VAULT_ADDR=https://VAULT_SERVER_FQDN:8200

# And log into Vault using the globoadmin user
vault login -method=userpass username=globoadmin

# First we need to update our admin policy!
vault policy write vault-admins vault-admins.hcl

# Enable a file location for an audit device
vault audit enable file file_path=/opt/vault/audit.log

# On vault server enable the syslog audit device to a facility
vault audit enable syslog tag="vault" facility="LOCAL7"

# Now go back to the Azure portal and the log analytics workspace
# we created earlier. You can query the logs capture and verify
# that event have started to show up

# Run the following query on Logs
Syslog
| where Facility == "local7" 

# Add some entries to the audit log by issuing
# Vault requests
vault secrets list

vault policy list

vault secrets enable -path=audittest kv