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

variable "name" {
  type        = string
  description = "Name of the VM type"
}

variable "vcpus" {
  type        = number
  description = "Number of VCPUs"
}

variable "memory" {
  type        = string
  description = "Memory capacity in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/)."
}

variable "is_guaranteed" {
  type        = bool
  default     = false
  description = "If the resources of the VM are in the guaranteed tier"
}

variable "gpu" {
  type = object({
    model    = string
    quantity = number
  })
  default     = null
  description = <<EOT
    model : "The GPU model the VM want to reserve."
    quantity : "The number of GPU card for the specific GPU model the VM want to reserve."
  EOT
}

variable "dedicated_cpu" {
  type        = bool
  default     = false
  description = "If the VM should be allocated dedicated host CPU cores and each VM CPU core is pinned to each allocated host CPU core."
}

variable "isolated_emulator_thread" {
  type        = bool
  default     = false
  description = "If one more dedicated host CPU core should be allocated to the VM for the QEMU emulator thread."
}

variable "hugepage_size" {
  type        = string
  default     = ""
  description = "Use the huge page instead for the VM memory config. Valid huge pages are 2Mi or 1Gi."
}

variable "numa_guest_mapping_passthrough" {
  type        = bool
  default     = false
  description = "It creates an efficient guest topology based on container NUMA topology"
}

