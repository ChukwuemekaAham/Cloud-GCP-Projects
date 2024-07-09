set x


# configure RBAC policies on the Anthos bare metal cluster.

export user_account=<GCP login account username from your session>

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF1
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
cat <<EOF2 > /tmp/impersonate.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
    name: gateway-impersonate
rules:
- apiGroups:
  - ""
  resourceNames:
  - ${user_account}
  resources:
  - users
  verbs:
  - impersonate
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: gateway-impersonate
roleRef:
    kind: ClusterRole
    name: gateway-impersonate
    apiGroup: rbac.authorization.k8s.io
subjects:
    - kind: ServiceAccount
      name: connect-agent-sa
      namespace: gke-connect
EOF2
kubectl apply -f /tmp/impersonate.yaml
cat <<EOF2 > /tmp/admin-permission.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: gateway-cluster-admin
subjects:
    - kind: User
      name: ${user_account}
roleRef:
      kind: ClusterRole
      name: cluster-admin
      apiGroup: rbac.authorization.k8s.io
EOF2
kubectl apply -f /tmp/admin-permission.yaml
EOF1


# Go to Google Cloud Console and view the Anthos bare metal server under Compute > Kubernetes Engine > Clusters section. You should see the cluster has been authenticated and logged on using your Google Cloud login.
# If not, follow the on-screen instructions below to log into the Anthos bare metal server:

# Click on the three dots on the right side of your cluster.

# Click Log in.

# In the pop up window, select Use your Google identity to log-in and click Login.

# Your cluster should now be authenticated.