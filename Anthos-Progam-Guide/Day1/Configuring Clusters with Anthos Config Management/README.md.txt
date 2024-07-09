Overview
Kubernetes clusters are configured using manifests, or configs, written in YAML or JSON. These configurations include important Kubernetes objects such as Namespaces, ClusterRoles, ClusterRoleBindings, Roles, RoleBindings, PodSecurityPolicy, NetworkPolicy, and ResourceQuotas, etc.

These declarative configs can be applied by hand or with automated tooling. The preferred method is to use an automated process to establish and maintain a consistently managed environment from the beginning.

Anthos Config Management is a solution to help manage these resources in a configuration-as-code like manner. Anthos Config Management utilizes a version-controlled Git repository (repo) for configuration storage along with configuration operators which apply configs to selected clusters.

Anthos Config Management allows you to easily manage the configuration of many clusters. At the heart of this process are the Git repositories that store the configurations to be applied on the clusters.


Objectives
In this lab, you learn how to perform the following tasks:

Install the Config Management Operator and the nomos command-line tool

Set up your config repo in Cloud Source Repositories

Connect your GKE clusters to the config repo

Examine the configs in your clusters and repo

Filter application of configs by Namespace

Review automated drift management

Update a config in the repo



student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ export PROJECT_ID=$(gcloud config get-value project)
Your active configuration is: [cloudshell-2036]
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ export SHELL_IP=$(curl -s api.ipify.org)
export KUBECONFIG=~/.kube/config
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

gcloud compute firewall-rules create shell-to-onprem \
    --network=onprem-k8s-local \
    --allow tcp \
    --source-ranges $SHELL_IP

Creating firewall...done.                                                                                                            
NAME: shell-to-onprem
NETWORK: onprem-k8s-local
DIRECTION: INGRESS
PRIORITY: 1000
ALLOW: tcp
DENY: 
DISABLED: False
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ gsutil cp gs://$PROJECT_ID-kops-onprem/config \
    ~/.kube/config
Copying gs://qwiklabs-gcp-04-52772f07b2f2-kops-onprem/config...
/ [1 files][  5.5 KiB/  5.5 KiB]                                                
Operation completed over 1 objects/5.5 KiB.                                      
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectx onprem.k8s.local
Switched to context "onprem.k8s.local".
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectl create token remote-admin-sa
eyJhbGciOiJSUzI1NiIsImtpZCI6InVTdGdSdms2V1JVVFBKVmVXUVRmWGxhRkVIdlBHT1J5UTRPekI0TFVIZ3MifQ.eyJhdWQiOlsia3ViZXJuZXRlcy5zdmMuZGVmYXVsdCJdLCJleHAiOjE2ODQ0NjIyODQsImlhdCI6MTY4NDQ1ODY4NCwiaXNzIjoiaHR0cHM6Ly9hcGkuaW50ZXJuYWwub25wcmVtLms4cy5sb2NhbCIsImt1YmVybmV0ZXMuaW8iOnsibmFtZXNwYWNlIjoiZGVmYXVsdCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJyZW1vdGUtYWRtaW4tc2EiLCJ1aWQiOiJjZWViZGY1ZC04N2Y2LTQwODAtYjQ1ZC01YzE4NWRjMjFmYmIifX0sIm5iZiI6MTY4NDQ1ODY4NCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6cmVtb3RlLWFkbWluLXNhIn0.l79tJXfFDjyymeCGASedut_Mei-ptfNZWUpUJord5uYjU-7lXWY33BP_f6CLuLLQwrTRMrwa4Y3JHKx6C5VLEDXZMvEZGKT5JchP_7FlSSyNDKPfnXVgY7j0E04OUnsDaUOW09TOTIcI4qWZJMPnY0Ck9AR9exUY_-aacV5KaxM0xluxiEHQiEdnzsfC2RnUhIqML4AEG2ZYGc9Q0Wie2j1tQlFk9r-_lSsrJIK5wI8IDYrBSt8VVNoJgr7oXvbBTsVUPaQIST_z-h-euBYJMSS86RcHFKXE65aN-RF1QSZOCIsQ3IjcxJcocx97K2Q8gsP2hLszvz6VoeBTHCRdWg
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$


tudent_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ gsutil cp gs://$PROJECT_ID-kops-onprem/config \
    ~/.kube/config
