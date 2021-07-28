# You should have already downloaded the Vault binary and placed it in folder in your $PATH
# Start up a dev Vault server in one terminal
vault server -dev -dev-root-token-id=86753098675309

# Open a second terminal window
export VAULT_ADDR='http://127.0.0.1:8200'

# Try the CLI
# Check for the root token
vault token lookup

# List out the secrets engines
vault secrets list

# Write a secret
vault kv put secret/hg2g life=42

# List out the auth methods
vault auth list

# Try the UI by going to http://127.0.0.1:8200

# Try the API - we will use curl
# Set the root token
# MacOS or Linux
export VAULT_TOKEN=86753098675309

curl -H "X-Vault-Token: $VAULT_TOKEN" \
  -X GET \
  $VAULT_ADDR/v1/secret/data/hg2g | jq