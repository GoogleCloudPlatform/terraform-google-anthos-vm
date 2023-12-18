/**
 * Copyright 2022 Google LLC
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
  source  = "GoogleCloudPlatform/anthos-vm/google//modules/vm-disk"
  version = "~> 0.1"

  name      = "empty-disk"
  disk_size = "10Gi"
}

# Use a small OS image here because downloading from HTTP is very slow in the test setup.
module "disk_from_http" {
  source  = "GoogleCloudPlatform/anthos-vm/google//modules/vm-disk"
  version = "~> 0.1"

  http_source = {
    url = "https://download.cirros-cloud.net/0.6.0/cirros-0.6.0-x86_64-disk.img"
  }
  name      = "disk-http-source"
  disk_size = "20Gi"
}

module "disk_from_gcs" {
  count   = var.gcs_secret == "" ? 0 : 1
  source  = "GoogleCloudPlatform/anthos-vm/google//modules/vm-disk"
  version = "~> 0.1"

  gcs_source = {
    url       = var.gcs_images["ubuntu2004"]
    secretRef = var.gcs_secret
  }
  name      = "disk-gcs-source"
  disk_size = "20Gi"
}
