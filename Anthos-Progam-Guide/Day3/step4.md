Create a Redis Enterprise database
Run the following script to create a Redis Enterprise database:

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF1
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
cat <<EOF2 > /tmp/redis-enterprise-database.yaml
apiVersion: app.redislabs.com/v1alpha1
kind: RedisEnterpriseDatabase
metadata:
  name: redis-enterprise-database
spec:
  memorySize: 100MB
EOF2
kubectl apply -f /tmp/redis-enterprise-database.yaml -n redis
EOF1