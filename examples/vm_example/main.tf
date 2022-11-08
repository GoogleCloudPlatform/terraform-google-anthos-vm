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

module "anthos_vm" {
  source = "../.."

  name = "anthos-vm"
  boot_disk_gcs_source = {
    url       = var.gcs_images["ubuntu2004"]
    secretRef = var.gcs_secret
  }
  boot_disk_size = "20Gi"
  vcpus          = 2
  memory         = "8Gi"
  storage_class  = "nfs-csi"

  wait_fields = {
    "status.state" = "Running"
  }
}

module "boot_disk" {
  source = "../../modules/vm-disk"
  gcs_source = {
    url       = var.gcs_images["ubuntu2004"]
    secretRef = var.gcs_secret
  }
  name          = "boot-disk"
  disk_size     = "20Gi"
  storage_class = "nfs-csi"
}

module "data_disk" {
  source        = "../../modules/vm-disk"
  name          = "data-disk"
  disk_size     = "20Gi"
  storage_class = "nfs-csi"
}

module "vm_type" {
  source = "../../modules/vm-type"
  name   = "myvmtype"
  vcpus  = 4
  memory = "8Gi"
}

module "anthos_vm_with_ref" {
  source         = "../.."
  name           = "anthos-vm-with-ref"
  boot_disk_name = module.boot_disk.disk_name
  vm_type_name   = module.vm_type.vm_type_name
  extra_disks = [
    {
      name = module.data_disk.disk_name
    }
  ]
  wait_fields = {
    "status.state" = "Running"
  }
  depends_on = [
    module.vm_type,
    module.data_disk,
    module.boot_disk,
  ]
}