Copying gs://qwiklabs-gcp-04-52772f07b2f2-kops-onprem/config...
/ [1 files][  5.5 KiB/  5.5 KiB]                                                
Operation completed over 1 objects/5.5 KiB.                                      
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectx onprem.k8s.local
Switched to context "onprem.k8s.local".
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectl create token remote-admin-sa
eyJhbGciOiJSUzI1NiIsImtpZCI6InVTdGdSdms2V1JVVFBKVmVXUVRmWGxhRkVIdlBHT1J5UTRPekI0TFVIZ3MifQ.eyJhdWQiOlsia3ViZXJuZXRlcy5zdmMuZGVmYXVsdCJdLCJleHAiOjE2ODQ0NjIyODQsImlhdCI6MTY4NDQ1ODY4NCwiaXNzIjoiaHR0cHM6Ly9hcGkuaW50ZXJuYWwub25wcmVtLms4cy5sb2NhbCIsImt1YmVybmV0ZXMuaW8iOnsibmFtZXNwYWNlIjoiZGVmYXVsdCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJyZW1vdGUtYWRtaW4tc2EiLCJ1aWQiOiJjZWViZGY1ZC04N2Y2LTQwODAtYjQ1ZC01YzE4NWRjMjFmYmIifX0sIm5iZiI6MTY4NDQ1ODY4NCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6cmVtb3RlLWFkbWluLXNhIn0.l79tJXfFDjyymeCGASedut_MeRF1QSZOCIsQ3IjcxJcocx97K2Q8gsP2hLszvz6VoeBTHCRdWg                                                                                     student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ LS                                                               -bash: LS: command not found
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ ls
README-cloudshell.txt
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ ^C
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ ZONE=us-central1-a
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ gcloud container clusters get-credentials gke --zone $ZONE --project $PROJECT_ID
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke.
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectx gke=gke_${PROJECT_ID}_${ZONE}_gke
Context "gke_qwiklabs-gcp-04-52772f07b2f2_us-central1-a_gke" renamed to "gke".
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ kubectx gke
Switched to context "gke".
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ export LAB_DIR=$HOME/acm-lab
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$ mkdir $LAB_DIR
student_01_213c1fd1d369@cloudshell:~ (qwiklabs-gcp-04-52772f07b2f2)$  cd $LAB_DIR
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ ls
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml
Copying gs://config-management-release/released/latest/config-management-operator.yaml...
/ [1 files][ 21.1 KiB/ 21.1 KiB]                                                
Operation completed over 1 objects/21.1 KiB.                                     
serviceaccount/config-management-operator created
deployment.apps/config-management-operator created
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectx onprem.k8s.local
Switched to context "onprem.k8s.local".
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectl apply -f config-management-operator.yaml
customresourcedefinition.apiextensions.k8s.io/configmanagements.configmanagement.gke.io created
namespace/config-management-system created
namespace/config-management-monitoring created
clusterrole.rbac.authorization.k8s.io/config-management-operator created
clusterrolebinding.rbac.authorization.k8s.io/config-management-operator created
serviceaccount/config-management-operator created
deployment.apps/config-management-operator created
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ cd $LAB_DIR
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos nomos
Copying gs://config-management-release/released/latest/linux_amd64/nomos...
| [1 files][ 27.2 MiB/ 27.2 MiB]                                                
Operation completed over 1 objects/27.2 MiB.                                     
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ chmod +x ./nomos
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ ./nomos status
Connecting to clusters...

gke
  --------------------
     Failed to get the RootSync CRD: customresourcedefinitions.apiextensions.k8s.io "rootsyncs.configsync.gke.io" not found

*onprem.k8s.local
  --------------------
     Failed to get the RootSync CRD: customresourcedefinitions.apiextensions.k8s.io "rootsyncs.configsync.gke.io" not found
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$

In this case, config management is installed but not yet configured for your clusters.

When nomos status reports an error, it also shows any additional error text available to help diagnose the problem under Config Management Errors.

You will correct the issues you see here in later steps.


