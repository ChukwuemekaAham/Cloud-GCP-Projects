Create a Knative serverless service (incrementing a Redis counter)
This Knative service is a web application counting number of visitors at RedisConf conference

It uses Knative concurrency-based auto-scaling at 2 requests in-flight per pod

It has a minimum of 1 pod and maximum of 5 pods. It scales based on current workload.

Go inside the Admin workstation machine:

gcloud compute ssh root@$VM_WS --zone ${ZONE}
Copied!
Then run the following script to create the Knative service:

set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/anthos-bm-cluster-1/anthos-bm-cluster-1-kubeconfig
export redispassword=`kubectl get secrets -n redis redb-redis-enterprise-database  -o json | jq '.data | {password}[] | @base64d'`
export redishost=`kubectl get svc -n redis | grep "redis-enterprise-database " | awk '{print $3}' | awk '{split($0,a,"/"); print a[1]}'`
export redisport=`kubectl get secrets -n redis redb-redis-enterprise-database  -o json | jq -r '.data | {port}[] | @base64d'`
cat <<EOF2 > /tmp/redisconf.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: redisconf
  namespace: default
spec:
  template:
    metadata:
      annotations:
        # Knative concurrency-based autoscaling (default).
        autoscaling.knative.dev/class: kpa.autoscaling.knative.dev
        autoscaling.knative.dev/metric: concurrency
        # Target 2 requests in-flight per pod.
        autoscaling.knative.dev/target: "2"
        # Disable scale to zero with a minScale of 1.
        autoscaling.knative.dev/minScale: "1"
        # Limit scaling to 5 pods.
        autoscaling.knative.dev/maxScale: "5"
    spec:
      containers:
        - name: redisconf-container
          image: gcr.io/central-beach-194106/visit-count:latest
          ports:
          - containerPort: 80
          env:
          - name: REDISHOST
            value: ${redishost}
          - name: REDISPORT
            value: '${redisport}'
          - name: REDISPASSWORD
            value: ${redispassword}
EOF2
kubectl apply -f /tmp/redisconf.yaml
Copied!
Remain inside the Admin workstation machine and run the following to verify the Knative service is up and running and view the status of the "redisconf" Knative service:

kubectl get ksvc redisconf
Copied!
Access the Knative service via a curl command:

curl http://redisconf.default.10.200.0.51.xip.io
Copied!
You should see a similar output like the following from the curl command: