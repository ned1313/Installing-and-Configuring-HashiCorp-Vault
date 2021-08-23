# Allow access to all website secrets
path "website/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to metadata for kv2
path "website/metadata/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}