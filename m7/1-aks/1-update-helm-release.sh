# We are going to update our Kubernetes deployment for HA
# and there's not a whole lot to do!
NAMESPACE=vault

helm upgrade vault hashicorp/vault \
 --namespace $NAMESPACE \
 --values overrides.yaml

# Verify that we now have three vault pods
kubectl get pods -n $NAMESPACE

# Of course we haven't initilized Vault or configured
# auto-unseal. That will be covered in a separate course.