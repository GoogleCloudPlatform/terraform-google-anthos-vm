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
  description = "Name of the VM disk"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Namespace of the VM disk"
}

variable "http_source" {
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

variable "gcs_source" {
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

variable "registry_source" {
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

variable "disk_size" {
  type        = string
  default     = "20G"
  description = "Disk size in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/)."
}

variable "storage_class" {
  type        = string
  default     = "local-shared"
  description = "The name of storage class used to provision the disks"
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
