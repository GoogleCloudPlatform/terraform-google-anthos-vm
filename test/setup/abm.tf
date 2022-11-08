/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  tmp_dir            = ".tmp"
  zone               = "us-central1-a"
  cluster_id         = "cluster1"
  machine_type       = "n1-standard-8"
  workstation_node   = "${var.node_prefix}-ws"
  controlplane_nodes = [for i in range(var.controlplane_node_count) : "${var.node_prefix}-cp-${i}"]
  worker_nodes       = [for i in range(var.worker_node_count) : "${var.node_prefix}-w-${i}"]
  node_names         = concat([local.workstation_node], local.controlplane_nodes, local.worker_nodes)
  # Map from node name to the VxLAN IP.
  node_vxlan_ips = { for idx, name in local.node_names : name => format("10.200.0.%d", idx + 2) }
  # List of controlplan nodes VxLAN IPs.
  controlplane_vxlan_ips = [for name in local.controlplane_nodes : local.node_vxlan_ips[name]]
  # List of worker nodes VxLAN IPs.
  worker_vxlan_ips           = [for name in local.worker_nodes : local.node_vxlan_ips[name]]
  cluster_yaml_file          = "${local.cluster_id}.yaml"
  cluster_yaml_template_file = "templates/anthos_gce_cluster.tpl"
  kubeconfig                 = "/root/bmctl-workspace/${local.cluster_id}/${local.cluster_id}-kubeconfig"
  gcs_secret_ref             = "gcs-sa"
  nfs_yaml_template_file     = "templates/nfs-csi.tpl"
  nfs_yaml_file              = "nfs-csi.yaml"
}

resource "local_sensitive_file" "credentials_file" {
  content  = base64decode(google_service_account_key.int_test.private_key)
  filename = "${local.tmp_dir}/sa.json"
}

resource "local_file" "destroy_script" {
  filename             = "${local.tmp_dir}/destroy.sh"
  file_permission      = 0555
  directory_permission = 0555
  content              = <<EOT
#!/bin/bash
printf "🔄 Activating Service Account[%s]...\n" "$SERVICE_ACCOUNT"
gcloud auth activate-service-account --project=${module.project.project_id} --key-file=${abspath(local_sensitive_file.credentials_file.filename)}
printf "✅ Service Account activated.\n\n"

printf "🔄 Deleting GCE VMs...\n"
gcloud compute instances delete ${join(" ", local.node_names)} --quiet --project ${module.project.project_id} --zone ${local.zone} --verbosity=none || true
printf "✅ GCE VMS deleted.\n\n"

printf "🔄 Deleting GKE fleet membership...\n"
gcloud container fleet memberships unregister --quiet ${local.cluster_id} --project=${module.project.project_id} --gke-cluster=${local.zone}/${local.cluster_id} --verbosity=none || true
printf "✅ GKE hub membership deleted.\n\n"

printf "🔄 Deleting GKE fleet membership...\n"
gcloud container fleet memberships delete --quiet --project ${module.project.project_id} ${local.cluster_id} --verbosity=none || true
printf "✅ GKE hub membership deleted.\n\n"
EOT
}

resource "google_compute_network" "default" {
  name    = "abm"
  project = module.project.project_id
  depends_on = [
    google_service_account_key.int_test,
  ]
}

resource "google_compute_firewall" "internal" {
  name    = "abm-allow-internal"
  network = google_compute_network.default.name
  project = module.project.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.128.0.0/9"]
  priority      = 65534

  depends_on = [
    google_compute_network.default,
  ]
}

resource "google_compute_firewall" "ssh" {
  name    = "abm-allow-ssh"
  network = google_compute_network.default.name
  project = module.project.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 65534

  depends_on = [
    google_compute_network.default,
  ]
}

resource "google_filestore_instance" "abm_nfs" {
  name     = "${substr(local.cluster_id, 0, min(12, length(local.cluster_id)))}-nfs"
  location = local.zone
  tier     = "STANDARD"
  project  = module.project.project_id

  file_shares {
    capacity_gb = 1024
    name        = "${local.cluster_id}_fs"
  }

  networks {
    network = google_compute_network.default.name
    modes   = ["MODE_IPV4"]
  }

  depends_on = [
    google_compute_network.default,
    google_project_iam_member.int_test,
  ]
}

