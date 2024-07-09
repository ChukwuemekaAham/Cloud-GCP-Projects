Overview
In this lab, you learn to install Anthos Service Mesh (ASM) on Google Kubernetes Engine. Anthos Service Mesh is a managed service based on Istio, the leading open source service mesh.

A service mesh gives you a framework for connecting, securing, and managing microservices. It provides a networking layer on top of Kubernetes with features such as advanced load balancing capabilities, service-to-service authentication, and monitoring without requiring any changes in service code.

Anthos Service Mesh has a suite of additional features and tools that help you observe and manage secure, reliable services in a unified way. In this lab you also learn how to use some of these features:

Service metrics and logs for HTTP(S) traffic within your mesh's GKE cluster are automatically ingested to Google Cloud.
Preconfigured service dashboards give you the information you need to understand your services.
In-depth telemetry lets you dig deep into your metrics and logs, filtering and slicing your data on a wide variety of attributes.
Service-to-service relationships at a glance help you understand who connects to which service and the services that each service depends on.
Service-level objectives (SLOs) provide insights into the health of your services. You can easily define an SLO and alert on your own standards of service health.
Anthos Service Mesh is the easiest and richest way to implement an Istio-based service mesh on your Anthos clusters.

Objectives
In this lab, you learn how to perform the following tasks:

Install Anthos Service Mesh, with tracing enabled and configured to use Cloud Trace as the backend.

Deploy Bookinfo, an Istio-enabled multi-service application.

Enable external access using an Istio Ingress Gateway.

Use the Bookinfo application.

Evaluate service performance using Cloud Trace features within Google Cloud.

Create and monitor service-level objectives (SLOs).

Leverage the Anthos Service Mesh Dashboard to understand service performance.

Setup and requirements



$ printf '\nCLUSTER_NAME:'$CLUSTER_NAME'\nCLUSTER_ZONE:'$CLUSTER_ZONE'\nPROJECT_ID:'$PROJECT_ID'\nPROJECT_NUMBER:'$PROJECT_NUMBER'\nFLEET PROJECT_ID:'$FLEET_PROJECT_ID'\nIDNS:'$IDNS'\nDIR_PATH:'$DIR_PATH'\n'

CLUSTER_NAME:gke
CLUSTER_ZONE:us-central1-f
PROJECT_ID:qwiklabs-gcp-03-b44f0bd650a8
PROJECT_NUMBER:542668078087
FLEET PROJECT_ID:qwiklabs-gcp-03-b44f0bd650a8
IDNS:qwiklabs-gcp-03-b44f0bd650a8.svc.id.goog
DIR_PATH:.
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$

student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$  gcloud container clusters get-credentials $CLUSTER_NAME \
     --zone $CLUSTER_ZONE --project $PROJECT_ID
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke.
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://34.69.5.95
  name: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
contexts:
- context:
    cluster: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
    user: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
  name: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
current-context: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
kind: Config
preferences: {}
users:
- name: gke_qwiklabs-gcp-03-b44f0bd650a8_us-central1-f_gke
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args: null
      command: gke-gcloud-auth-plugin
      env: null
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      interactiveMode: IfAvailable
      provideClusterInfo: true
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$  gcloud container clusters list
NAME: gke
LOCATION: us-central1-f
MASTER_VERSION: 1.25.8-gke.500
MASTER_IP: 34.69.5.95
MACHINE_TYPE: e2-standard-2
NODE_VERSION: 1.25.8-gke.500
NUM_NODES: 3
STATUS: RUNNING
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$

student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$  gcloud container clusters list
NAME: gke
LOCATION: us-central1-f
MASTER_VERSION: 1.25.8-gke.500
MASTER_IP: 34.69.5.95
MACHINE_TYPE: e2-standard-2
NODE_VERSION: 1.25.8-gke.500
NUM_NODES: 3
STATUS: RUNNING
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ ^C
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ sudo curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 -o /usr/bin/asmcli && sudo chmod +x /usr/bin/asmcli
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  181k  100  181k    0     0   241k      0 --:--:-- --:--:-- --:--:--  241k
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$  asmcli install \
 --project_id $PROJECT_ID \
 --cluster_name $CLUSTER_NAME \
 --cluster_location $CLUSTER_ZONE \
 --fleet_id $FLEET_PROJECT_ID \
 --output_dir $DIR_PATH \
 --managed \
 --enable_all \
 --ca mesh_ca
