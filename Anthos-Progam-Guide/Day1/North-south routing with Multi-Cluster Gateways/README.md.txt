Overview
Introduction
This lab shows you how to enable, use and deploy the multi-cluster GKE Gateway controller, a Google-hosted controller that provisions external and internal load balancers, which balance traffic across multiple Kubernetes clusters.

In GKE the gke-l7-gxlb-mc and gke-l7-rilb-mc GatewayClasses deploy multi-cluster Gateways that provide HTTP routing, traffic splitting, traffic mirroring, health-based failover, and more across different GKE clusters, Kubernetes Namespaces, and across different regions. Multi-cluster Gateways make managing application networking across many clusters and teams easy, secure, and scalable for infrastructure administrators.

Objectives
In this lab, you will learn how to perform the following tasks:

Register GKE clusters to an Anthos Fleet

Enable and configure Multi-cluster Services (MCS)

Enable and configure Multi-clusster Gateways (MCG)

Deploy a distributed application and balance traffic accross clusters




Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to qwiklabs-gcp-02-bc33dbb79675.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ export PROJECT_ID=$(gcloud config get-value project)
Your active configuration is: [cloudshell-2307]
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ export PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" \
  --format "value(projectNumber)")
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ WEST1_LOCATION=us-west2-c
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ WEST2_LOCATION=us-west2-c
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ EAST1_LOCATION=us-central1-c
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container clusters get-credentials gke-west-2 --zone=${WEST2_LOCATION} --project=${PROJECT_ID}
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container clusters get-credentials gke-east-1 --zone=${EAST1_LOCATION}  --project=${PROJECT_ID}
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke-east-1.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container clusters get-credentials gke-west-1 --zone=${WEST1_LOCA
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke-west-1.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ 
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ kubectl config rename-context gke_${PROJECT_ID}_${EAST1_LOCATION}_gke-east-1 gke-east-1
Context "gke_qwiklabs-gcp-02-bc33dbb79675_us-central1-c_gke-east-1" renamed to "gke-east-1".
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ kubectl config rename-context gke_${PROJECT_ID}_${WEST1_LOCATION}_gke-west-1 gke-west-1
Context "gke_qwiklabs-gcp-02-bc33dbb79675_us-west2-c_gke-west-1" renamed to "gke-west-1".
 --enable-workload-identity \
 --project=${PROJECT_ID}
Waiting for membership to be created...done.                                                                                                
Finished registering to the Fleet.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$  gcloud container fleet memberships register gke-west-2 \
    --gke-cluster ${WEST2_LOCATION}/gke-west-2 \
    --enable-workload-identity \
    --project=${PROJECT_ID}
Waiting for membership to be created...done.                                                                                                
Finished registering to the Fleet.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet memberships register gke-east-1 \
    --gke-cluster ${EAST1_LOCATION}/gke-east-1 \
    --enable-workload-identity \
    --project=${PROJECT_ID}
Waiting for membership to be created...done.                                                                                                
Finished registering to the Fleet.
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet memberships list --project=${PROJECT_ID}
NAME: gke-east-1
EXTERNAL_ID: 78e65be3-88da-4901-9b96-464635d893c5
LOCATION: us-central1

NAME: gke-west-2
EXTERNAL_ID: 8eb5f487-0029-4edd-ada1-6b307aa60728
LOCATION: us-west2

LOCATION: us-west2
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet multi-cluster-services enable \
--project ${PROJECT_ID}
Waiting for Feature Multi-cluster Services to be created...done.                                                                            
 --role "roles/compute.networkViewer" \
 --project=${PROJECT_ID}
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-1020590709424@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:qwiklabs-gcp-02-bc33dbb79675.svc.id.goog[gke-mcs/gke-mcs-importer]
  role: roles/compute.networkViewer
- members:
  - serviceAccount:service-1020590709424@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-1020590709424@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:1020590709424-compute@developer.gserviceaccount.com
  - serviceAccount:1020590709424@cloudservices.gserviceaccount.com
  role: roles/editor
- members:
  - serviceAccount:service-1020590709424@gcp-sa-gkehub.iam.gserviceaccount.com
  role: roles/gkehub.serviceAgent
- members:
  - serviceAccount:service-1020590709424@gcp-sa-mcmetering.iam.gserviceaccount.com
  role: roles/multiclustermetering.serviceAgent
- members:
  - serviceAccount:service-1020590709424@gcp-sa-mcsd.iam.gserviceaccount.com
  role: roles/multiclusterservicediscovery.serviceAgent
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-02-bc33dbb79675@qwiklabs-gcp-02-bc33dbb79675.iam.gserviceaccount.com
  - user:student-02-566c8595f581@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-02-bc33dbb79675@qwiklabs-gcp-02-bc33dbb79675.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-02-566c8595f581@qwiklabs.net
  role: roles/storage.objectViewer
- members:
  - user:student-02-566c8595f581@qwiklabs.net
  role: roles/viewer
etag: BwX72pD8Xl0=
version: 1
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet multi-cluster-services describe --project=${PROJECT_ID}
createTime: '2023-05-17T02:34:28.873145457Z'
membershipStates:
  projects/1020590709424/locations/us-central1/memberships/gke-east-1:
    state:
      code: OK
      description: Firewall successfully updated
      updateTime: '2023-05-17T02:35:27.862503962Z'
  projects/1020590709424/locations/us-west2/memberships/gke-west-1:
      description: Firewall successfully updated
      updateTime: '2023-05-17T02:35:28.625775814Z'
  projects/1020590709424/locations/us-west2/memberships/gke-west-2:
    state:
      code: OK
      description: Firewall successfully updated
      updateTime: '2023-05-17T02:35:27.081272463Z'
name: projects/qwiklabs-gcp-02-bc33dbb79675/locations/global/features/multiclusterservicediscovery
resourceState:
  state: ACTIVE
spec: {}
updateTime: '2023-05-17T02:35:29.206693334Z'
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" \
| kubectl apply -f - --context=gke-west-1
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$



student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" \
| kubectl apply -f - --context=gke-west-1
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ ^C
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet ingress enable \
  --config-membership=gke-west-1 \
  --project=${PROJECT_ID} \
  --location=us-west2
Waiting for Feature Ingress to be created...done.                                                                                           
Waiting for controller to start......done.                                                                                                  
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$ gcloud container fleet ingress describe --project=${PROJECT_ID}
createTime: '2023-05-17T02:43:53.510006480Z'
membershipStates:
  projects/1020590709424/locations/us-central1/memberships/gke-east-1:
    state:
      code: OK
      updateTime: '2023-05-17T02:45:35.243916120Z'
  projects/1020590709424/locations/us-west2/memberships/gke-west-1:
    state:
      code: OK
      updateTime: '2023-05-17T02:45:35.243913980Z'
  projects/1020590709424/locations/us-west2/memberships/gke-west-2:
    state:
      code: OK
      updateTime: '2023-05-17T02:45:35.243915287Z'
name: projects/qwiklabs-gcp-02-bc33dbb79675/locations/global/features/multiclusteringress
resourceState:
  state: ACTIVE
spec:
  multiclusteringress:
    configMembership: projects/qwiklabs-gcp-02-bc33dbb79675/locations/us-west2/memberships/gke-west-1
state:
  state:
    code: OK
    description: Ready to use
    updateTime: '2023-05-17T02:45:35.133159166Z'
updateTime: '2023-05-17T02:45:36.840074420Z'
student_02_566c8595f581@cloudshell:~ (qwiklabs-gcp-02-bc33dbb79675)$



Deploy the Gateway and HTTPRoutes
Gateway and HTTPRoutes are resources deployed in the Config cluster, which in this case is the gke-west-1 cluster.

Platform administrators manage and deploy Gateways to centralize security policies such as TLS.

Service Owners in different teams deploy HTTPRoutes in their own namespace so that they can independently control their routing logic.