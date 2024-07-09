In this lab, you learn to:

Enable the Cloud Run API.

Deploy a Cloud Run Service.

Assign tags to a revision.

Migrate traffic to a revision.

Roll back a revision.

Overview
Cloud Run allows you to specify which revisions should receive traffic and to specify traffic percentages that are received by a revision. This feature allows you to rollback to a previous revision, gradually roll out a revision, and split traffic between multiple revisions.

In this lab you will learn how to use Cloud Run features. The lab features three high level sections that resolve a technical problem:

Situational Overview

Requirements Gathering

Developing a minimal viable product

Prerequisites
These labs are based on intermediate knowledge of Google Cloud. While the steps required are covered in the content, it would be helpful to have familiarity with any of the following products:

Cloud Build

Cloud Run



student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud services enable run.googleapis.com
Operation "operations/acf.p2-370513043816-6e7d9a99-1ddf-4624-8190-94271710157c" finished successfully.
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud config set compute/region us-central1
Updated property [compute/region].
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ LOCATION="us-central1"
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run deploy product-service \
   --image gcr.io/qwiklabs-resources/product-status:0.0.1 \
   --tag test1 \
   --region $LOCATION \
   --allow-unauthenticated
Deploying container to Cloud Run service [product-service] in project [qwiklabs-gcp-01-270ef5ad7ed9] region [us-central1]
OK Deploying new service... Done.                                                                                             
  OK Creating Revision...                                                                                                     
  OK Routing traffic...                                                                                                       
  OK Setting IAM Policy...                                                                                                    
Done.                                                                                                                         
Service [product-service] revision [product-service-00001-cog] has been deployed and is serving 100 percent of traffic.
Service URL: https://product-service-t4y3uptxdq-uc.a.run.app
The revision can be reached directly at https://test1---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ TEST1_PRODUCT_SERVICE_URL=$(gcloud run services describe product-service --platform managed --region us-central1 --format="value(status.address.url)")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ curl $TEST1_PRODUCT_SERVICE_URL/v1/revision -w "\n"
{"api":"version 1"}
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ 
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$


Note: Traffic management

100 percent of traffic is being served to the revision TEST1
Service is accessible and set to the default
The Cloud Run service has been successfully deployed and is responding to requests. In the next section explore how to utilise Traffic Migration to specify which revision receives traffic.



student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run deploy product-service \
  --image gcr.io/qwiklabs-resources/product-status:0.0.2 \
  --no-traffic \
  --tag test2 \
  --region=$LOCATION \
  --allow-unauthenticated
Deploying container to Cloud Run service [product-service] in project [qwiklabs-gcp-01-270ef5ad7ed9] region [us-central1]
OK Deploying... Done.                                                                                                         
  OK Creating Revision...                                                                                                     
  OK Routing traffic...                                                                                                       
  OK Setting IAM Policy...                                                                                                    
Done.                                                                                                                         
Service [product-service] revision [product-service-00002-viw] has been deployed and is serving 0 percent of traffic.
The revision can be reached directly at https://test2---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ TEST2_PRODUCT_STATUS_URL=$(gcloud run services describe product-service --platform managed --region=us-central1 --format="value(status.traffic[2].url)")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$


student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ ^C
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ curl $TEST2_PRODUCT_STATUS_URL/help -w "\n"
API Microservice example: v2
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run services update-traffic product-service \
  --to-tags test2=50 \
  --region=$LOCATION
/  Updating traffic...                                                                                                        
OK Updating traffic... Done.                                                                                                  
  OK Routing traffic...                                                                                                       
Done.                                                                                                                         
URL: https://product-service-t4y3uptxdq-uc.a.run.app
Traffic:
  50% product-service-00001-cog
        test1: https://test1---product-service-t4y3uptxdq-uc.a.run.app
  50% product-service-00002-viw
        test2: https://test2---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ 

student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run deploy product-service \
  --image gcr.io/qwiklabs-resources/product-status:0.0.3 \
  --no-traffic \
  --tag test3 \
  --region=$LOCATION \
  --allow-unauthenticated
Deploying container to Cloud Run service [product-service] in project [qwiklabs-gcp-01-270ef5ad7ed9] region [us-central1]
OK Deploying... Done.                                                                                                         
  OK Creating Revision...                                                                                                     
  OK Setting IAM Policy...                                                                                                    
