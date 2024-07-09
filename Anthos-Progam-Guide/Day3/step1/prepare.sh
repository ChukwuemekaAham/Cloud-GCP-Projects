set x


#  Prepare the workstation machine for needed software components for this lab:

# Create service key for the service account

# Install bare metal cluster kit

# Install docker

# Install Siege (load tester)


gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -x
export PROJECT_ID=\$(gcloud config get-value project)
gcloud iam service-accounts keys create bm-gcr.json \
--iam-account=baremetal-gcr@\${PROJECT_ID}.iam.gserviceaccount.com
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/sbin/
mkdir baremetal && cd baremetal
gsutil cp gs://anthos-baremetal-release/bmctl/1.8.3/linux-amd64/bmctl .
chmod a+x bmctl
mv bmctl /usr/local/sbin/
cd ~
echo "Installing docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
# Install siege
cd ~
apt install siege -y
siege -V
cat /root/.siege/siege.conf \
| sed -e "s:^\(connection \=\).*:connection \= keep-alive:" \
> /root/.siege/siege.conf.new
mv /root/.siege/siege.conf.new /root/.siege/siege.conf
EOF



# Create SSH key for the Admin workstation machine and add corresponding public key to the rest of the VMs:

gcloud compute ssh root@$VM_WS --zone ${ZONE} << EOF
set -x
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
sed 's/ssh-rsa/root:ssh-rsa/' ~/.ssh/id_rsa.pub > ssh-metadata
for vm in ${VMs[@]}
do
    gcloud compute instances add-metadata \$vm --zone ${ZONE} --metadata-from-file ssh-keys=ssh-metadata
done
EOF
