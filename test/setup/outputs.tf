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

output "project_id" {
  value = module.project.project_id
}

output "sa" {
  value = google_service_account.int_test.email
}

output "workstation" {
  value       = local.workstation_node
  description = "The host name of the workstation node."
}

output "workers" {
  value       = local.worker_nodes
  description = "The list of worker nodes."
}

output "kubeconfig_path" {
  value       = local.kubeconfig
  description = "The kubeconfig path on the workstation."
  depends_on = [
    null_resource.abm_cluster
  ]
}

output "zone" {
  value       = local.zone
  description = "GCP zone of the cluster."
}

output "gcs_images" {
  value       = { for i in google_storage_bucket_object.images : i.name => "${google_storage_bucket.vm_images.url}/${i.name}" }
  description = "Map of the image name to GCS URL. The key is an arbitary string and the value is the GCS URL of the VM image."
}

output "gcs_secret" {
  value       = local.gcs_secret_ref
  description = "The secret name to access GCS bucket."
}
