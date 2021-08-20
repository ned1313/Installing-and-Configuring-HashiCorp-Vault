# Set your Vault address environment variable
# Ex. vault-vms.globomantics.xyz
export VAULT_ADDR=https://VAULT_SERVER_FQDN:8200

# And log into Vault using the root token
vault login 

# First let's see what auth methods are avilable now
vault auth list

# Cool, now let's enable our first auth method using userpass
vault auth enable userpass

# Now let's check the list of auth methods again
vault auth list

# Oh no! We forgot to add descriptions! Better take care of that
vault auth tune -description="Globomantics Userpass" userpass/

vault auth list

# Let's write some data to create a new user

vault write auth/userpass/users/globoadmin password=burritos