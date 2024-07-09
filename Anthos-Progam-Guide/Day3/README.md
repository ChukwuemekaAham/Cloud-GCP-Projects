Overview
In this lab you will learn how to create Compute Engine VMs on Google Cloud with L2 connectivity through the use of vxlan built-in functionality in Linux. You'll be using the Compute Engine VMs to simulate Anthos on Bare Metal (BM) in high-availability mode which requires L2 connectivity. The deployment will consist of 4 VMs to deploy Anthos on BM, 1 x workstation, 1 x control plane nodes and 2 x worker nodes. Then you'll install Anthos Service Mesh and Knative on the BM cluster, followed by deploying Redis Enterprise for GKE and a Serverless application. Finally, this guide will show you how to run a simple load test on the serverless application to realize the elasticity of Knative backed by a Redis datastore.

What you'll learn
In this lab, you will:

Create an Anthos bare metal cluster

Install Anthos service mesh and Knative

Deploy Redis Enterprise cluster

Create a Redis Enterprise database

Create a Knative serverless service (incrementing a Redis counter)

Run a load test against the Knative serverless application


Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to qwiklabs-gcp-01-2fc31c8b782a.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ export PROJECT_ID=$(gcloud config get-value project)
Your active configuration is: [cloudshell-6771]
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ export ZONE=us-central1-a
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ export service_account="baremetal-gcr"
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ export cluster_name=anthos-bm-cluster-1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud iam service-accounts create baremetal-gcrgcloud iam service-accounts create baremetal-gcr^C
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud iam service-accounts create baremetal-gcr
Created service account [baremetal-gcr].
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud iam service-accounts keys create bm-gcr.json \
--iam-account=baremetal-gcr@${PROJECT_ID}.iam.gserviceaccount.com
created key [de50f2b810eff63b6e5ab83161e41b7a6621abff] of type [json] as [bm-gcr.json] for [baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com]
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ ls
bm-gcr.json  README-cloudshell.txt
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud services enable \
    anthos.googleapis.com \
    anthosaudit.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    connectgateway.googleapis.com \
    opsconfigmonitoring.googleapis.com
Operation "operations/acat.p2-184725217604-1078adf7-dd32-4986-939f-17550ee2820d" finished successfully.
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YWj8o84=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.admin"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YWo_-p4=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/logging.logWriter"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/logging.logWriter
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YWtRLfk=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/logging.logWriter
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.metricWriter
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YWx4zYM=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/monitoring.dashboardEditor"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/logging.logWriter
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.dashboardEditor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.metricWriter
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YW3BW7o=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/stackdriver.resourceMetadata.writer"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/logging.logWriter
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.dashboardEditor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.metricWriter
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/stackdriver.resourceMetadata.writer
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YW7DCsE=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/opsconfigmonitoring.resourceMetadata.writer"
Updated IAM policy for project [qwiklabs-gcp-01-2fc31c8b782a].
bindings:
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/appengine.appAdmin
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/bigquery.admin
- members:
  - serviceAccount:184725217604@cloudbuild.gserviceaccount.com
  role: roles/cloudbuild.builds.builder
- members:
  - serviceAccount:service-184725217604@gcp-sa-cloudbuild.iam.gserviceaccount.com
  role: roles/cloudbuild.serviceAgent
- members:
  - serviceAccount:service-184725217604@compute-system.iam.gserviceaccount.com
  role: roles/compute.serviceAgent
- members:
  - serviceAccount:service-184725217604@container-engine-robot.iam.gserviceaccount.com
  role: roles/container.serviceAgent
- members:
  - serviceAccount:184725217604-compute@developer.gserviceaccount.com
  - serviceAccount:184725217604@cloudservices.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/editor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.admin
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/gkehub.connect
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/logging.logWriter
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.dashboardEditor
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/monitoring.metricWriter
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/opsconfigmonitoring.resourceMetadata.writer
- members:
  - serviceAccount:admiral@qwiklabs-services-prod.iam.gserviceaccount.com
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/owner
- members:
  - serviceAccount:baremetal-gcr@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/stackdriver.resourceMetadata.writer
