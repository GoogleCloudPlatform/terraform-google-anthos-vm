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

variable "name" {
  type        = string
  description = "Name of the VM"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Namespace where the VM belongs to"
}

variable "is_windows" {
  type        = bool
  default     = false
  description = "If the VM is a windows VM"
}

variable "guest_environment" {
  type = object({
    enable_access_management = optional(bool)
  })
  default = {
    enable_access_management = true
  }
  description = <<EOT
    The guest environment features.
    enable_access_management : "Whether the SSH access management feature should be enabled."
  EOT
}

variable "auto_install_guest_agent" {
  type        = bool
  default     = true
  description = "If auto install/upgrade the guest agent binary when bringing up a VM."
}

variable "auto_restart_on_config_change" {
  type        = bool
  default     = false
  description = "whether to automatically restart a VM to pick up configuration changes."
}

variable "scheduling" {
  type = object({
    nodeSelector = optional(map(string))
    affinity     = optional(any)
    tolerations  = optional(list(any))
  })
  default     = null
  description = <<EOT
    nodeSelector : "The node labels that the host node of this VM must have."
    affinity : "The affinity rules of the VM. The object needs to align with the k8s Affinity type."
    tolerations : "Allows the VM to schedule onto nodes with matching taints. The list elements should have the type align with k8s Toleration type."
  EOT
}

variable "cloudinit_nocloud" {
  type = object({
    secretRef = optional(object({
      name = string
    }))
    userDataBase64 = optional(string)
    userData       = optional(string)
    networkDataSecretRef = optional(object({
      name = string
    }))
    networkDataBase64 = optional(string)
    networkData       = optional(string)
  })
  default     = null
  description = <<EOT
    cloud-init nocloud source https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
    secretRef : "Then name of a k8s secret that contains the userdata."
    userDataBase64 : "Userdata as a base64 encoded string."
    userData : "Inline userdata."
    networkDataSecretRef : "The name of a k8s secret that contains the networkdata."
    networkDataBase64 : "Networkdata as a base64 encoded string."
    networkData : "Inline networkdata"
  EOT
}

variable "startup_scripts" {
  type = list(object({
    name         = string
    script       = optional(string)
    scriptBase64 = optional(string)
    scriptSecretRef = optional(object({
      name = string
    }))
  }))
  default     = null
  description = <<EOT
    A list of startup scripts of the VM.
    name : "The name of a script."
    script : "The plain text string of the script."
    scriptBase64 : "The base64 encoded string of the script."
    scriptSecretRef : "The name of a k8s secret that contains the script."
  EOT
}

# Disk Inputs
variable "boot_disk_name" {
  type        = string
  default     = ""
  description = "The name of the existing boot disk in the same namespace."
}

variable "boot_disk_http_source" {
  type = object({
    url                = string
    secretRef          = optional(string)
    certConfigMap      = optional(string)
    extraHeaders       = optional(list(string))
    secretExtraHeaders = optional(list(string))
  })
  default     = null
  description = <<EOT
    url : "URL of the http(s) endpoint"
    secretRef : "A Secret reference which contains accessKeyId (user name) base64 encoded, and secretKey (password) also base64 encoded"
    certConfigMap : "A configmap reference which contains a Certificate Authority(CA) public key, and a base64 encoded pem certificate"
    extraHeaders : "A list of strings containing extra headers to include with HTTP transfer requests"
    secretExtraHeaders : "A list of Secret references, each containing an extra HTTP header that may include sensitive information"
  EOT
}

variable "boot_disk_gcs_source" {
  type = object({
    url       = string
    secretRef = optional(string)
  })
  default     = null
  description = <<EOT
    url : "URL of the GCS source"
    secretRef : "A Secret reference needed to access the GCS source"
  EOT
}

variable "boot_disk_registry_source" {
  type = object({
    url           = string
    secretRef     = optional(string)
    certConfigMap = optional(string)
    imageStream   = optional(string)
    pullMethod    = optional(string)
  })
  default     = null
  description = <<EOT
    url : "URL of the registry source (starting with the scheme: docker, oci-archive)"
    secretRef : "A Secret reference needed to access the Registry source"
    certConfigMap : "A configmap reference provides registry certs"
    imageStream : "The name of image stream for import"
    pullMethod : "pullMethod can be either "pod" (default import), or "node" (node docker cache based import)"
  EOT
}

variable "boot_disk_size" {
  type        = string
  default     = "20Gi"
  description = "Boot disk size in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/)."
}

variable "boot_loader_type" {
  type        = string
  default     = ""
  description = "The initial machine booting options when powering on before loading the kernel. The supported boot options are uefi or bios."
}

variable "enable_secure_boot" {
  type        = bool
  default     = true
  description = "Whether to assist blocking modified or malicious code from loading. Only work with UEFI bootloader"
}

variable "storage_class" {
  type        = string
  default     = "local-shared"
  description = "The name of storage class used to provision the disks"
}

variable "extra_disks" {
  type = list(object({
    name        = string
    readonly    = optional(bool, false)
    auto_delete = optional(bool, false)
  }))
  default     = []
  description = <<EOT
    A list of existing disks that will be used by the VM.
    name : "Name of the VM disk in the same namespace"
    readonly : "If the VM disk is readonly."
    auto_delete : "If to delete the VM disk when the VM is deleted."
  EOT
}

# Compute Inputs
variable "vm_type_name" {
  type        = string
  default     = ""
  description = "Name of the exsiting virtual machine type"
}

variable "vcpus" {
  type        = number
  default     = 1
  description = "Number of VCPUs"
}

variable "memory" {
  type        = string
  default     = "4Gi"
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

# Networking Inputs
variable "extra_interfaces" {
  type = list(object({
    name    = string
    network = string
    ips     = list(string)
  }))
  default     = []
  description = <<EOT
    A list of existing disks that will be used by the VM.
    name : "Name of the network interface in the VM."
    network : "Name of the Anthos network object."
    ips : "A list of IP addresses from the network to be allocated to the VM."
  EOT
}

# Status check
variable "wait_fields" {
  type = map(string)
  default = {
    "status.state" = "Running"
  }
  description = "A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use `*` for any value."
}

variable "wait_conditions" {
  type = list(object({
    type   = string
    status = string
  }))
  default     = []
  description = "A list of conditions to wait for."
}

variable "create_timeout" {
  type        = string
  default     = "10m"
  description = "Timeout for the disk creation."
}

variable "update_timeout" {
  type        = string
  default     = "10m"
  description = "Timeout for the disk udpate."
}

variable "delete_timeout" {
  type        = string
  default     = "1m"
  description = "Timeout for the disk deletion."
}
