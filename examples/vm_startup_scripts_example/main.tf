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

resource "kubernetes_secret" "script" {
  metadata {
    name = "startup-script"
  }

  data = {
    script = base64encode("echo \"script in k8s secret\"")
  }
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
  startup_scripts = [
    {
      name   = "plan_text_script"
      script = "echo \"plan text script\""
    },
    {
      name         = "base64_encoded_script"
      scriptBase64 = base64encode("echo \"base64 endoded script\"")
    },
    {
      name = "script_in_secret"
      scriptSecretRef = {
        name = kubernetes_secret.script.metadata[0].name
      }
    },
  ]
}