asmcli: Setting up necessary files...
asmcli: Using /home/student_02_620b117f2125/asm_kubeconfig as the kubeconfig...
asmcli: Checking installation tool dependencies...
asmcli: Fetching/writing GCP credentials to kubeconfig file...
asmcli: [WARNING]: nc not found, skipping k8s connection verification
asmcli: [WARNING]: (Installation will continue normally.)
asmcli: Getting account information...
asmcli: Downloading kpt..
asmcli: Downloading ASM..
asmcli: Downloading ASM kpt package...
fetching package "/asm" from "https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages" to "asm"
fetching package "/samples" from "https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages" to "samples"
asmcli: Verifying cluster registration.
asmcli: Enabling required APIs...
asmcli: Enabling the service mesh feature...
asmcli: Verifying cluster registration.
asmcli: Binding user:student-02-620b117f2125@qwiklabs.net to required IAM roles...
asmcli: Registering the cluster as gke...
asmcli: Verifying cluster registration.
asmcli: Verified cluster is registered to qwiklabs-gcp-03-b44f0bd650a8
asmcli: Checking for project qwiklabs-gcp-03-b44f0bd650a8...
asmcli: Reading labels for us-central1-f/gke...
asmcli: Querying for core/account...
asmcli: Binding student-02-620b117f2125@qwiklabs.net to cluster admin role...
clusterrolebinding.rbac.authorization.k8s.io/student-02-620b117f2125-cluster-admin-binding created
asmcli: Creating istio-system namespace...
namespace/istio-system created
asmcli: Configuring kpt package...
asm/
set 16 field(s) of setter "gcloud.container.cluster" to value "gke"
asm/
set 19 field(s) of setter "gcloud.core.project" to value "qwiklabs-gcp-03-b44f0bd650a8"
asm/
set 2 field(s) of setter "gcloud.project.projectNumber" to value "542668078087"
asm/
set 16 field(s) of setter "gcloud.compute.location" to value "us-central1-f"
asm/
set 1 field(s) of setter "gcloud.compute.network" to value "qwiklabs-gcp-03-b44f0bd650a8-default"
asm/
set 3 field(s) of setter "gcloud.project.environProjectNumber" to value "542668078087"
asm/
set 2 field(s) of setter "anthos.servicemesh.rev" to value "asm-managed"
asm/
set 3 field(s) of setter "anthos.servicemesh.tag" to value "1.15.7-asm.8"
asm/
set 3 field(s) of setter "anthos.servicemesh.trustDomain" to value "qwiklabs-gcp-03-b44f0bd650a8.svc.id.goog"
asm/
set 1 field(s) of setter "anthos.servicemesh.tokenAudiences" to value "istio-ca,qwiklabs-gcp-03-b44f0bd650a8.svc.id.goog"
asm/
set 1 field(s) of setter "anthos.servicemesh.spiffeBundleEndpoints" to value "qwiklabs-gcp-03-b44f0bd650a8.svc.id.goog|https://storage.googleapis.com/mesh-ca-resources/spiffe_bundle.json"
asm/
set 3 field(s) of setter "anthos.servicemesh.created-by" to value "asmcli-1.15.7-asm.8.config1"
asm/
set 2 field(s) of setter "anthos.servicemesh.idp-url" to value "https://container.googleapis.com/v1/projects/qwiklabs-gcp-03-b44f0bd650a8/locations/us-central1-f/clusters/gke"
asm/
set 2 field(s) of setter "anthos.servicemesh.trustDomainAliases" to value "qwiklabs-gcp-03-b44f0bd650a8.svc.id.goog"
namespace/istio-system labeled
asmcli: Waiting for the controlplanerevisions CRD to be installed by AFC. This could take a few minutes if cluster is newly registered.
customresourcedefinition.apiextensions.k8s.io/controlplanerevisions.mesh.cloud.google.com condition met
asmcli: Applying mcp_configmap.yaml...
configmap/asm-options created
asmcli: Configuring ASM managed control plane revision CR for channels...
asmcli: Installing ASM Control Plane Revision CR with asm-managed channel in istio-system namespace...
controlplanerevision.mesh.cloud.google.com/asm-managed created
asmcli: Waiting for deployment...
controlplanerevision.mesh.cloud.google.com/asm-managed condition met
asmcli: 
asmcli: *****************************
1.15.7-asm.8
asmcli: *****************************
asmcli: The ASM control plane installation is now complete.
asmcli: To enable automatic sidecar injection on a namespace, you can use the following command:
asmcli: kubectl label namespace <NAMESPACE> istio-injection- istio.io/rev=asm-managed --overwrite
asmcli: If you use 'istioctl install' afterwards to modify this installation, you will need
asmcli: to specify the option '--set revision=asm-managed' to target this control plane
asmcli: instead of installing a new one.
asmcli: To finish the installation, enable Istio sidecar injection and restart your workloads.
asmcli: For more information, see:
asmcli: https://cloud.google.com/service-mesh/docs/proxy-injection
asmcli: The ASM package used for installation can be found at:
asmcli: /home/student_02_620b117f2125/asm
asmcli: The version of istioctl that matches the installation can be found at:
asmcli: /home/student_02_620b117f2125/istio-1.15.7-asm.8/bin/istioctl
asmcli: A symlink to the istioctl binary can be found at:
asmcli: /home/student_02_620b117f2125/istioctl
asmcli: *****************************
asmcli: Successfully installed ASM.
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$

