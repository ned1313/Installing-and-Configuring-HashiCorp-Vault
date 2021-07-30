# We are going to use certbot to create a 3rd part certificate
# for our Vault server. You will need to have a registered domain
# to do this.

# Before you run the commands, log into your domain hosting service
# and be ready to add a TXT record to your domain

# First set the domain name you are going to create a certificate for
domain_name=YOUR_DOMAIN_NAME
request_name=vault.${domain_name}

# Next we will install certbot if you don't already have it
sudo apt install certbot -y

# Now we are going to request a certificate from Let's Encrypt
# using the manual verification process
sudo certbot certonly --manual -d $request_name --agree-tos -m ned@${domain_name} --no-eff-email --preferred-challenges dns

# Agree to your IP being logged

# Create a TXT record on your domain and then hit enter

# Copy your fullchain.pem and privkey.pem files to the cert-gen folder
sudo cp /etc/letsencrypt/live/vault-test.globomantics.xyz/chain.pem .
sudo cp /etc/letsencrypt/live/vault-test.globomantics.xyz/cert.pem .
sudo cp /etc/letsencrypt/live/vault-test.globomantics.xyz/privkey.pem .

# Now we'll create our PFX file that we can upload to Key Vault
openssl pkcs12 -export -out certificate-to-import.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -passout pass:
