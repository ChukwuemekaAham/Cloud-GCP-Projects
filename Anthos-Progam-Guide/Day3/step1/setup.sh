set -x

gcloud auth list
gcloud config list project

export PROJECT_ID=$(gcloud config get-value project)
export ZONE=us-central1-a
export service_account="baremetal-gcr"
export cluster_name=anthos-bm-cluster-1

#Create the baremetal-gcr account which will be used to authenticate from the Anthos bare metal cluster:

gcloud iam service-accounts create baremetal-gcr
gcloud iam service-accounts keys create bm-gcr.json \
--iam-account=baremetal-gcr@${PROJECT_ID}.iam.gserviceaccount.com

gcloud services enable \
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

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.connect"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/gkehub.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/logging.logWriter"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/monitoring.dashboardEditor"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/stackdriver.resourceMetadata.writer"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:baremetal-gcr@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/opsconfigmonitoring.resourceMetadata.writer"