Enable Anthos Service Mesh to send telemetry to Cloud Trace:

cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  mesh: |-
    defaultConfig:
      tracing:
        stackdriver: {}
kind: ConfigMap
metadata:
  name: istio-asm-managed
  namespace: istio-system
EOF

Warning: resource configmaps/istio-asm-managed is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/istio-asm-managed configured
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl get configmap
NAME               DATA   AGE
kube-root-ca.crt   1      3h46m
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$

Congratulations!

You now have a GKE cluster with Anthos Service Mesh installed. Kubernetes Metrics are being recorded to Cloud Monitoring, logs are being recorded to Cloud Logging, and distributed trace information is being sent to Cloud Trace.


## Install the microservices-demo application on the cluster
Online Boutique is a cloud-native microservices demo application. Online Boutique consists of a 10-tier microservices application. The application is a web-based ecommerce app where users can browse items, add them to the cart, and purchase them.

Google uses this application to demonstrate use of technologies like Kubernetes/GKE, Istio/ASM, Google Operations Suite, gRPC and OpenCensus. This application works on any Kubernetes cluster (such as a local one) and on Google Kubernetes Engine. It’s easy to deploy with little to no configuration.

For more information about the application, refer to the github repo https://github.com/GoogleCloudPlatform/microservices-demo



student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  mesh: |-
    defaultConfig:
      tracing:
        stackdriver: {}
kind: ConfigMap
metadata:
  name: istio-asm-managed
  namespace: istio-system
EOF
Warning: resource configmaps/istio-asm-managed is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/istio-asm-managed configured
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl get configmap
NAME               DATA   AGE
kube-root-ca.crt   1      3h46m
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ ^C
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl label namespace default istio.io/rev=asm-managed --overwrite
namespace/default labeled
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl annotate --overwrite namespace default \
  mesh.cloud.google.com/proxy='{"managed":"true"}'
