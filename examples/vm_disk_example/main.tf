/**
 * Copyright 2021 Google LLC
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

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

module "emtpy_disk" {
  source    = "../../modules/vm-disk"
  name      = "empty-disk"
  disk_size = "10Gi"
}

module "disk_from_http" {
  source = "../../modules/vm-disk"
  http_source = {
    url = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  }
  name      = "disk-http-source"
  disk_size = "20Gi"
}

module "disk_from_gcs" {
  count  = var.gcs_secret == "" ? 0 : 1
  source = "../../modules/vm-disk"
  gcs_source = {
    url       = "gs://kubevirt-ci-vm-images/focal-server-cloudimg-amd64.img"
    secretRef = var.gcs_secret
  }
  name      = "disk-gcs-source"
  disk_size = "20Gi"
}
