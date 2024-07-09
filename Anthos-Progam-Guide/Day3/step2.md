Install Anthos Service Mesh and Knative
In this section you will deploy Anthos Service Mesh on the bare metal cluster. You will:

Install Anthos Service Mesh kit

Configure certs

Create cacerts secret

Set network annotation for istio-system namespace

Configure Anthos Service Mesh Configuration File

Configure Validation Web Hook

First, run the following script to install the Anthos Service Mesh:

```bash

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
apt install make -y
curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.10.4-asm.6-linux-amd64.tar.gz
tar xzf istio-1.10.4-asm.6-linux-amd64.tar.gz
cd istio-1.10.4-asm.6
export PATH="/root/istio-1.10.4-asm.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
mkdir -p certs && \
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca
make -f ../tools/certs/Makefile.selfsigned.mk anthos-on-nucs-cacerts
kubectl create namespace istio-system
kubectl create secret generic cacerts -n istio-system \
  --from-file=anthos-on-nucs/ca-cert.pem \
  --from-file=anthos-on-nucs/ca-key.pem \
  --from-file=anthos-on-nucs/root-cert.pem \
  --from-file=anthos-on-nucs/cert-chain.pem
popd
kubectl label namespace istio-system topology.istio.io/network=anthos-on-nucs-network
cat <<EOF1 > cluster.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: asm-multicloud
  revision: asm-1104-6
  values:
    global:
      meshID: anthos-on-nucs-mesh
      multiCluster:
        clusterName: $clusterid
      network: anthos-on-nucs-network
EOF1
istioctl install -f cluster.yaml -y
cat <<EOF1 > istiod-service.yaml
apiVersion: v1
kind: Service
metadata:
 name: istiod
 namespace: istio-system
 labels:
   istio.io/rev: asm-1104-6
   app: istiod
   istio: pilot
   release: istio
spec:
 ports:
   - port: 15010
     name: grpc-xds # plaintext
     protocol: TCP
   - port: 15012
     name: https-dns # mTLS with k8s-signed cert
     protocol: TCP
   - port: 443
     name: https-webhook # validation and injection
     targetPort: 15017
     protocol: TCP
   - port: 15014
     name: http-monitoring # prometheus stats
     protocol: TCP
 selector:
   app: istiod
   istio.io/rev: asm-1104-6
EOF1
kubectl apply -f istiod-service.yaml
EOF

```


Deploy and configure Knative:

Install Knative

Update Anthos Service Mesh configuration to add a new cluster-local-gateway


```bash
gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -ex
export clusterid=${cluster_name}
export KUBECONFIG=/root/bmctl-workspace/\$clusterid/\$clusterid-kubeconfig
export PATH="/root/istio-1.10.4-asm.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/serving-crds.yaml"
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/serving-core.yaml"
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/net-istio.yaml"
kubectl --namespace istio-system get service istio-ingressgateway
kubectl apply --filename "https://raw.githubusercontent.com/Redislabs-Solution-Architects/qwiklabs/master/Google/anthos-gke/serving-default-domain.yaml"
kubectl get pods --namespace knative-serving
cat > cluster.yaml <<EOF1
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: asm-multicloud
  revision: asm-1104-6
  values:
    global:
      meshID: asm-multicloud
      multiCluster:
        clusterName: $clusterid
      network: anthos-on-nucs-network
  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
      - name: cluster-local-gateway
        enabled: true
        label:
          istio: cluster-local-gateway
          app: cluster-local-gateway
        k8s:
          service:
            type: ClusterIP
            ports:
            - port: 15020
              name: status-port
            - port: 80
              targetPort: 8080
              name: http2
            - port: 443
              targetPort: 8443
              name: https
EOF1
istioctl install -f cluster.yaml -y
EOF

```