student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectx onprem.k8s.local
Switched to context "onprem.k8s.local".
namespace/config-management-system created
namespace/config-management-monitoring created
clusterrole.rbac.authorization.k8s.io/config-management-operator created
clusterrolebinding.rbac.authorization.k8s.io/config-management-operator created
serviceaccount/config-management-operator created
deployment.apps/config-management-operator created
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ cd $LAB_DIR
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos nomos
Copying gs://config-management-release/released/latest/linux_amd64/nomos...
| [1 files][ 27.2 MiB/ 27.2 MiB]                                                
Operation completed over 1 objects/27.2 MiB.                                     
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ chmod +x ./nomos
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ ./nomos status
Connecting to clusters...

gke
  --------------------
     Failed to get the RootSync CRD: customresourcedefinitions.apiextensions.k8s.io "rootsyncs.configsync.gke.io" not found

*onprem.k8s.local
  --------------------
     Failed to get the RootSync CRD: customresourcedefinitions.apiextensions.k8s.io "rootsyncs.configsync.gke.io" not found
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ ^C
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ echo $GCLOUD_EMAIL
student-01-213c1fd1d369@qwiklabs.net
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ 
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ echo $USER
student_01_213c1fd1d369
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ git config --global user.email "$GCLOUD_EMAIL"
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ git config --global user.name "$USER"
Cloning into 'training-data-analyst'...
remote: Enumerating objects: 62932, done.
remote: Counting objects: 100% (581/581), done.
remote: Compressing objects: 100% (328/328), done.
remote: Total 62932 (delta 304), reused 459 (delta 226), pack-reused 62351
Receiving objects: 100% (62932/62932), 696.14 MiB | 22.39 MiB/s, done.
Resolving deltas: 100% (40028/40028), done.
Updating files: 100% (12837/12837), done.
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ cd ./training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ git init
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
Initialized empty Git repository in /home/student_01_213c1fd1d369/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config/.git/
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ git commit -m "Initial config repo commit"
[master (root-commit) 2c7956d] Initial config repo commit
 9 files changed, 67 insertions(+)
 create mode 100644 README.md
 create mode 100644 cluster/clusterrole-namespace-readers.yaml
 create mode 100644 cluster/clusterrolebinding-namespace-readers.yaml
 create mode 100644 namespaces/dev/namespace.yaml
 create mode 100644 namespaces/prod/namespace.yaml
 create mode 100644 namespaces/rolebinding-sre.yaml
 create mode 100644 namespaces/selector-sre-support.yaml
 create mode 100644 system/README.md
 create mode 100644 system/repo.yaml
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ gcloud source repos create anthos_config
Created [anthos_config].
WARNING: You may be billed for this repository. See https://cloud.google.com/source-repositories/docs/pricing for details.
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ git config credential.helper gcloud.sh
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ ls
cluster  namespaces  README.md  system
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ git remote add origin https://source.developers.google.com/p/$PROJECT_ID/r/anthos_config
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ git push origin master
Enumerating objects: 16, done.
Counting objects: 100% (16/16), done.
Delta compression using up to 2 threads
Compressing objects: 100% (14/14), done.
Writing objects: 100% (16/16), 1.82 KiB | 466.00 KiB/s, done.
Total 16 (delta 0), reused 0 (delta 0), pack-reused 0
To https://source.developers.google.com/p/qwiklabs-gcp-04-52772f07b2f2/r/anthos_config
 * [new branch]      master -> master
student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$

student_01_213c1fd1d369@cloudshell:~/acm-lab/training-data-analyst/courses/ahybrid/v1.0/AHYBRID071/config (qwiklabs-gcp-04-52772f07b2f2)$ ^C
SHA256:Pgh6XFQDezgsVV7EP/1Vnaiu38FtRbJNoqWBl3Z1yc0 student-01-213c1fd1d369@qwiklabs.net
The key's randomart image is:
|     o = o.. o =E|
|    . * o ..*.= +|
|     o o   +o*.B.|
|    . . S . o...+|
|   o o o   .. . o|
|          .. .   |
+----[SHA256]-----+
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectx gke
Switched to context "gke".
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectl create secret generic git-creds \
    --namespace=config-management-system \
    --from-file=ssh=$HOME/.ssh/id_rsa.acm
secret/git-creds created
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectx onprem.k8s.local
Switched to context "onprem.k8s.local".
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ 
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ kubectl create secret generic git-creds \
    --namespace=config-management-system \
    --from-file=ssh=$HOME/.ssh/id_rsa.acm
secret/git-creds created
student_01_213c1fd1d369@cloudshell:~/acm-lab (qwiklabs-gcp-04-52772f07b2f2)$ 



