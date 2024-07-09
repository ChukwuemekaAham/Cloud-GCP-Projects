Overview
In this lab, you learn how to use Policy Controller, a Kubernetes dynamic admission controller that checks, audits, and enforces your clusters' compliance with policies related to security, regulations, or business rules.

Policy Controller enforces your clusters' compliance with policies called constraints. In this lab, you use the constraint library, a set of templates that can be easily configured to enforce and audit security and compliance policies. For example, you can require that namespaces have at least one label so that you use GKE Usage Metering and allocate costs to different teams. Or, you might want to enforce the same requirements as provided by PodSecurityPolicies, but with the ability to audit them before disrupting a deployment with enforcements.

In addition to working with the provided platform constraint templates, you will learn how to create your own. With constraint templates, a centralized team can define how a constraint works, and delegate defining the specifics of the constraint to an individual or group with subject-matter expertise.

Policy Controller is built from the Gatekeeper open source project and is integrated into Anthos Config Management v1.1+.

Objectives
In this lab, you learn how to perform the following tasks:

Install Anthos Policy Controller

Create and enforce constraints using the Template Library provided by Google

Audit constraint violation

Create your own Template Constraints to create the custom compliance policies that your company needs



Welcome to Cloud Shell! Type "help" to get started.
Your Cloud Platform project in this session is set to qwiklabs-gcp-02-437bc1d6cdb2.
Use “gcloud config set project [PROJECT_ID]” to change to a different project.
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ ZONE=us-central1-a
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ export CLUSTER_NAME=gkeexport CLUSTER_NAME=gkevexport CLUSTER_NAME=gke^C
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ export CLUSTER_NAME=gke
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ 
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ export PROJECT_ID=$(gcloud config get-value project)
Your active configuration is: [cloudshell-25068]
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")
ERROR: (gcloud.projects.describe) You do not currently have an active account selected.
Please run:

  $ gcloud auth login

to obtain new credentials.

If you have already logged in with a different account, run:

  $ gcloud config set account ACCOUNT

to select an already authenticated account to use.
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ gcloud container clusters get-credentials gke --zone $ZONE --project $PROJECT_ID
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gke.
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ gcloud beta container fleet config-management enable 
Enabling service [anthosconfigmanagement.googleapis.com] on project [qwiklabs-gcp-02-437bc1d6cdb2]...
Operation "operations/acat.p2-868720792726-2b633feb-df5c-4a38-8e07-ed55d4b6bda3" finished successfully.
Waiting for Feature Config Management to be created...done.                                                                              
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ cat <<EOF > config-management.yaml
apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
applySpecVersion: 1
spec:
  # Set to true to install and enable Policy Controller
  policyController:
    enabled: true
    # Uncomment to prevent the template library from being installed
    # templateLibraryInstalled: false
    # Uncomment to enable support for referential constraints
    # referentialRulesEnabled: true
    # Uncomment to disable audit, adjust value to set audit interval
Every 2.0s: gcloud beta container fleet config-management status --project=qwiklabs-...  cs-705879515183-default: Mon May 22 07:16:15 2023

Name: global/gke-connect
Status: PENDING
Last_Synced_Token: NA
Sync_Branch: NA
Last_Synced_Time:
Policy_Controller: INSTALLED
Hierarchy_Controller: PENDING



