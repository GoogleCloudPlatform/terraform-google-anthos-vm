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

locals {
  node = var.workers[0]
}


module "anthos_vm" {
  source = "../.."

  name = "myvm"
  boot_disk_gcs_source = {
    url       = var.gcs_images["ubuntu2004"]
    secretRef = var.gcs_secret
  }
  boot_disk_size = "20Gi"
  vcpus          = 2
  memory         = "8Gi"
  storage_class  = "nfs-csi"
  scheduling = {
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = "kubernetes.io/hostname"
                  operator = "In"
                  values   = [local.node]
                }
              ]
            }
          ]
        }
      }
    }
  }
}