- members:
  - serviceAccount:qwiklabs-gcp-01-2fc31c8b782a@qwiklabs-gcp-01-2fc31c8b782a.iam.gserviceaccount.com
  role: roles/storage.admin
- members:
  - user:student-04-c2156532d277@qwiklabs.net
  role: roles/viewer
etag: BwX8YW-ez_4=
version: 1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ MACHINE_TYPE=n1-standard-4
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_PREFIX=abm
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_WS=$VM_PREFIX-wsVM_WS=$VM_PREFIX-ws
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ ^Cstudent_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ ^C
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_WS=$VM_PREFIX-wsVM_WS=$VM_PREFIX-ws
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ echo $VM_P

student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ echo $VM_WS
abm-wsVM_WS=abm-ws
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_WS=$VM_PREFIX-ws
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ echo $VM_WS
abm-ws
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_CP1=$VM_PREFIX-cp1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_W1=$VM_PREFIX-w1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ VM_W2=$VM_PREFIX-w2
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ declare -a CP_W_VMs=("$VM_CP1" "$VM_W1" "$VM_W2")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ declare -a VMs=("$VM_WS" "$VM_CP1" "$VM_W1" "$VM_W2")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ declare -a IPs=()
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud compute instances create $VM_WS \
          --image-family=ubuntu-2004-lts \
          --image-project=ubuntu-os-cloud \
          --zone=${ZONE} \
          --boot-disk-size 50G \
          --boot-disk-type pd-ssd \
          --can-ip-forward \
          --network default \
          --tags http-server,https-server \
          --min-cpu-platform "Intel Haswell" \
          --scopes cloud-platform \
          --machine-type $MACHINE_TYPE \
          --metadata=enable-oslogin=FALSE
Created [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-2fc31c8b782a/zones/us-central1-a/instances/abm-ws].
WARNING: Some requests generated warnings:
 - Disk size: '50 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud.google.com/compute/docs/disks/add-persistent-disk#resize_pd for details.

NAME: abm-ws
ZONE: us-central1-a
MACHINE_TYPE: n1-standard-4
PREEMPTIBLE: 
INTERNAL_IP: 10.128.0.2
EXTERNAL_IP: 34.123.36.3
STATUS: RUNNING
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ IP=$(gcloud compute instances describe $VM_WS --zone ${ZONE} \
     --format='get(networkInterfaces[0].networkIP)')
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ IPs+=("$IP")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ for vm in "${CP_W_VMs[@]}"
do
    gcloud compute instances create $vm \
              --image-family=ubuntu-2004-lts \
              --image-project=ubuntu-os-cloud \
              --zone=${ZONE} \
              --boot-disk-size 150G \
              --boot-disk-type pd-ssd \
              --can-ip-forward \
              --network default \
              --tags http-server,https-server \
              --min-cpu-platform "Intel Haswell" \
              --scopes cloud-platform \
              --machine-type $MACHINE_TYPE \
              --metadata=enable-oslogin=FALSE
    IP=$(gcloud compute instances describe $vm --zone ${ZONE} \
         --format='get(networkInterfaces[0].networkIP)')
doneIPs+=("$IP")
Created [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-2fc31c8b782a/zones/us-central1-a/instances/abm-cp1].
WARNING: Some requests generated warnings:
 - Disk size: '150 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud.google.com/compute/docs/disks/add-persistent-disk#resize_pd for details.

NAME: abm-cp1
ZONE: us-central1-a
MACHINE_TYPE: n1-standard-4
PREEMPTIBLE: 
INTERNAL_IP: 10.128.0.3
EXTERNAL_IP: 104.198.73.213
STATUS: RUNNING
Created [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-2fc31c8b782a/zones/us-central1-a/instances/abm-w1].
WARNING: Some requests generated warnings:
 - Disk size: '150 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud.google.com/compute/docs/disks/add-persistent-disk#resize_pd for details.

