Deploy Redis Enterprise cluster
Now you will deploy the Redis Enterprise Operator and Redis Enterprise cluster using the command line.

Run the following script to deploy a Redis Enterprise cluster. First, it will deploy Redis Enterprise Operator for Kubernetes and then followed by Redis Enterprise cluster:

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
export PATH="/root/istio-1.10.4-asm.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
kubectl create clusterrolebinding my-cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl create namespace redis
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/bundle.yaml" -n redis
sleep 10
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/rec.yaml" -n redis
EOF
Copied!
The deployment will take about 3 minutes to complete. Once it is complete, you should see this line: statefulset.apps/redis-enterprise 1/1 5m after running the following script:

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
export PATH="/root/istio-1.10.4-asm.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
kubectl get sts -n redis
EOF
Copied!
1/1 indicates a single-node Redis Enterprise cluster has been successfully created with 1 backing Kubernetes pod.s