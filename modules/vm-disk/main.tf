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

locals {

  http_source     = var.http_source == null ? null : { for k, v in var.http_source : k => v if v != null }
  registry_source = var.registry_source == null ? null : { for k, v in var.registry_source : k => v if v != null }
  gcs_source      = var.gcs_source == null ? null : { for k, v in var.gcs_source : k => v if v != null }
  sources         = zipmap(["gcs", "http", "registry"], [local.gcs_source, local.http_source, local.registry_source])
  image_source    = { for k, v in local.sources : k => v if v != null }
  is_empty_disk   = length(local.image_source) == 0 ? true : false
  spec = {
    source           = local.is_empty_disk ? null : local.image_source
    size             = var.disk_size
    storageClassName = var.storage_class
  }
}

resource "null_resource" "data_source_check" {
  lifecycle {
    precondition {
      condition     = local.is_empty_disk || length(local.image_source) == 1
      error_message = "At most one data source can be specified."
    }
  }
}

resource "kubernetes_manifest" "disk" {
  manifest = {
    apiVersion = "vm.cluster.gke.io/v1"
    kind       = "VirtualMachineDisk"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = { for k, v in local.spec : k => v if v != null }
  }

  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}
