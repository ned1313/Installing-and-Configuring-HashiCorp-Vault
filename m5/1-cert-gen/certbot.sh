# We are going to use certbot to create a 3rd party certificate
# for our Vault server instances. You will need to have a registered domain
# to do this.

# Before you run the commands, log into your domain hosting service
# and be ready to add a TXT record to your domain

# First set the domain name you are going to create a certificate for
domain_name=YOUR_DOMAIN_NAME

# We are going to create two certificates: one for Azure VMs
# and one for AKS
vm_request_name=vault-vms.${domain_name}
aks_request_name=vault-aks.${domain_name}

# Next we will install certbot if you don't already have it
sudo apt install certbot -y

# Now we are going to request a certificate from Let's Encrypt
# using the manual verification process for the Azure VMs
sudo certbot certonly --manual -d $vm_request_name --agree-tos -m noone@${domain_name} --no-eff-email --preferred-challenges dns

# Agree to your IP being logged

# Create a TXT record on your domain and then hit enter

# Copy your pem files to the cert-gen folder
sudo cp /etc/letsencrypt/live/${vm_request_name}/fullchain.pem vm_fullchain.pem
sudo cp /etc/letsencrypt/live/${vm_request_name}/privkey.pem vm_privkey.pem

# Now we'll create our PFX file that we can upload to Key Vault for the Azure VMs
openssl pkcs12 -export -out vm-certificate-to-import.pfx -inkey vm_privkey.pem -in vm_fullchain.pem -passout pass:

# Repeat the process for the AKS certificate
sudo certbot certonly --manual -d $aks_request_name --agree-tos -m noone@${domain_name} --no-eff-email --preferred-challenges dns

# Copy your pem files to the cert-gen folder
sudo cp /etc/letsencrypt/live/${aks_request_name}/fullchain.pem aks_fullchain.pem
sudo cp /etc/letsencrypt/live/${aks_request_name}/privkey.pem aks_privkey.pem

# Create the PFX file
openssl pkcs12 -export -out aks-certificate-to-import.pfx -inkey aks_privkey.pem -in aks_fullchain.pem -passout pass: