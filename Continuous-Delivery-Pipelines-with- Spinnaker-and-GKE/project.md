# Objectives

- Set up your environment by launching Google Cloud Shell, creating a Kubernetes Engine cluster, and configuring your identity and user management scheme.
- Download a sample application, create a Git repository then upload it to a Google Cloud Source Repository.
- Deploy Spinnaker to Kubernetes Engine using Helm.
- Build your Docker image.
- Create triggers to create Docker images when your application changes.
- Configure a Spinnaker pipeline to reliably and continuously deploy your application to Kubernetes Engine.
- Deploy a code change, triggering the pipeline, and watch it roll out to production.

# Pipeline architecture
To continuously deliver application updates to your users, you need an automated process that reliably builds, tests, and updates your software. Code changes should automatically flow through a pipeline that includes artifact creation, unit testing, functional testing, and production rollout. In some cases, you want a code update to apply to only a subset of your users, so that it is exercised realistically before you push it to your entire user base. If one of these canary releases proves unsatisfactory, your automated procedure must be able to quickly roll back the software changes.

img

With Kubernetes Engine and Spinnaker you can create a robust continuous delivery flow that helps to ensure your software is shipped as quickly as it is developed and validated. Although rapid iteration is your end goal, you must first ensure that each application revision passes through a gamut of automated validations before becoming a candidate for production rollout. When a given change has been vetted through automation, you can also validate the application manually and conduct further pre-release testing.

After your team decides the application is ready for production, one of your team members can approve it for production deployment.


Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to qwiklabs-gcp-00-590ac91686ca.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud config set compute/zone us-east1-d
Updated property [compute/zone].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud container clusters create spinnaker-tutorial \
    --machine-type=n1-standard-2
Default change: VPC-native is the default mode during cluster creation for versions greater than 1.21.0-gke.1500. To create advanced routes based clusters, please pass the `--no-enable-ip-alias` flag
Default change: During creation of nodepools or autoscaling configuration changes for cluster versions greater than 1.24.1-gke.800 a default location policy is applied. For Spot and PVM it defaults to ANY, and for all other VM kinds a BALANCED policy is used. To change the default values use the `--location-policy` flag.
Note: Your Pod address range (`--cluster-ipv4-cidr`) can accommodate at most 1008 node(s).
Creating cluster spinnaker-tutorial in us-east1-d... Cluster is being health-checked...working.   


