# We are going to set this up initially for a standard seal
# Let's go with 3 shares and 2 for the threshold
kubectl exec -it vault-0 -n vault -- \
  vault operator init --key-shares=3 --key-threshold=2

# Take note of the root token and unseal keys
kubectl exec -it vault-0 -n vault -- vault operator unseal

# The first node is running and ready!
kubectl get pods -n vault
kubectl exec -it vault-0 -n vault -- vault status
kubectl exec -it vault-2 -n vault -- \
  cat /vault/config/extraconfig-from-values.hcl

kubectl exec -it vault-0 -n vault -- env


# Let's join our other two pods to the raft storage and vault cluster
kubectl exec -it vault-1 -n vault -- \
  vault operator raft join http://vault-0.vault-internal:8200

kubectl exec -it vault-1 -n vault -- vault operator unseal
kubectl exec -it vault-1 -n vault -- vault status


kubectl exec -it vault-2 -n vault -- \
  vault operator raft join http://vault-0.vault-internal:8200

kubectl exec -it vault-2 -n vault -- vault operator unseal
kubectl exec -it vault-2 -n vault -- vault status
