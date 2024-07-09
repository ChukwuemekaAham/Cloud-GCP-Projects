set x



# Wait for SSH to be ready on all VMs:
for vm in "${VMs[@]}"
do
    while ! gcloud compute ssh root@$vm --zone us-central1-a --command "echo SSH to $vm succeeded"
    do
        echo "Trying to SSH into $vm failed. Sleeping for 5 seconds. zzzZZzzZZ"
        sleep  5
    done
done


# At the prompt asking if you want to continue (Y/n), type Y.

# Press Enter key a few times to set an empty passphrase.

# Create a vxlan with L2 connectivity between all VMs:


i=2
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
        systemctl stop apparmor.service
        systemctl disable apparmor.service
EOF
    i=$((i+1))
dones


# After you are done you now have L2 connectivity when using the 10.200.0.0/24 network. The VMs will now have the following IP addresses:

# Admin Workstation: 10.200.0.2
# 3 x control plane: 10.200.0.3,4,5
# 3 x worker nodes: 10.200.0.6,7,8