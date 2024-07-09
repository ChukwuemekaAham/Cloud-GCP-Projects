set x


# Define variables and arrays needed for the commands for this lab:

MACHINE_TYPE=n1-standard-4
VM_PREFIX=abm
VM_WS=$VM_PREFIX-ws
VM_CP1=$VM_PREFIX-cp1
VM_W1=$VM_PREFIX-w1
VM_W2=$VM_PREFIX-w2
declare -a CP_W_VMs=("$VM_CP1" "$VM_W1" "$VM_W2")
declare -a VMs=("$VM_WS" "$VM_CP1" "$VM_W1" "$VM_W2")
declare -a IPs=()


# Create four VMs for the Anthos bare metal cluster:

# Admin workstation machine to execute scripts to create the Anthos bare metal cluster and rest of the scripts for this lab

# One control plane master machine of the Anthos bare metal cluster

# Two worker machines of the Anthos bare metal cluster for running workloads

# Create a vxlan with L2 connectivity between all VMs

gcloud compute instances create $VM_WS \
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
IP=$(gcloud compute instances describe $VM_WS --zone ${ZONE} \
     --format='get(networkInterfaces[0].networkIP)')
IPs+=("$IP")


for vm in "${CP_W_VMs[@]}"
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
    IPs+=("$IP")
dones