resource "google_compute_firewall" "filestore_ingress" {
  name    = "filestore-ingress"
  network = google_compute_network.default.name
  project = module.project.project_id

  allow {
    protocol = "tcp"
    ports    = ["111", "2046", "2049", "2050", "4045"]
  }

  source_ranges = google_filestore_instance.abm_nfs.networks[0].ip_addresses

  depends_on = [
    google_compute_network.default,
  ]
}

// Generate the Anthos bare metal nfs yaml file using the template.
resource "local_file" "nfs_yaml" {
  filename = "${local.tmp_dir}/${local.nfs_yaml_file}"
  content = templatefile(local.nfs_yaml_template_file, {
    nfs_server = google_filestore_instance.abm_nfs.networks[0].ip_addresses[0]
    nfs_share  = google_filestore_instance.abm_nfs.file_shares[0].name
  })
  depends_on = [
    google_filestore_instance.abm_nfs,
    google_compute_firewall.filestore_ingress,
  ]
}

resource "local_file" "cluster_yaml_bundledlb" {
  filename = "${local.tmp_dir}/${local.cluster_yaml_file}"
  content = templatefile(local.cluster_yaml_template_file, {
    clusterId       = local.cluster_id,
    projectId       = module.project.project_id,
    controlPlaneIps = local.controlplane_vxlan_ips,
    workerNodeIps   = local.worker_vxlan_ips
    abmVersion      = var.abm_version
  })
}

resource "null_resource" "abm_cluster" {
  triggers = {
    project_id      = module.project.project_id
    zone            = local.zone
    cluster_id      = local.cluster_id
    service_account = google_service_account.int_test.email
    network         = google_compute_network.default.name
    destroy_script  = local_file.destroy_script.filename
  }

  provisioner "local-exec" {
    command     = "./scripts/install_hybrid_cluster.sh"
    interpreter = ["/bin/bash", "-e"]
    environment = {
      PROJECT_ID        = module.project.project_id
      ZONE              = local.zone
      CLUSTER_ID        = local.cluster_id
      SERVICE_ACCOUNT   = google_service_account.int_test.email
      CREDENTIALS_FILE  = abspath(local_sensitive_file.credentials_file.filename)
      ABM_VERSION       = var.abm_version
      NODE_NAMES        = join(",", local.node_names)
      VXLAN_IPS         = join(",", [for name in local.node_names : local.node_vxlan_ips[name]])
      CLUSTER_YAML_FILE = abspath(local_file.cluster_yaml_bundledlb.filename)
      NETWORK           = google_compute_network.default.name
      NFS_YAML_FILE     = abspath(local_file.nfs_yaml.filename)
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = self.triggers.destroy_script
    interpreter = ["/bin/bash", "-e"]
  }

  depends_on = [
    google_compute_network.default,
    google_compute_firewall.ssh,
    google_compute_firewall.internal,
    local_sensitive_file.credentials_file,
    local_file.destroy_script,
    google_project_iam_member.int_test,
    local_file.nfs_yaml,
  ]
}

module "gcloud" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 3.1"

  platform                 = "linux"
  skip_download            = true
  service_account_key_file = abspath(local_sensitive_file.credentials_file.filename)

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "compute ssh --project=${module.project.project_id} --zone=${local.zone} root@${local.workstation_node} --command=\"kubectl --kubeconfig=${local.kubeconfig} create secret generic ${local.gcs_secret_ref} --from-file=creds-gcp.json=bm-gcr.json\""
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "compute ssh --project=${module.project.project_id} --zone=${local.zone} root@${local.workstation_node} --command=\"kubectl --kubeconfig=${local.kubeconfig} delete secret ${local.gcs_secret_ref}\""

  module_depends_on = [
    null_resource.abm_cluster,
  ]
}