student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl get constrainttemplates
NAME                                        AGE
allowedserviceportname                      103s
asmauthzpolicydisallowedprefix              103s
asmauthzpolicyenforcesourceprincipals       103s
asmauthzpolicynormalization                 103s
asmauthzpolicysafepattern                   103s
asmingressgatewaylabel                      103s
asmpeerauthnstrictmtls                      103s
asmrequestauthnprohibitedoutputheaders      103s
asmsidecarinjection                         103s
destinationruletlsenabled                   103s
disallowedauthzprefix                       103s
gcpstoragelocationconstraintv1              103s
k8sallowedrepos                             103s
k8sblockallingress                          103s
k8sblockcreationwithdefaultserviceaccount   103s
k8sblockendpointeditdefaultrole             103s
k8sblockloadbalancer                        103s
k8sblocknodeport                            103s
k8sblockobjectsoftype                       103s
k8sblockprocessnamespacesharing             103s
k8sblockwildcardingress                     103s
k8scontainerephemeralstoragelimit           103s
k8scontainerlimits                          103s
k8scontainerratios                          103s
k8scontainerrequests                        103s
k8sdisallowanonymous                        102s
k8sdisallowedrepos                          102s
k8sdisallowedrolebindingsubjects            102s
k8sdisallowedtags                           102s
k8semptydirhassizelimit                     102s
k8senforcecloudarmorbackendconfig           102s
k8sexternalips                              102s
k8shttpsonly                                102s
k8simagedigests                             102s
k8slocalstoragerequiresafetoevict           102s
k8smemoryrequestequalslimit                 102s
k8snoenvvarsecrets                          102s
k8snoexternalservices                       102s
k8spodsrequiresecuritycontext               102s
k8sprohibitrolewildcardaccess               102s
k8spspallowedusers                          102s
k8spspallowprivilegeescalationcontainer     102s
k8spspapparmor                              102s
k8spspautomountserviceaccounttokenpod       102s
k8spspcapabilities                          102s
k8spspflexvolumes                           102s
k8spspforbiddensysctls                      101s
k8spspfsgroup                               101s
k8spsphostfilesystem                        101s
k8spsphostnamespace                         101s
k8spsphostnetworkingports                   101s
k8spspprivilegedcontainer                   101s
k8spspprocmount                             101s
k8spspreadonlyrootfilesystem                101s
k8spspseccomp                               101s
k8spspselinuxv2                             101s
k8spspvolumetypes                           101s
k8sreplicalimits                            101s
k8srequirecosnodeimage                      101s
k8srequiredannotations                      101s
k8srequiredlabels                           100s
k8srequiredprobes                           100s
k8srequiredresources                        100s
k8srequirevalidrangesfornetworks            100s
k8srestrictlabels                           100s
k8srestrictnamespaces                       100s
k8srestrictnfsurls                          100s
k8srestrictrbacsubjects                     100s
k8srestrictrolebindings                     100s
noupdateserviceaccount                      100s
policystrictonly                            100s
restrictnetworkexclusions                   100s
sourcenotallauthz                           100s
verifydeprecatedapi                         100s
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$

student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ cat <<EOF > ns-must-have-geo.yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-geo
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels:
      - key: "geo"
EOF
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl apply -f ns-must-have-geo.yaml
k8srequiredlabels.constraints.gatekeeper.sh/ns-must-have-geo created
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl create namespace test
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [ns-must-have-geo] you must provide labels: {"geo"}
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$

student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ cat <<EOF > test-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test
  labels:
    geo: eu-west1
EOF
kubectl apply -f test-namespace.yaml
namespace/test created
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$


student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl get K8sRequiredLabels ns-must-have-geo -o yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"constraints.gatekeeper.sh/v1beta1","kind":"K8sRequiredLabels","metadata":{"annotations":{},"name":"ns-must-have-geo"},"spec":{"match":{"kinds":[{"apiGroups":[""],"kinds":["Namespace"]}]},"parameters":{"labels":[{"key":"geo"}]}}}
  creationTimestamp: "2023-05-22T07:18:54Z"
  generation: 1
  name: ns-must-have-geo
  resourceVersion: "593582"
  uid: 7755562f-782d-469d-95c0-1427e0910a57
spec:
  match:
    kinds:
    - apiGroups:
      - ""
      kinds:
      - Namespace
  parameters:
    labels:
    - key: geo
status:
  auditTimestamp: "2023-05-22T07:24:10Z"
  byPod:
  - constraintUID: 7755562f-782d-469d-95c0-1427e0910a57
    enforced: true
    id: gatekeeper-audit-767bf66d99-fnmq2
    observedGeneration: 1
    operations:
    - audit
    - status
  - constraintUID: 7755562f-782d-469d-95c0-1427e0910a57
    enforced: true
    id: gatekeeper-controller-manager-5999d47799-dbb5q
    observedGeneration: 1
    operations:
    - webhook
  totalViolations: 7
  violations:
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: default
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: config-management-monitoring
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: gatekeeper-system
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-public
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-system
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-node-lease
    version: v1
  - enforcementAction: deny
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: config-management-system
    version: v1
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$

Open the constraint in the Cloud Shell editor. Add the constraint enforcementAction to dryrun. That way you can validate policy constraints before enforcing them. Make sure that the yaml file looks as follows:

apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-geo
spec:
  enforcementAction: dryrun
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels:
      - key: "geo"


