# First we can check and see what policies exist right now
vault policy list 

# Now we'll create a policy for Vault administration
# This policy is based off an example provided by HashiCorp
vault policy write vault-admins vault-admins.hcl

# Next we can assign the policy to the globoadmin user
vault write auth/userpass/users/globoadmin token_policies="vault-admins"

# Now we can log in as globoadmin and a few actions
vault login -method=userpass username=globoadmin

# List all secrets engines
vault secrets list

# Enable a secrets engine
vault secrets enable -path=testing -version=1 kv

# List all policies
vault policy list

# Things look good! Let's revoke the current root token 
# and use the admin account from here on out
vault token revoke ROOT_TOKEN_VALUE
