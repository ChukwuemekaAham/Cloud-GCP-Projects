Run a load test against the Knative serverless application
In the existing Cloud Shell terminal, run the following command to view the status of redisconf Knative service:

watch kubectl get deployment
Copied!
You will notice the number of pods for redisconf deployment will increase when executing the load-test in a new terminal window.

Open another terminal (Cloud Shell) by clicking (+) right after the current terminal tab and get inside the Admin workstation machine by running the following commands:

VM_WS=abm-ws
ZONE=us-central1-a
gcloud compute ssh root@$VM_WS --zone ${ZONE}
Copied!
Once inside the Admin workstation machine, run:

siege -c10 -t30S http://redisconf.default.10.200.0.51.nip.io
Copied!
Go back to the first Cloud Shell, you should see the number of READY pods increase as follows:
Output: Ready 3/5

The load test's result from Siege in the second Cloud Shell should look like the following:

