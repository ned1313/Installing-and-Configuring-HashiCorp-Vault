# Set your Vault address environment variable
# Ex. vault-vms.globomantics.xyz
export VAULT_ADDR=https://VAULT_SERVER_FQDN:8200

# And log into Vault using the globoadmin user
vault login -method=userpass username=globoadmin

# We are going to enable a v2 KV secrets engine called website

# Let's first see which secrets engines are enabled

vault secrets list

# Now let's get our secrets engines enabled

vault secrets enable -path=website -version=2 kv

vault secrets enable -path=dbas transit

# And verify they exist
vault secrets list