NAME: abm-w1
ZONE: us-central1-a
MACHINE_TYPE: n1-standard-4
PREEMPTIBLE: 
INTERNAL_IP: 10.128.0.4
EXTERNAL_IP: 34.171.141.100
STATUS: RUNNING
Created [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-2fc31c8b782a/zones/us-central1-a/instances/abm-w2].
WARNING: Some requests generated warnings:
 - Disk size: '150 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud.google.com/compute/docs/disks/add-persistent-disk#resize_pd for details.

NAME: abm-w2
ZONE: us-central1-a
MACHINE_TYPE: n1-standard-4
PREEMPTIBLE: 
INTERNAL_IP: 10.128.0.5
EXTERNAL_IP: 35.188.196.238
STATUS: RUNNING
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ for vm in "${VMs[@]}"
do
    while ! gcloud compute ssh root@$vm --zone us-central1-a --command "echo SSH to $vm succeeded"
    do
        echo "Trying to SSH into $vm failed. Sleeping for 5 seconds. zzzZZzzZZ"
        sleep  5
    done
done
WARNING: The private SSH key file for gcloud does not exist.
WARNING: The public SSH key file for gcloud does not exist.
WARNING: You do not have an SSH key for gcloud.
WARNING: SSH keygen will be executed to generate a key.
This tool needs to create the directory [/home/student_04_c2156532d277/.ssh] before being able to 
generate SSH keys.

Do you want to continue (Y/n)?  y

Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/student_04_c2156532d277/.ssh/google_compute_engine
Your public key has been saved in /home/student_04_c2156532d277/.ssh/google_compute_engine.pub
The key fingerprint is:
SHA256:POu32pWBI6Fl2OzzYZM86UkZuiWpe6UkRSMfM4GDoCk student_04_c2156532d277@cs-720200638619-default
The key's randomart image is:
+---[RSA 3072]----+
|  .. . ...       |
| o  . ++*        |
|E     .=*=.      |
|.      *o= *     |
|      ..S # .    |
|      ...&.* o   |
|      .ooo+ o    |
|       oo...     |
|      ..ooo.     |
+----[SHA256]-----+
Updating project ssh metadata...working..Updated [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-01-2fc31c8b782a].
Updating project ssh metadata...done.                                                               
Waiting for SSH key to propagate.
Warning: Permanently added 'compute.2660045022468024713' (ECDSA) to the list of known hosts.
SSH to abm-ws succeeded
Warning: Permanently added 'compute.3562222101496637748' (ECDSA) to the list of known hosts.
SSH to abm-cp1 succeeded
Warning: Permanently added 'compute.9167769818575710472' (ECDSA) to the list of known hosts.
SSH to abm-w1 succeeded
Warning: Permanently added 'compute.6502552692248848668' (ECDSA) to the list of known hosts.
SSH to abm-w2 succeeded
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ i=2
for vm in "${VMs[@]}"
do
    gcloud compute ssh root@$vm --zone ${ZONE} << EOF
        apt-get -qq update > /dev/null
        apt-get -qq install -y jq > /dev/null
        set -x
        ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
        current_ip=\$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)
        echo "VM IP address is: \$current_ip"
        for ip in ${IPs[@]}; do
            if [ "\$ip" != "\$current_ip" ]; then
                bridge fdb append to 00:00:00:00:00:00 dst \$ip dev vxlan0
            fi
        done
        ip addr add 10.200.0.$i/24 dev vxlan0
        ip link set up dev vxlan0
