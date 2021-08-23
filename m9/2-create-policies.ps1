# Now we'll create a policy for the two secrets engines

# First up we'll create a policy for the devs to do whatever
# they want in the website KV engine
vault policy write website-devs kv-policy.hcl

# Now we'll create one for the transit engine
# Except we'll only allow encrypt and decrypt operations
vault policy write transit-dbas transit-policy.hcl