Created [https://container.googleapis.com/v1/projects/qwiklabs-gcp-00-590ac91686ca/zones/us-east1-d/clusters/spinnaker-tutorial].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-east1-d/spinnaker-tutorial?project=qwiklabs-gcp-00-590ac91686ca
kubeconfig entry generated for spinnaker-tutorial.
NAME: spinnaker-tutorial
LOCATION: us-east1-d
MASTER_VERSION: 1.27.3-gke.100
MASTER_IP: 34.74.182.197
MACHINE_TYPE: n1-standard-2s
NODE_VERSION: 1.27.3-gke.100
NUM_NODES: 3
STATUS: RUNNING


student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud iam service-accounts create spinnaker-account \
    --display-name spinnaker-account
Created service account [spinnaker-account].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" \
    --format='value(email)')
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export PROJECT=$(gcloud info --format='value(config.project)')

student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin \
    --member serviceAccount:$SA_EMAIL

Updated IAM policy for project [qwiklabs-gcp-00-590ac91686ca].
bindings:
- members:
  - serviceAccount:qwiklabs-gcp-00-590ac91686ca@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  role: roles/bigquery.admin
- members:
  - serviceAccount:944208407196@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-944208407196@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-944208407196@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-944208407196@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:service-944208407196@containerregistry.iam.gserviceaccount.com
  role: roles/containerregistry.ServiceAgent
- members:
  - serviceAccount:944208407196-compute@developer.gserviceaccount.com
  - serviceAccount:944208407196@cloudservices.gserviceaccount.com
  role: roles/editor
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-00-590ac91686ca@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  - user:student-00-0bd1394ea1e0@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-00-590ac91686ca@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  - serviceAccount:spinnaker-account@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-00-0bd1394ea1e0@qwiklabs.net
  role: roles/viewer
etag: BwYHqh7sD4A=
version: 1
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud iam service-accounts keys create spinnaker-sa.json \
     --iam-account $SA_EMAIL
created key [6ae54262b7effeaf8ab3992183ba1eac8164c5cb] of type [json] as [spinnaker-sa.json] for [spinnaker-account@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com]
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud pubsub topics create projects/$PROJECT/topics/gcr
Created topic [projects/qwiklabs-gcp-00-590ac91686ca/topics/gcr].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud pubsub subscriptions create gcr-triggers \
    --topic projects/${PROJECT}/topics/gcr
Created subscription [projects/qwiklabs-gcp-00-590ac91686ca/subscriptions/gcr-triggers].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" \
    --format='value(email)')
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud beta pubsub subscriptions add-iam-policy-binding gcr-triggers \
    --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL
Updated IAM policy for subscription [gcr-triggers].
bindings:
- members:
  - serviceAccount:spinnaker-account@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  role: roles/pubsub.subscriber
etag: BwYHqimnPas=
version: 1
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$

student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud iam service-accounts keys create spinnaker-sa.json \
     --iam-account $SA_EMAIL
created key [6ae54262b7effeaf8ab3992183ba1eac8164c5cb] of type [json] as [spinnaker-sa.json] for [spinnaker-account@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com]
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud pubsub topics create projects/$PROJECT/topics/gcr
Created topic [projects/qwiklabs-gcp-00-590ac91686ca/topics/gcr].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud pubsub subscriptions create gcr-triggers \
    --topic projects/${PROJECT}/topics/gcr
Created subscription [projects/qwiklabs-gcp-00-590ac91686ca/subscriptions/gcr-triggers].
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:spinnaker-account" \
    --format='value(email)')
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gcloud beta pubsub subscriptions add-iam-policy-binding gcr-triggers \
    --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL
Updated IAM policy for subscription [gcr-triggers].
bindings:
- members:
  - serviceAccount:spinnaker-account@qwiklabs-gcp-00-590ac91686ca.iam.gserviceaccount.com
  role: roles/pubsub.subscriber
etag: BwYHqimnPas=
version: 1
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$(gcloud config get-value account)
Your active configuration is: [cloudshell-18382]
clusterrolebinding.rbac.authorization.k8s.io/user-admin-binding created
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ kubectl create clusterrolebinding --clusterrole=cluster-admin \
    --serviceaccount=default:default spinnaker-admin
clusterrolebinding.rbac.authorization.k8s.io/spinnaker-admin created
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ helm repo add stable https://charts.helm.sh/stable
helm repo update
"stable" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈Happy Helming!⎈
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export PROJECT=$(gcloud info \
    --format='value(config.project)')
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export BUCKET=$PROJECT-spinnaker-config
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gsutil mb -c regional -l us-east1 gs://$BUCKET
Creating gs://qwiklabs-gcp-00-590ac91686ca-spinnaker-config/...
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$


student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export SA_JSON=$(cat spinnaker-sa.json)
export PROJECT=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT-spinnaker-config
cat > spinnaker-config.yaml <<EOF
gcs:
  enabled: true
  bucket: $BUCKET
  project: $PROJECT
  jsonKey: '$SA_JSON'
dockerRegistries:
- name: gcr
  address: https://gcr.io
  username: _json_key
  password: '$SA_JSON'
  email: 1234@5678.com
# Disable minio as the default storage backend
minio:
  enabled: false
# Configure Spinnaker to enable GCP services
halyard:
  spinnakerVersion: 1.19.4
  image:
    repository: us-docker.pkg.dev/spinnaker-community/docker/halyard
    tag: 1.32.0
    pullSecrets: []
  additionalScripts:
    create: true
    data:
      enable_gcs_artifacts.sh: |-
        \$HAL_COMMAND config artifact gcs account add gcs-$PROJECT --json-path /opt/gcs/key.json
        \$HAL_COMMAND config artifact gcs enable
      enable_pubsub_triggers.sh: |-
EOF       --message-format GCR/key.json \s \ubscription add gcr-triggers \
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ls
README-cloudshell.txt  spinnaker-config.yaml  spinnaker-sa.json
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$


student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ls
README-cloudshell.txt  spinnaker-config.yaml  spinnaker-sa.json
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ helm install -n default cd stable/spinnaker -f spinnaker-config.yaml \
           --version 2.0.0-rc9 --timeout 10m0s --wait
NAME: cd
LAST DEPLOYED: Sat Oct 14 10:05:32 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. You will need to create 2 port forwarding tunnels in order to access the Spinnaker UI:
  export DECK_POD=$(kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward --namespace default $DECK_POD 9000

  export GATE_POD=$(kubectl get pods --namespace default -l "cluster=spin-gate" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward --namespace default $GATE_POD 8084

2. Visit the Spinnaker UI by opening your browser to: http://127.0.0.1:9000

To customize your Spinnaker installation. Create a shell in your Halyard pod:

  kubectl exec --namespace default -it cd-spinnaker-halyard-0 bash

For more info on using Halyard to customize your installation, visit:
  https://www.spinnaker.io/reference/halyard/

For more info on the Kubernetes integration for Spinnaker, visit:
  https://www.spinnaker.io/reference/providers/kubernetes-v2/
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 


student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ export DECK_POD=$(kubectl get pods --namespace default -l "cluster=spin-deck" \
    -o jsonpath="{.items[0].metadata.name}")
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ kubectl port-forward --namespace default $DECK_POD 8080:9000 >> /dev/null &
[1] 1312
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gsutil -m cp -r gs://spls/gsp114/sample-app.tar .
Copying gs://spls/gsp114/sample-app.tar...
- [1/1 files][824.7 KiB/824.7 KiB] 100% Done                                    
Operation completed over 1 objects/824.7 KiB.                                    
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 


student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ gsutil -m cp -r gs://spls/gsp114/sample-app.tar .
Copying gs://spls/gsp114/sample-app.tar...
- [1/1 files][824.7 KiB/824.7 KiB] 100% Done                                    
Operation completed over 1 objects/824.7 KiB.                                    
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ ls
README-cloudshell.txt  sample-app.tar  spinnaker-config.yaml  spinnaker-sa.json
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ mkdir sample-app
tar xvf sample-app.tar -C ./sample-app
./
./.dockerignore
./cloudbuild.yaml
./pkg/
./pkg/stackdriver/
./pkg/stackdriver/monitoring.go
./docs/
./docs/img/
./docs/img/image19.png
./docs/img/image16.png
./docs/img/image23.png
./docs/img/image17.png
./docs/img/image10.png
./docs/img/image1.png
./docs/img/image22.png
./docs/img/image20.png
./docs/img/image6.png
./docs/img/image7.png
./docs/img/image13.png
./docs/img/image24.png
./docs/img/image2.png
./docs/img/image14.png
./docs/img/image15.png
./docs/img/image25.png
./docs/img/image3.png
./docs/img/image11.png
./docs/img/image8.png
./docs/img/image12.png
./docs/img/image9.png
./docs/img/image5.png
./docs/img/image4.png
./docs/img/info_card.png
./docs/img/image21.png
./docs/img/image18.png
./spinnaker/
./spinnaker/pipeline-deploy.json
./cmd/
./cmd/gke-info/
./cmd/gke-info/html.go
./cmd/gke-info/transport.go
./cmd/gke-info/stackdriver.go
./cmd/gke-info/common-service.go
./cmd/gke-info/main.go
./cmd/gke-info/messages.go
./glide.yaml
./glide.lock
./CONTRIBUTING.md
./.gitignore
./k8s/
./k8s/services/
./k8s/services/sample-backend-canary.yaml
./k8s/services/sample-frontend-prod.yaml
./k8s/services/sample-backend-prod.yaml
./k8s/services/sample-frontend-canary.yaml
./k8s/deployments/
./k8s/deployments/sample-frontend-production.yaml
./k8s/deployments/sample-backend-canary.yaml
./k8s/deployments/sample-backend-production.yaml
./k8s/deployments/sample-frontend-canary.yaml
./README.md
./pipeline.json
./LICENSE
./tests/
./tests/pipelines/
./tests/pipelines/spinnaker-tutorial-prs.yaml
./tests/pipelines/spinnaker-tutorial.yaml
./tests/tasks/
./tests/tasks/install-spinnaker.yaml
./tests/tasks/build-gke-info.yaml
./tests/scripts/
./tests/scripts/cleanup.sh
./tests/scripts/install-spinnaker.sh
./Dockerfile
./Jenkinsfile
./labs/
./labs/triggering-deployments.md
./labs/installing-spinnaker.md
./labs/building-container-images.md
./labs/creating-your-pipeline.md
./labs/workshop-cleanup.md
./labs/workshop-setup.md
student_00_0bd1394ea1e0@cloudshell:~ (qwiklabs-gcp-00-590ac91686ca)$ cd sample-app
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git config --global user.email "$(gcloud config get-value core/account)"
Your active configuration is: [cloudshell-18382]
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git config --global user.name "[USERNAME]"
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: is subject to change. To configure the initial branch name to use in all
hint: of your new repositories, which will suppress this warning, call:
hint: 
hint:   git config --global init.defaultBranch <name>
hint: 
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint: 
hint:   git branch -m <name>
Initialized empty Git repository in /home/student_00_0bd1394ea1e0/sample-app/.git/
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git add .
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git commit -m "Initial commit"
[master (root-commit) 618b978] Initial commit
 65 files changed, 2855 insertions(+)
 create mode 100644 .dockerignore
 create mode 100644 .gitignore
 create mode 100644 CONTRIBUTING.md
 create mode 100644 Dockerfile
 create mode 100644 Jenkinsfile
 create mode 100644 LICENSE
 create mode 100644 README.md
 create mode 100644 cloudbuild.yaml
 create mode 100644 cmd/gke-info/common-service.go
 create mode 100644 cmd/gke-info/html.go
 create mode 100644 cmd/gke-info/main.go
 create mode 100644 cmd/gke-info/messages.go
 create mode 100644 cmd/gke-info/stackdriver.go
 create mode 100644 cmd/gke-info/transport.go
 create mode 100644 docs/img/image1.png
 create mode 100644 docs/img/image10.png
 create mode 100644 docs/img/image11.png
 create mode 100644 docs/img/image12.png
 create mode 100644 docs/img/image13.png
 create mode 100644 docs/img/image14.png
 create mode 100644 docs/img/image15.png
 create mode 100644 docs/img/image16.png
 create mode 100644 docs/img/image17.png
 create mode 100644 docs/img/image18.png
 create mode 100644 docs/img/image19.png
 create mode 100644 docs/img/image2.png
 create mode 100644 docs/img/image20.png
 create mode 100644 docs/img/image21.png
 create mode 100644 docs/img/image22.png
 create mode 100644 docs/img/image23.png
 create mode 100644 docs/img/image24.png
 create mode 100644 docs/img/image25.png
 create mode 100644 docs/img/image3.png
 create mode 100644 docs/img/image4.png
 create mode 100644 docs/img/image5.png
 create mode 100644 docs/img/image6.png
 create mode 100644 docs/img/image7.png
 create mode 100644 docs/img/image8.png
 create mode 100644 docs/img/image9.png
 create mode 100644 docs/img/info_card.png
 create mode 100644 glide.lock
 create mode 100644 glide.yaml
 create mode 100644 k8s/deployments/sample-backend-canary.yaml
 create mode 100644 k8s/deployments/sample-backend-production.yaml
 create mode 100644 k8s/deployments/sample-frontend-canary.yaml
 create mode 100644 k8s/deployments/sample-frontend-production.yaml
 create mode 100644 k8s/services/sample-backend-canary.yaml
 create mode 100644 k8s/services/sample-backend-prod.yaml
 create mode 100644 k8s/services/sample-frontend-canary.yaml
 create mode 100644 k8s/services/sample-frontend-prod.yaml
 create mode 100644 labs/building-container-images.md
 create mode 100644 labs/creating-your-pipeline.md
 create mode 100644 labs/installing-spinnaker.md
 create mode 100644 labs/triggering-deployments.md
 create mode 100644 labs/workshop-cleanup.md
 create mode 100644 labs/workshop-setup.md
 create mode 100644 pipeline.json
 create mode 100644 pkg/stackdriver/monitoring.go
 create mode 100644 spinnaker/pipeline-deploy.json
 create mode 100644 tests/pipelines/spinnaker-tutorial-prs.yaml
 create mode 100644 tests/pipelines/spinnaker-tutorial.yaml
 create mode 100755 tests/scripts/cleanup.sh
 create mode 100755 tests/scripts/install-spinnaker.sh
 create mode 100644 tests/tasks/build-gke-info.yaml
 create mode 100644 tests/tasks/install-spinnaker.yaml
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ gcloud source repos create sample-app
Created [sample-app].
WARNING: You may be billed for this repository. See https://cloud.google.com/source-repositories/docs/pricing for details.
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$

student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ gcloud source repos create sample-app
Created [sample-app].
WARNING: You may be billed for this repository. See https://cloud.google.com/source-repositories/docs/pricing for details.
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$  git config credential.helper gcloud.sh
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ export PROJECT=$(gcloud info --format='value(config.project)')student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git remote add origin https://source.developers.google.com/p/$PROJECT/r/sample-app
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git push origin master
Enumerating objects: 82, done.
Counting objects: 100% (82/82), done.
Delta compression using up to 2 threads
Compressing objects: 100% (75/75), done.
Writing objects: 100% (82/82), 822.04 KiB | 13.26 MiB/s, done.
Total 82 (delta 8), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (8/8)
remote: Waiting for private key checker: 27/65 objects left
To https://source.developers.google.com/p/qwiklabs-gcp-00-590ac91686ca/r/sample-app
 * [new branch]      master -> master
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$



student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ export PROJECT=$(gcloud info --format='value(config.project)')student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ gsutil mb -l us-east1 gs://$PROJECT-kubernetes-manifests
Creating gs://qwiklabs-gcp-00-590ac91686ca-kubernetes-manifests/...
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ gsutil versioning set on gs://$PROJECT-kubernetes-manifests
Enabling versioning for gs://qwiklabs-gcp-00-590ac91686ca-kubernetes-manifests/...
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ sed -i s/PROJECT/$PROJECT/g k8s/deployments/*
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git commit -a -m "Set project ID"
[master a9747c7] Set project ID
 4 files changed, 4 insertions(+), 4 deletions(-)
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 

student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git tag v1.0.0
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git push --tags
Enumerating objects: 14, done.
Counting objects: 100% (14/14), done.
Delta compression using up to 2 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 780 bytes | 390.00 KiB/s, done.
Total 8 (delta 5), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (5/5)
remote: Waiting for private key checker: 4/4 objects left
To https://source.developers.google.com/p/qwiklabs-gcp-00-590ac91686ca/r/sample-app
 * [new tag]         v1.0.0 -> v1.0.0
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 

student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/1.14.0/linux/amd64/spin
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13.5M  100 13.5M    0     0  13.2M      0  0:00:01  0:00:01 --:--:-- 13.2M
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ chmod +x spin
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ ./spin application save --application-name sample \
                        --owner-email "$(gcloud config get-value core/account)" \
                        --cloud-providers kubernetes \
                        --gate-endpoint http://localhost:8080/gate
Your active configuration is: [cloudshell-18382]
Application save succeeded
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 

student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ export PROJECT=$(gcloud info --format='value(config.project)') 
sed s/PROJECT/$PROJECT/g spinnaker/pipeline-deploy.json > pipeline.json
./spin pipeline save --gate-endpoint http://localhost:8080/gate -f pipeline.json
Pipeline save succeeded
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$


student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ ^C
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ sed -i 's/orange/blue/g' cmd/gke-info/common-service.go
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git commit -a -m "Change color to blue"
[master 9e53e00] Change color to blue
 2 files changed, 39 insertions(+), 39 deletions(-)
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git tag v1.0.1
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git push --tags
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 2 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 794 bytes | 794.00 KiB/s, done.
Total 6 (delta 4), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (4/4)
remote: Waiting for private key checker: 2/2 objects left
To https://source.developers.google.com/p/qwiklabs-gcp-00-590ac91686ca/r/sample-app
 * [new tag]         v1.0.1 -> v1.0.1
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)


student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git revert v1.0.1
[master 2bc293b] Revert "Change color to blue"
 2 files changed, 39 insertions(+), 39 deletions(-)
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git tag v1.0.2
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ git push --tags
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 2 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 817 bytes | 408.00 KiB/s, done.
Total 6 (delta 4), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (4/4)
remote: Waiting for private key checker: 2/2 objects left
To https://source.developers.google.com/p/qwiklabs-gcp-00-590ac91686ca/r/sample-app
 * [new tag]         v1.0.2 -> v1.0.2
student_00_0bd1394ea1e0@cloudshell:~/sample-app (qwiklabs-gcp-00-590ac91686ca)$ 