donei=$((i+1))ctl disable apparmor.service

Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1030-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue May 23 19:47:42 UTC 2023

  System load:  0.19              Processes:             124
  Usage of /:   3.9% of 48.27GB   Users logged in:       0
  Memory usage: 1%                IPv4 address for ens4: 10.128.0.2
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
dpkg-preconfigure: unable to re-open stdin: 
+ ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
++ jq '.[0].addr_info[0].local' -r
++ ip --json a show dev ens4
VM IP address is: 10.128.0.2
+ current_ip=10.128.0.2
+ echo 'VM IP address is: 10.128.0.2'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.2 '!=' 10.128.0.2 ']'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.3 '!=' 10.128.0.2 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.3 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.4 '!=' 10.128.0.2 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.4 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.5 '!=' 10.128.0.2 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.5 dev vxlan0
+ ip addr add 10.200.0.2/24 dev vxlan0
+ ip link set up dev vxlan0
+ systemctl stop apparmor.service
+ systemctl disable apparmor.service
Synchronizing state of apparmor.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable apparmor
Removed /etc/systemd/system/sysinit.target.wants/apparmor.service.
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1030-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue May 23 19:48:04 UTC 2023

  System load:  0.27               Processes:             126
  Usage of /:   1.3% of 145.19GB   Users logged in:       0
  Memory usage: 1%                 IPv4 address for ens4: 10.128.0.3
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
dpkg-preconfigure: unable to re-open stdin: 
+ ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
++ jq '.[0].addr_info[0].local' -r
++ ip --json a show dev ens4
VM IP address is: 10.128.0.3
+ current_ip=10.128.0.3
+ echo 'VM IP address is: 10.128.0.3'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.2 '!=' 10.128.0.3 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.2 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.3 '!=' 10.128.0.3 ']'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.4 '!=' 10.128.0.3 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.4 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.5 '!=' 10.128.0.3 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.5 dev vxlan0
+ ip addr add 10.200.0.3/24 dev vxlan0
+ ip link set up dev vxlan0
+ systemctl stop apparmor.service
+ systemctl disable apparmor.service
Synchronizing state of apparmor.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable apparmor
Removed /etc/systemd/system/sysinit.target.wants/apparmor.service.
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1030-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue May 23 19:48:27 UTC 2023

  System load:  0.05               Processes:             124
  Usage of /:   1.3% of 145.19GB   Users logged in:       0
  Memory usage: 1%                 IPv4 address for ens4: 10.128.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
dpkg-preconfigure: unable to re-open stdin: 
+ ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
++ jq '.[0].addr_info[0].local' -r
++ ip --json a show dev ens4
VM IP address is: 10.128.0.4
+ current_ip=10.128.0.4
+ echo 'VM IP address is: 10.128.0.4'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.2 '!=' 10.128.0.4 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.2 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.3 '!=' 10.128.0.4 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.3 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.4 '!=' 10.128.0.4 ']'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.5 '!=' 10.128.0.4 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.5 dev vxlan0
+ ip addr add 10.200.0.4/24 dev vxlan0
+ ip link set up dev vxlan0
+ systemctl stop apparmor.service
+ systemctl disable apparmor.service
Synchronizing state of apparmor.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable apparmor
Removed /etc/systemd/system/sysinit.target.wants/apparmor.service.
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1030-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue May 23 19:48:50 UTC 2023

  System load:  0.04               Processes:             125
  Usage of /:   1.3% of 145.19GB   Users logged in:       0
  Memory usage: 1%                 IPv4 address for ens4: 10.128.0.5
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
dpkg-preconfigure: unable to re-open stdin: 
+ ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
++ jq '.[0].addr_info[0].local' -r
++ ip --json a show dev ens4
VM IP address is: 10.128.0.5
+ current_ip=10.128.0.5
+ echo 'VM IP address is: 10.128.0.5'
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.2 '!=' 10.128.0.5 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.2 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.3 '!=' 10.128.0.5 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.3 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.4 '!=' 10.128.0.5 ']'
+ bridge fdb append to 00:00:00:00:00:00 dst 10.128.0.4 dev vxlan0
+ for ip in 10.128.0.2 10.128.0.3 10.128.0.4 10.128.0.5
+ '[' 10.128.0.5 '!=' 10.128.0.5 ']'
+ ip addr add 10.200.0.5/24 dev vxlan0
+ ip link set up dev vxlan0
+ systemctl stop apparmor.service
+ systemctl disable apparmor.service
Synchronizing state of apparmor.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable apparmor
Removed /etc/systemd/system/sysinit.target.wants/apparmor.service.
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$