namespace/default annotate
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml
deployment.apps/emailservice created
service/emailservice created
deployment.apps/checkoutservice created
service/checkoutservice created
deployment.apps/recommendationservice created
service/recommendationservice created
deployment.apps/frontend created
service/frontend created
service/frontend-external created
deployment.apps/paymentservice created
service/paymentservice created
deployment.apps/productcatalogservice created
service/productcatalogservice created
deployment.apps/cartservice created
service/cartservice created
deployment.apps/loadgenerator created
deployment.apps/currencyservice created
service/currencyservice created
deployment.apps/shippingservice created
service/shippingservice created
deployment.apps/redis-cart created
service/redis-cart created
deployment.apps/adservice created
service/adservice created
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'
deployment.apps/productcatalogservice patched
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ [200~git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages~
-bash: [200~git: command not found
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages
Cloning into 'anthos-service-mesh-packages'...
remote: Enumerating objects: 11110, done.
remote: Counting objects: 100% (515/515), done.
remote: Compressing objects: 100% (208/208), done.
remote: Total 11110 (delta 360), reused 446 (delta 306), pack-reused 10595
Receiving objects: 100% (11110/11110), 2.74 MiB | 11.50 MiB/s, done.
Resolving deltas: 100% (7554/7554), done.
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ ls
anthos-service-mesh-packages  asm_kubeconfig      istioctl  lib.zip       mcp_configmap.yaml     samples
asm                           istio-1.15.7-asm.8  kpt       LICENSES.txt  README-cloudshell.txt
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f anthos-service-mesh-packages/samples/gateways/istio-ingressgateway
deployment.apps/istio-ingressgateway created
poddisruptionbudget.policy/istio-ingressgateway created
role.rbac.authorization.k8s.io/istio-ingressgateway created
rolebinding.rbac.authorization.k8s.io/istio-ingressgateway created
service/istio-ingressgateway created
serviceaccount/istio-ingressgateway created
error: resource mapping not found for name: "istio-ingressgateway" namespace: "" from "anthos-service-mesh-packages/samples/gateways/istio-ingressgateway/autoscaling-v2beta1.yaml": no matches for kind "HorizontalPodAutoscaler" in version "autoscaling/v2beta1"
ensure CRDs are installed first
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml
serviceentry.networking.istio.io/allow-egress-googleapis created
serviceentry.networking.istio.io/allow-egress-google-metadata created
virtualservice.networking.istio.io/frontend created
resource mapping not found for name: "istio-gateway" namespace: "" from "https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml": no matches for kind "Gateway" in version "gateway.networking.k8s.io/v1beta1"
ensure CRDs are installed first
resource mapping not found for name: "frontend-route" namespace: "" from "https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml": no matches for kind "HTTPRoute" in version "gateway.networking.k8s.io/v1beta1"
ensure CRDs are installed first
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl get deployments
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
adservice               1/1     1            1           9m42s
cartservice             1/1     1            1           9m44s
checkoutservice         1/1     1            1           9m47s
currencyservice         1/1     1            1           9m44s
emailservice            1/1     1            1           9m48s
frontend                1/1     1            1           9m46s
istio-ingressgateway    3/3     3            3           8m19s
loadgenerator           1/1     1            1           9m44s
paymentservice          1/1     1            1           9m45s
productcatalogservice   1/1     1            1           9m45s
recommendationservice   1/1     1            1           9m46s
redis-cart              1/1     1            1           9m43s
shippingservice         1/1     1            1           9m43s
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)

student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl get services 
NAME                    TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
adservice               ClusterIP      10.56.2.199    <none>           9555/TCP                                     10m
cartservice             ClusterIP      10.56.2.244    <none>           7070/TCP                                     10m
checkoutservice         ClusterIP      10.56.7.97     <none>           5050/TCP                                     10m
currencyservice         ClusterIP      10.56.15.3     <none>           7000/TCP                                     10m
emailservice            ClusterIP      10.56.4.247    <none>           5000/TCP                                     10m
frontend                ClusterIP      10.56.1.201    <none>           80/TCP                                       10m
frontend-external       LoadBalancer   10.56.14.243   34.132.85.57     80:30442/TCP                                 10m
istio-ingressgateway    LoadBalancer   10.56.6.30     34.122.246.112   15021:32643/TCP,80:30571/TCP,443:31983/TCP   9m27s
kubernetes              ClusterIP      10.56.0.1      <none>           443/TCP                                      4h2m
paymentservice          ClusterIP      10.56.11.150   <none>           50051/TCP                                    10m
productcatalogservice   ClusterIP      10.56.3.93     <none>           3550/TCP                                     10m
recommendationservice   ClusterIP      10.56.14.10    <none>           8080/TCP                                     10m
redis-cart              ClusterIP      10.56.15.156   <none>           6379/TCP                                     10m
shippingservice         ClusterIP      10.56.10.231   <none>           50051/TCP                                    10m
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$


student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ git clone https://github.com/GoogleCloudPlatform/istio-samples.git \
  ~/istio-samples
Cloning into '/home/student_02_620b117f2125/istio-samples'...
remote: Enumerating objects: 1737, done.
remote: Counting objects: 100% (210/210), done.
remote: Compressing objects: 100% (142/142), done.
remote: Total 1737 (delta 104), reused 146 (delta 67), pack-reused 1527
Receiving objects: 100% (1737/1737), 22.04 MiB | 7.39 MiB/s, done.
Resolving deltas: 100% (863/863), done.
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ ls
anthos-service-mesh-packages  asm_kubeconfig      istioctl       kpt      LICENSES.txt        README-cloudshell.txt
asm                           istio-1.15.7-asm.8  istio-samples  lib.zip  mcp_configmap.yaml  samples
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ git clone https://github.com/GoogleCloudPlatform/istio-samples.git   ~/istio-sampleskubectl apply -f ~/istio-samples/istio-canary-gke/canary/destinationrule.yaml^C
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f ~/istio-samples/istio-canary-gke/canary/destinationrule.yaml
destinationrule.networking.istio.io/productcatalogservice created
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f ~/istio-samples/istio-canary-gke/canary/productcatalog-v2.yaml
deployment.apps/productcatalogservice-v2 created
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ kubectl apply -f ~/istio-samples/istio-canary-gke/canary/vs-split-traffic.yaml
virtualservice.networking.istio.io/productcatalogservice created
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$ ^C
student_02_620b117f2125@cloudshell:~ (qwiklabs-gcp-03-b44f0bd650a8)$