Done.                                                                                                                         
Service [product-service] revision [product-service-00005-cep] has been deployed and is serving 0 percent of traffic.
The revision can be reached directly at https://test3---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run deploy product-service \
  --image gcr.io/qwiklabs-resources/product-status:0.0.4 \
  --no-traffic \
  --tag test4 \
  --region=$LOCATION \
  --allow-unauthenticated
Deploying container to Cloud Run service [product-service] in project [qwiklabs-gcp-01-270ef5ad7ed9] region [us-central1]
OK Deploying... Done.                                                                                                         
  OK Creating Revision...                                                                                                     
  OK Setting IAM Policy...                                                                                                    
Done.                                                                                                                         
Service [product-service] revision [product-service-00006-vab] has been deployed and is serving 0 percent of traffic.
The revision can be reached directly at https://test4---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run services describe product-service \
  --region=$LOCATION \
  --format='value(status.traffic.revisionName)'
product-service-00001-cog;product-service-00001-cog;product-service-00002-viw;product-service-00005-cep;product-service-00006-vab
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ LIST=$(gcloud run services describe product-service --platform=managed --region=$LOCATION --format='value[delimiter="=25,"](status.traffic.revisionName)')"=25"
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run services update-traffic product-service \
  --to-revisions $LIST --region=$LOCATION
OK Updating traffic... Done.                                                                                                  
  OK Routing traffic...                                                                                                       
Done.                                                                                                                         
URL: https://product-service-t4y3uptxdq-uc.a.run.app
Traffic:
  25% product-service-00001-cog
        test1: https://test1---product-service-t4y3uptxdq-uc.a.run.app
  25% product-service-00002-viw
        test2: https://test2---product-service-t4y3uptxdq-uc.a.run.app
  25% product-service-00005-cep
        test3: https://test3---product-service-t4y3uptxdq-uc.a.run.app
  25% product-service-00006-vab
        test4: https://test4---product-service-t4y3uptxdq-uc.a.run.app
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v2
API Microservice example: v1
API Microservice example: v1
API Microservice example: v2
API Microservice example: v1
API Microservice example: v1
API Microservice example: v2
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v2
API Microservice example: v1
API Microservice example: v1
API Microservice example: v2
API Microservice example: v1
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v2
API Microservice example: v2
API Microservice example: v1
API Microservice example: v2
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v1
API Microservice example: v2
API Microservice example: v3
API Microservice example: v3
API Microservice example: v2
API Microservice example: v3
API Microservice example: v3
API Microservice example: v1
API Microservice example: v4
API Microservice example: v1
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v4
API Microservice example: v1
API Microservice example: v2
API Microservice example: v4
API Microservice example: v3
API Microservice example: v2
API Microservice example: v2
API Microservice example: v2
API Microservice example: v3
API Microservice example: v2
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ for i in {1..10}; do curl $TEST1_PRODUCT_SERVICE_URL/help -w "\n"; done
API Microservice example: v3
API Microservice example: v4
API Microservice example: v1
API Microservice example: v2
API Microservice example: v2
API Microservice example: v1
API Microservice example: v3
API Microservice example: v1
API Microservice example: v2
API Microservice example: v3
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ gcloud run services update-traffic product-service --to-latest --platform=managed --region=$LOCATION
OK Updating traffic... Done.                                                                                                  
  OK Routing traffic...                                                                                                       
Done.                                                                                                                         
URL: https://product-service-t4y3uptxdq-uc.a.run.app
Traffic:
  0%   product-service-00001-cog
         test1: https://test1---product-service-t4y3uptxdq-uc.a.run.app
  0%   product-service-00002-viw
         test2: https://test2---product-service-t4y3uptxdq-uc.a.run.app
  0%   product-service-00005-cep
         test3: https://test3---product-service-t4y3uptxdq-uc.a.run.app
  0%   product-service-00006-vab
         test4: https://test4---product-service-t4y3uptxdq-uc.a.run.app
  100% LATEST (currently product-service-00006-vab)
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ LATEST_PRODUCT_STATUS_URL=$(gcloud run services describe product-service --platform managed --region=$LOCATION --format="value(status.address.url)")
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$ curl $LATEST_PRODUCT_STATUS_URL/help -w "\n"
API Microservice example: v4
student_04_c2156532d277@cloudshell:~ (qwiklabs-gcp-01-270ef5ad7ed9)$

