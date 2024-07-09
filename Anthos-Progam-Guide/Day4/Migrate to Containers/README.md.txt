Objectives
You will learn how to perform the following tasks:

Create a Compute Engine instance hosting a Web Server.

Create a GKE cluster to host the migrated Compute Engine instance.

Migrate the Compute Engine instance using Migrate to Containers.

Test the Web Server that exists in GKE.



student_02_a1ed56b1b36a@cloudshell:~ (qwiklabs-gcp-02-5b814546322d)$ migctl migration status my-migration -v
Name:         my-migration
Namespace:    v2k-system
Labels:       migration-name=my-migration
              trace-token=ljndhpny
Annotations:  anthos-migrate.cloud.google.com/legacy-status:
                {"currentOperationSubSteps":[{"description":"GenerateArtifacts","status":"Running"}],"reconcileOperationInfo":{"status":"Running","numErro...
              anthos-migrate.cloud.google.com/old-resources:
                {"sourceSnapshot":{"name":"sourcesnapshot-1cc82dec-35b9-4632-8495-64623d8e4505","status":{"computeEngine":{"volumes":{"source-vm":{"pvc":{...
API Version:  anthos-migrate.cloud.google.com/v1
Kind:         Migration
Metadata:
  Creation Timestamp:  2023-05-22T14:53:47Z
  Generation:          1
  Managed Fields:
    API Version:  anthos-migrate.cloud.google.com/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:spec:
        .:
        f:sourceSnapshotTemplate:
          .:
          f:spec:
            .:
            f:sourceId:
            f:sourceProviderRef:
              .:
              f:name:
        f:type:
    Manager:      migctl
    Operation:    Update
    Time:         2023-05-22T14:53:47Z
    API Version:  anthos-migrate.cloud.google.com/v1beta2
    Fields Type:  FieldsV1
    fieldsV1:
      f:status:
        f:currentOperation:
        f:currentOperationSubSteps:
        f:reconcileOperationInfo:
          f:numErrors:
          f:status:
        f:resources:
          f:appX:
            .:
            f:discoveryStatus:
              .:
              f:task:
                .:
                f:name:
            f:extractStatus:
              .:
              f:task:
                .:
                f:name:
            f:name:
          f:sourceSnapshot:
            .:
            f:name:
            f:status:
              .:
              f:computeEngine:
                .:
                f:bootVolumeName:
                f:destinationProject:
                f:destinationZone:
                f:sourceDisks:
                f:v2kCsiPvc:
                  .:
                  f:claimPhase:
                  f:created:
                  f:csiPvc:
                  f:name:
                f:volumes:
                  .:
                  f:source-vm:
                    .:
                    f:copiedDisk:
                      .:
                      f:endTime:
                      f:name:
                      f:operationName:
                      f:operationType:
                      f:progress:
                      f:startTime:
                      f:status:
                      f:zone:
                    f:pvc:
                      .:
                      f:claimPhase:
                      f:created:
                      f:csiPvc:
                      f:name:
                      f:pvName:
              f:operation:
                .:
                f:numErrors:
                f:status:
              f:ready:
        f:status:
    Manager:         manager
    Operation:       Update
    Subresource:     status
    Time:            2023-05-22T14:58:08Z
  Resource Version:  9310
  UID:               1cc82dec-35b9-4632-8495-64623d8e4505
Spec:
  Source Snapshot Template:
    Spec:
      Source Id:  source-vm
      Source Provider Ref:
        Name:  source-vm
  Type:        linux-system-container
Status:
  Conditions:
    Last Transition Time:  <nil>
    Reason:                GenerateArtifacts
    Status:                False
    Type:                  Ready
    Last Transition Time:  <nil>
    Status:                False
    Type:                  Failed
  Discovery Task Ref:
    API Group:  anthos-migrate.cloud.google.com
    Kind:       AppXDiscoveryTask
    Name:       discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40
  Migration Plan Ref:
    API Group:  anthos-migrate.cloud.google.com
    Kind:       AppXGenerateArtifactsFlow
    Name:       appx-generateartifactsflow-my-migration
  Source Snapshot Ref:
    Name:  sourcesnapshot-1cc82dec-35b9-4632-8495-64623d8e4505
Events:
  Type    Reason                  Age                    From                                                                                 Message
  ----    ------                  ----                   ----                                                                                 -------
  Normal  ExternalProvisioning    7m11s (x2 over 7m11s)  PersistentVolumeClaim v2k-csi-pvc-63abeef9-8bed-4ca5-8214-688e06842f68               waiting for a volume to be created, either by external provisioner "io.gcr.anthos-migrate-generic" or manually created by system administrator
  Normal  Provisioning            7m11s                  PersistentVolumeClaim v2k-csi-pvc-63abeef9-8bed-4ca5-8214-688e06842f68               External provisioner is provisioning volume for claim "v2k-system/v2k-csi-pvc-63abeef9-8bed-4ca5-8214-688e06842f68"
  Normal  ProvisioningSucceeded   7m11s                  PersistentVolumeClaim v2k-csi-pvc-63abeef9-8bed-4ca5-8214-688e06842f68               Successfully provisioned volume pvc-d82d9491-8eb0-4cce-816e-221c4e7c4c68
  Normal  WaitForFirstConsumer    6m49s                  PersistentVolumeClaim discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40-923111fde  waiting for first consumer to be created before binding
  Normal  ExternalProvisioning    6m49s                  PersistentVolumeClaim discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40-923111fde  waiting for a volume to be created, either by external provisioner "pd.csi.storage.gke.io" or manually created by system administrator
  Normal  Provisioning            6m49s                  PersistentVolumeClaim discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40-923111fde  External provisioner is provisioning volume for claim "v2k-system/discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40-923111fde"
  Normal  ProvisioningSucceeded   6m45s                  PersistentVolumeClaim discovery-task-9affa6a5-84ea-446a-aff4-afb7491f9f40-923111fde  Successfully provisioned volume pvc-e7219d6d-d847-47c1-b3c8-f0bd8a3b3d73
  Normal  Scheduled               6m44s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully assigned v2k-system/discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c to gke-migration-processing-default-pool-b1e4294d-gz66
  Normal  SuccessfulAttachVolume  6m43s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  AttachVolume.Attach succeeded for volume "pvc-d82d9491-8eb0-4cce-816e-221c4e7c4c68"
  Normal  SuccessfulAttachVolume  6m38s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  AttachVolume.Attach succeeded for volume "pvc-e7219d6d-d847-47c1-b3c8-f0bd8a3b3d73"
  Normal  SuccessfulAttachVolume  6m34s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  AttachVolume.Attach succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c"
  Normal  SuccessfulMountVolume   6m33s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  MapVolume.MapPodDevice succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c" globalMapPath "/var/lib/kubelet/plugins/kubernetes.io/csi/volumeDevices/source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c/dev"
  Normal  SuccessfulMountVolume   6m33s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  MapVolume.MapPodDevice succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c" volumeMapPath "/var/lib/kubelet/pods/b016c97a-a35a-4002-aa00-4da7a1bfdbaf/volumeDevices/kubernetes.io~csi"
  Normal  Started                 6m30s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Started container wrapper-copier
  Normal  Pulled                  6m30s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully pulled image "anthos-migrate.gcr.io/v2k-delta:v1.14.0" in 2.716672253s (2.716684148s including waiting)
  Normal  Created                 6m30s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Created container wrapper-copier
  Normal  Pulling                 6m28s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Pulling image "anthos-migrate.gcr.io/v2k-lister:v1.14.0"
  Normal  Pulled                  6m23s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully pulled image "anthos-migrate.gcr.io/v2k-lister:v1.14.0" in 4.653232189s (4.653244712s including waiting)
  Normal  Created                 6m23s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Created container lister
  Normal  Started                 6m23s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Started container lister
  Normal  Pulling                 6m21s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Pulling image "anthos-migrate.gcr.io/v2k-init:v1.14.0"
  Normal  Pulled                  6m19s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully pulled image "anthos-migrate.gcr.io/v2k-init:v1.14.0" in 2.453877625s (2.453890571s including waiting)
  Normal  Created                 6m19s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Created container aggregator
  Normal  Started                 6m18s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Started container aggregator
  Normal  Pulling                 6m17s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Pulling image "anthos-migrate.gcr.io/v2k-linux-plugin-discovery:v1.14.0"
  Normal  Pulling                 6m15s (x2 over 6m33s)  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Pulling image "anthos-migrate.gcr.io/v2k-delta:v1.14.0"
  Normal  Pulled                  6m15s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully pulled image "anthos-migrate.gcr.io/v2k-linux-plugin-discovery:v1.14.0" in 1.727494875s (1.727501675s including waiting)
  Normal  Created                 6m15s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Created container plugin-worker
  Normal  Started                 6m15s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Started container plugin-worker
  Normal  Created                 6m15s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Created container artifacts-uploader
  Normal  Pulled                  6m15s                  Pod discoverer-58e46c17-b1b9-47aa-80c4-420a4acd223c                                  Successfully pulled image "anthos-migrate.gcr.io/v2k-delta:v1.14.0" in 146.629162ms (146.636878ms including waiting)
  Normal  AppXDiscoveryDone       6m1s                   AppXDiscoveryTask                                                                    Discovery done, repository:{GCS {Bucket qwiklabs-gcp-02-5b814546322d-migration-artifacts}} folder:v2k-system-my-migration/1cc82dec-35b9-4632-8495-64623d8e4505/discovery
  Normal  WaitForFirstConsumer    2m52s                  PersistentVolumeClaim my-migration-dt85h-scratch-pvc-601f0c2d-d5ca-498b-bd0dbab4016  waiting for first consumer to be created before binding
  Normal  ExternalProvisioning    2m51s (x2 over 2m51s)  PersistentVolumeClaim my-migration-dt85h-scratch-pvc-601f0c2d-d5ca-498b-bd0dbab4016  waiting for a volume to be created, either by external provisioner "pd.csi.storage.gke.io" or manually created by system administrator
  Normal  Provisioning            2m51s                  PersistentVolumeClaim my-migration-dt85h-scratch-pvc-601f0c2d-d5ca-498b-bd0dbab4016  External provisioner is provisioning volume for claim "v2k-system/my-migration-dt85h-scratch-pvc-601f0c2d-d5ca-498b-bd0dbab4016"
  Normal  ProvisioningSucceeded   2m48s                  PersistentVolumeClaim my-migration-dt85h-scratch-pvc-601f0c2d-d5ca-498b-bd0dbab4016  Successfully provisioned volume pvc-03b853a9-74d6-4134-abef-334b770f79bb
  Normal  Scheduled               2m47s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Successfully assigned v2k-system/extract-601f0c2d-d5ca-498b-bd32-485377d2c42a to gke-migration-processing-default-pool-b1e4294d-gz66
  Normal  SuccessfulAttachVolume  2m47s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     AttachVolume.Attach succeeded for volume "pvc-d82d9491-8eb0-4cce-816e-221c4e7c4c68"
  Normal  SuccessfulAttachVolume  2m43s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     AttachVolume.Attach succeeded for volume "pvc-03b853a9-74d6-4134-abef-334b770f79bb"
  Normal  SuccessfulAttachVolume  2m40s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     AttachVolume.Attach succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c"
  Normal  SuccessfulMountVolume   2m35s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     MapVolume.MapPodDevice succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c" globalMapPath "/var/lib/kubelet/plugins/kubernetes.io/csi/volumeDevices/source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c/dev"
  Normal  SuccessfulMountVolume   2m35s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     MapVolume.MapPodDevice succeeded for volume "source-vm-disk-63abeef9-8bed-4ca5-8214-688e06842f68-9ff1b1d8c" volumeMapPath "/var/lib/kubelet/pods/b3c0676e-ad64-406b-8932-3c64f4ac3609/volumeDevices/kubernetes.io~csi"
  Normal  Created                 2m35s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Created container wrapper-copier
  Normal  Pulled                  2m35s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Successfully pulled image "anthos-migrate.gcr.io/v2k-delta:v1.14.0" in 191.797938ms (191.812696ms including waiting)
  Normal  Started                 2m35s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Started container wrapper-copier
  Normal  Pulled                  2m34s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Container image "anthos-migrate.gcr.io/v2k-lister:v1.14.0" already present on machine
  Normal  Created                 2m34s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Created container lister
  Normal  Started                 2m34s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Started container lister
  Normal  Started                 2m33s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Started container aggregator
  Normal  Pulled                  2m33s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Container image "anthos-migrate.gcr.io/v2k-init:v1.14.0" already present on machine
  Normal  Created                 2m33s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Created container aggregator
  Normal  Pulling                 2m31s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Pulling image "anthos-migrate.gcr.io/v2k-linux-plugin-extraction:v1.14.0"
  Normal  Pulling                 2m26s (x2 over 2m35s)  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Pulling image "anthos-migrate.gcr.io/v2k-delta:v1.14.0"
  Normal  Pulled                  2m26s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Successfully pulled image "anthos-migrate.gcr.io/v2k-linux-plugin-extraction:v1.14.0" in 5.588553895s (5.588562318s including waiting)
  Normal  Created                 2m26s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Created container plugin-worker
  Normal  Started                 2m26s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Started container plugin-worker
  Normal  Pulled                  2m25s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Successfully pulled image "anthos-migrate.gcr.io/v2k-delta:v1.14.0" in 142.611553ms (142.620243ms including waiting)
  Normal  Created                 2m25s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Created container artifacts-uploader
  Normal  Started                 2m25s                  Pod extract-601f0c2d-d5ca-498b-bd32-485377d2c42a                                     Started container artifacts-uploader

student_02_a1ed56b1b36a@cloudshell:~ (qwiklabs-gcp-02-5b814546322d)$ 


Once the migration is complete, get the generated YAML artifacts:

migctl migration get-artifacts my-migration
Copied!
The command downloads files that were generated during the migration:

deployment_spec.yaml -- The YAML file that configures your workload.

Dockerfile -- The Dockerfile used to build the image for your migrated VM.

migration.yaml -- A copy of the migration plan.

blocklist.yaml -- The list of container services to disable based on your settings in the migration plan.

If the Cloud Shell editor isn't open already, click the Open Editor button.

Open the deployment_spec.yaml file and locate the Service object whose name is source-vm.

Beneath the following Service definition, add another Service at the end that will expose port 80 for access to your web server over HTTP:

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: source-vm
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
Copied!
Your file should look like this:

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  name: source-vm
spec:
  clusterIP: None
  selector:
    app: source-vm
  type: ClusterIP
status:
  loadBalancer: {}
---
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: source-vm
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
Save the file.

Apply the deployment_spec.yaml to deploy the workload:

kubectl apply -f deployment_spec.yaml
Copied!
Sample output:

deployment.apps/source-vm created
service/source-vm created
service/my-service created
It may take a few minutes for the deployment to finish.

Now check for an external IP address:
kubectl get service