EOF^C create cluster -c \$clusterido/v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)$ gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -x
export PROJECT_ID=$(gcloud config get-value project)
export clusterid=${cluster_name}
bmctl create config -c \$clusterid
cat > bmctl-workspace/\$clusterid/\$clusterid.yaml << EOB
---
gcrKeyPath: /root/bm-gcr.json
sshPrivateKeyPath: /root/.ssh/id_rsa
gkeConnectAgentServiceAccountKeyPath: /root/bm-gcr.json
gkeConnectRegisterServiceAccountKeyPath: /root/bm-gcr.json
cloudOperationsServiceAccountKeyPath: /root/bm-gcr.json
---
apiVersion: v1
kind: Namespace
metadata:
EOFtl create cluster -c \$clusterido/v1
Your active configuration is: [cloudshell-6771]
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1030-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue May 23 19:55:31 UTC 2023

  System load:  0.04              Users logged in:          0
  Usage of /:   5.6% of 48.27GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 2%                IPv4 address for ens4:    10.128.0.2
  Swap usage:   0%                IPv4 address for vxlan0:  10.200.0.2
  Processes:    125


 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/gcp/pro

Expanded Security Maintenance for Applications is not enabled.

71 updates can be applied immediately.
51 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


+ export PROJECT_ID=qwiklabs-gcp-01-2fc31c8b782a
+ PROJECT_ID=qwiklabs-gcp-01-2fc31c8b782a
+ export clusterid=anthos-bm-cluster-1
+ clusterid=anthos-bm-cluster-1
+ bmctl create config -c anthos-bm-cluster-1
[2023-05-23 19:55:32+0000] Created config: bmctl-workspace/anthos-bm-cluster-1/anthos-bm-cluster-1.yaml
+ cat
+ bmctl create cluster -c anthos-bm-cluster-1
Please check the logs at bmctl-workspace/anthos-bm-cluster-1/log/create-cluster-20230523-195532/create-cluster.log
[2023-05-23 19:55:44+0000] Creating bootstrap cluster... OK
[2023-05-23 19:57:18+0000] Installing dependency components... OK
[2023-05-23 19:58:34+0000] Waiting for preflight check job to finish... OK
[2023-05-23 20:00:54+0000] - Validation Category: machines and network
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.5-gcp
[2023-05-23 20:00:54+0000]      - [PASSED] gcp
[2023-05-23 20:00:54+0000]      - [PASSED] node-network
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.3
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.3-gcp
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.4
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.4-gcp
[2023-05-23 20:00:54+0000]      - [PASSED] 10.200.0.5
[2023-05-23 20:00:54+0000] Flushing logs... OK
[2023-05-23 20:00:55+0000] Applying resources for new cluster
[2023-05-23 20:00:56+0000] Waiting for cluster to become ready OK[2023-05-23 20:07:36+0000] Writing kubeconfig file
[2023-05-23 20:07:36+0000] kubeconfig of created cluster is at bmctl-workspace/anthos-bm-cluster-1/anthos-bm-cluster-1-kubeconfig, please run
[2023-05-23 20:07:36+0000] kubectl --kubeconfig bmctl-workspace/anthos-bm-cluster-1/anthos-bm-cluster-1-kubeconfig get nodes
[2023-05-23 20:07:36+0000] to get cluster node status.
[2023-05-23 20:07:36+0000] Please restrict access to this file as it contains authentication credentials of your cluster.
[2023-05-23 20:07:36+0000] Waiting for node pools to become ready OK
[2023-05-23 20:07:56+0000] Moving admin cluster resources to the created admin cluster
[2023-05-23 20:08:10+0000] Waiting for node update jobs to finish OK
[2023-05-23 20:10:40+0000] Flushing logs... OK
[2023-05-23 20:10:40+0000] Deleting bootstrap cluster... OK
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-2fc31c8b782a)


Task 2. Install Anthos Service Mesh and Knative
In this section you will deploy Anthos Service Mesh on the bare metal cluster. You will:

Install Anthos Service Mesh kit

Configure certs

Create cacerts secret

Set network annotation for istio-system namespace

Configure Anthos Service Mesh Configuration File

Configure Validation Web Hook

First, run the following script to install the Anthos Service Mesh:

