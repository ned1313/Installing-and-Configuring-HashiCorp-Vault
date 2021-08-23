# Allow access to list keys
path "dbas/keys" {
    capabilities = ["list"]
}

# Allow access to encrypt and decrypt data
path "dbas/encrypt/*" {
    capabilities = ["create","update"]
}

path "dbas/decrypt/*" {
    capabilities = ["update"]
}