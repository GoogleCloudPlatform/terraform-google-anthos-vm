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
variable "org_id" {
  description = "The numeric organization id"
}

variable "folder_id" {
  description = "The folder to deploy in"
}

variable "billing_account" {
  description = "The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ"
}

variable "abm_version" {
  type        = string
  default     = "1.13.0"
  description = "The version of Anthos Bare Metal."
}

variable "controlplane_node_count" {
  type        = number
  default     = 1
  description = "Number of the control plane nodes."
}

variable "worker_node_count" {
  type        = number
  default     = 2
  description = "Number of the worker nodes."
}

variable "node_prefix" {
  type        = string
  default     = "abm"
  description = "The prefix of the node name."
}
