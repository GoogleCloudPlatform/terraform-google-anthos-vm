#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is modified from https://github.com/GoogleCloudPlatform/anthos-samples/blob/main/anthos-bm-gcp-bash/install_hybrid_cluster.sh

printf "✅ Using Project [%s] and Zone [%s].\n\n" "$PROJECT_ID" "$ZONE"

# Activate service account
printf "🔄 Activating Service Account[%s]...\n" "${SERVICE_ACCOUNT}"
gcloud auth activate-service-account --project="${PROJECT_ID}" --key-file="${CREDENTIALS_FILE}"
printf "✅ Service Account activated.\n\n"

# declare arrays for VM names and IPs
printf "🔄 Setting up array variables for the VM names and IP addresses...\n"
# [START anthos_bm_gcp_bash_hybrid_vms_array]
MACHINE_TYPE=n1-standard-8
IFS=',' read -ra VMs <<< "${NODE_NAMES}"
printf "Total nodes: %s\n" "${VMs}"
VM_WS=${VMs[0]}
printf "Workstation node: %s\n" "${VM_WS}"
declare -a IPs=()
# [END anthos_bm_gcp_bash_hybrid_vms_array]
printf "✅ Variables for the VM names and IP addresses setup.\n\n"

# create GCE VMs
printf "🔄 Creating GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_create_vm]
for vm in "${VMs[@]}"
do
    gcloud compute instances create "$vm" \
      --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
      --zone="${ZONE}" \
      --boot-disk-size 200G \
      --boot-disk-type pd-ssd \
      --can-ip-forward \
      --network "${NETWORK}" \
      --tags http-server,https-server \
      --min-cpu-platform "Intel Haswell" \
      --scopes cloud-platform \
      --enable-nested-virtualization \
      --machine-type "$MACHINE_TYPE"
    IP=$(gcloud compute instances describe "$vm" --zone "${ZONE}" \
         --format='get(networkInterfaces[0].networkIP)')
    IPs+=("$IP")
done
# [END anthos_bm_gcp_bash_hybrid_create_vm]
printf "✅ Successfully created GCE VMs.\n\n"

# verify SSH access to the Google Compute Engine VMs
printf "🔄 Checking SSH access to the GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_check_ssh]
for vm in "${VMs[@]}"
do
    while ! gcloud compute ssh root@"$vm" --zone "${ZONE}" --command "printf SSH to $vm succeeded"
    do
        printf "Trying to SSH into %s failed. Sleeping for 5 seconds. zzzZZzzZZ" "$vm"
        sleep  5
    done
done
# [END anthos_bm_gcp_bash_hybrid_check_ssh]
printf "✅ Successfully connected to all the GCE VMs using SSH.\n\n"

# setup VxLAN configurations in all the VMs to enable L2-network connectivity
# between them
printf "🔄 Setting up VxLAN in the GCE VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_add_vxlan]
IFS=',' read -ra vxlanIPs <<< "${VXLAN_IPS}"
printf "VxLAN IPs: %s\n" "${vxlanIPs}"
for i in "${!VMs[@]}"
do
    vm=${VMs[$i]}
    gcloud compute ssh root@"$vm" --zone "${ZONE}" << EOF
        apt-get -qq update > /dev/null
        apt-get -qq install -y jq nfs-common > /dev/null
        set -x
        ip link add vxlan0 type vxlan id 42 dev ens4 dstport 0
        current_ip=\$(ip --json a show dev ens4 | jq '.[0].addr_info[0].local' -r)
        printf "VM IP address is: \$current_ip"
        for ip in ${IPs[@]}; do
            if [ "\$ip" != "\$current_ip" ]; then
                bridge fdb append to 00:00:00:00:00:00 dst \$ip dev vxlan0
            fi
        done
        ip addr add ${vxlanIPs[$i]}/24 dev vxlan0
        ip link set up dev vxlan0
EOF
done
# [END anthos_bm_gcp_bash_hybrid_add_vxlan]
printf "✅ Successfully setup VxLAN in the GCE VMs.\n\n"

