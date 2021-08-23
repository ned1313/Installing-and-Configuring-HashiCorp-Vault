# Generate a token for the website k/v engine
vault token create -policy="website-devs"

# Log in with the token
vault login

# Try to add a secret
vault kv put website/apitokens/d101 token=8675309

# Nice, let's read one of the values
vault kv get website/apitokens/d101

# Finally we can delete it and let the devs do their thing
vault kv delete website/apitokens/d101

# Now let's generate a token to test the transit engine

# Log back in as globoadmin
vault login -method=userpass username=globoadmin

# Create the token 
vault token create -policy="transit-dbas"

# Log in with the token
vault login

# First we'll encrypt some data
$plaintext=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("solongandthanks"))
vault write dbas/encrypt/key1 plaintext=$plaintext

# And now we'll try to decrypt the ciphertext
$ciphertext="CIPHERTEXT"

vault write dbas/decrypt/key1 ciphertext=$ciphertext

[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("PLAINTEXT"))