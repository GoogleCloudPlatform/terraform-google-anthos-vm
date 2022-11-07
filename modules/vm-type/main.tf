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
  use_advanced_compute = var.is_guaranteed && var.dedicated_cpu
  advanced_compute = {
    dedicatedCPUPlacement       = var.dedicated_cpu
    isolatedEmulatorThread      = var.isolated_emulator_thread
    hugePageSize                = var.hugepage_size
    numaGuestMappingPassthrough = var.numa_guest_mapping_passthrough ? {} : null
  }
  spec = {
    cpu = {
      vcpus = var.vcpus
    }
    memory = {
      capacity = var.memory
    }
    guaranteed      = var.is_guaranteed
    gpu             = var.gpu
    advancedCompute = local.use_advanced_compute ? { for k, v in local.advanced_compute : k => v if v != null } : null
  }
}

resource "kubernetes_manifest" "vm_type" {
  manifest = {
    apiVersion = "vm.cluster.gke.io/v1"
    kind       = "VirtualMachineType"
    metadata = {
      name = var.name
    }
    spec = { for k, v in local.spec : k => v if v != null }
  }
}