# install the necessary tools inside the VMs
printf "🔄 Setting up admin workstation...\n"
# [START anthos_bm_gcp_bash_hybrid_init_vm]
gcloud compute scp --zone "${ZONE}" "${CREDENTIALS_FILE}" root@"${VM_WS}":/root/bm-gcr.json
gcloud compute ssh root@"${VM_WS}" --zone "${ZONE}" << EOF
set -x
export PROJECT_ID=\$(gcloud config get-value project)
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/sbin/
mkdir baremetal && cd baremetal
gcloud auth activate-service-account --key-file=/root/bm-gcr.json
gsutil cp gs://anthos-baremetal-release/bmctl/${ABM_VERSION}/linux-amd64/bmctl .
chmod a+x bmctl
mv bmctl /usr/local/sbin/
cd ~
printf "Installing docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
EOF
# [END anthos_bm_gcp_bash_hybrid_init_vm]
printf "✅ Successfully set up admin workstation.\n\n"

# generate SSH key-pair in the admin workstation VM and copy the public-key
# to all the other (control-plane and worker) VMs
printf "🔄 Setting up SSH access from admin workstation to cluster node VMs...\n"
# [START anthos_bm_gcp_bash_hybrid_add_ssh_keys]
gcloud compute ssh root@"${VM_WS}" --zone "${ZONE}" << EOF
set -x
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
sed 's/ssh-rsa/root:ssh-rsa/' ~/.ssh/id_rsa.pub > ssh-metadata
gcloud auth activate-service-account --key-file=/root/bm-gcr.json
for vm in ${VMs[@]}
do
    gcloud compute instances add-metadata \$vm --zone ${ZONE} --metadata-from-file ssh-keys=ssh-metadata
done
EOF
# [END anthos_bm_gcp_bash_hybrid_add_ssh_keys]
printf "✅ Successfully set up SSH access from admin workstation to cluster node VMs.\n\n"

# initiate Anthos on bare metal installation from the admin workstation
printf "🔄 Installing Anthos on bare metal...\n"
# [START anthos_bm_gcp_bash_hybrid_install_abm]
gcloud compute ssh root@"${VM_WS}" --zone "${ZONE}" <<EOF
set -x
export GOOGLE_APPLICATION_CREDENTIALS=/root/bm-gcr.json
bmctl create config -c ${CLUSTER_ID}
EOF
gcloud compute scp --zone "${ZONE}" "${CLUSTER_YAML_FILE}" root@"${VM_WS}":/root/bmctl-workspace/"${CLUSTER_ID}"/"${CLUSTER_ID}".yaml
gcloud compute scp --zone "${ZONE}" "${NFS_YAML_FILE}" root@"${VM_WS}":/root/nfs-csi.yaml
gcloud compute ssh root@"${VM_WS}" --zone "${ZONE}" <<EOF
set -x
export GOOGLE_APPLICATION_CREDENTIALS=/root/bm-gcr.json
export KUBECONFIG=/root/bmctl-workspace/${CLUSTER_ID}/${CLUSTER_ID}-kubeconfig
bmctl create cluster -c ${CLUSTER_ID}
bmctl enable vmruntime --kubeconfig=\${KUBECONFIG}
bash -c 'curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v3.1.0/deploy/install-driver.sh | bash -s v3.1.0 --'
kubectl apply -f nfs-csi.yaml
EOF

# [END anthos_bm_gcp_bash_hybrid_install_abm]
printf "✅ Installation complete. Please check the logs for any errors!!!\n\n"

# Copy the Terraform binary
TF_BIN=$(command -v terraform)
printf "🔄 Copying %s to admin workstation...\n" "${TF_BIN}"
gcloud compute scp --zone "${ZONE}" "${TF_BIN}" root@"${VM_WS}":/usr/local/sbin/
printf "✅ Successfully copy %s to root@%s:/usr/local/sbin/\n\n" "${TF_BIN}" "${VM_WS}"
