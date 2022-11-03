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

module "general_vm_type" {
  source = "../../modules/vm-type"
  name   = "general"
  vcpus  = 4
  memory = "8Gi"
}

module "gpu_vm_type" {
  source = "../../modules/vm-type"
  name   = "gpu"
  vcpus  = 4
  memory = "8Gi"
  gpu = {
    model    = "vm-a100"
    quantity = 1
  }
}

module "advanced_vm_type" {
  source                   = "../../modules/vm-type"
  name                     = "advanced"
  vcpus                    = 4
  memory                   = "8Gi"
  dedicated_cpu            = true
  is_guaranteed            = true
  isolated_emulator_thread = true
  hugepage_size            = "2Mi"
}