kubectl apply -f ns-must-have-geo.yaml


k8srequiredlabels.constraints.gatekeeper.sh/ns-must-have-geo configured
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ ~kubectl create namespace ns-with-violations^C
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl create namespace ns-with-violations
namespace/ns-with-violations created
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl get K8sRequiredLabels ns-must-have-geo -o yaml

apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"constraints.gatekeeper.sh/v1beta1","kind":"K8sRequiredLabels","metadata":{"annotations":{},"name":"ns-must-have-geo"},"spec":{"enforcementAction":"dryrun","match":{"kinds":[{"apiGroups":[""],"kinds":["Namespace"]}]},"parameters":{"labels":[{"key":"geo"}]}}}
  creationTimestamp: "2023-05-22T07:18:54Z"
  generation: 2
  name: ns-must-have-geo
  resourceVersion: "597374"
  uid: 7755562f-782d-469d-95c0-1427e0910a57
spec:
  enforcementAction: dryrun
  match:
    kinds:
    - apiGroups:
      - ""
      kinds:
      - Namespace
  parameters:
    labels:
    - key: geo
status:
  auditTimestamp: "2023-05-22T07:31:10Z"
  byPod:
  - constraintUID: 7755562f-782d-469d-95c0-1427e0910a57
    enforced: true
    id: gatekeeper-audit-767bf66d99-fnmq2
    observedGeneration: 2
    operations:
    - audit
    - status
  - constraintUID: 7755562f-782d-469d-95c0-1427e0910a57
    enforced: true
    id: gatekeeper-controller-manager-5999d47799-dbb5q
    observedGeneration: 2
    operations:
    - webhook
  totalViolations: 7
  violations:
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: default
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: config-management-monitoring
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: gatekeeper-system
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-public
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-system
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: kube-node-lease
    version: v1
  - enforcementAction: dryrun
    group: ""
    kind: Namespace
    message: 'you must provide labels: {"geo"}'
    name: config-management-system
    version: v1
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$


Task 5. Writing a constraint template
In this task, you will write a custom constraint template and use it to extend Policy Controller capabilities. This is great when you cannot find a pre-written constraint template that suits your needs for extending Policy Controller.

Policy Controller policies are described by using the OPA Constraint Framework and are written in Rego. A policy can evaluate any field of a Kubernetes object.

Writing policies using Rego is a specialized skill. For this reason, a library of common constraint templates is installed by default. Most users can leverages these constraint templates when creating constraints. If you have specialized needs, you can create your own constraint templates.

Constraint templates let you separate a policy's logic from its specific requirements, and this enables reuse and delegation. You can create constraints by using constraint templates developed by third parties, such as open source projects, software vendors, or regulatory experts.

Create the policy template that denies all resources whose name matches a value provided by the creator of the constraint:

cat <<EOF > k8sdenyname-constraint-template.yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sdenyname
spec:
  crd:
    spec:
      names:
        kind: K8sDenyName
      validation:
        openAPIV3Schema:
          properties:
            invalidName:
              type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sdenynames
        violation[{"msg": msg}] {
          input.review.object.metadata.name == input.parameters.invalidName
          msg := sprintf("The name %v is not allowed", [input.parameters.invalidName])
        }
EOF
Copied!
Deploy the template in the kubernetes cluster:

kubectl apply -f k8sdenyname-constraint-template.yaml
Copied!
Note: If you are using a structured repo with ACM Config Sync, Google recommends that you create your constraints in the cluster/ directory.
Once the template is deployed, a team can reference it the same way it would reference a template from Google's library to create a constraint:

cat <<EOF > k8sdenyname-constraint.yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDenyName
metadata:
  name: no-policy-violation
spec:
  parameters:
    invalidName: "policy-violation"
EOF
Copied!
Deploy the constraint in the kubernetes cluster:

student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl apply -f k8sdenyname-constraint.yaml
k8sdenyname.constraints.gatekeeper.sh/no-policy-violation created
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$ kubectl create namespace policy-violation
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [no-policy-violation] The name policy-violation is not allowed
student_01_535c47ed9de7@cloudshell:~ (qwiklabs-gcp-02-437bc1d6cdb2)$

Congratulations! You successfully created and deployed your own template. Then you created a constraint and verified that it prevents users from installing non compliant resources.
