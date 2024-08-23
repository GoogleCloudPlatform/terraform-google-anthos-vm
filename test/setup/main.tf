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

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 16.0"

  name              = "ci-anthos-vm"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "anthos.googleapis.com",
    "anthosaudit.googleapis.com",
    "anthosgke.googleapis.com",
    "connectgateway.googleapis.com",
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "file.googleapis.com"
  ]

  disable_services_on_destroy = false
}

resource "google_storage_bucket" "vm_images" {
  name                        = "${module.project.project_id}-vm-images"
  location                    = "US-CENTRAL1"
  project                     = module.project.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "null_resource" "download_images" {
  count = length(var.vm_images)
  triggers = {
    image_name = var.vm_images[count.index].name
    image_url  = var.vm_images[count.index].url
  }

  provisioner "local-exec" {
    command = "curl --create-dirs -o ${local.tmp_dir}/${self.triggers.image_name} ${self.triggers.image_url}"
  }
}

resource "google_storage_bucket_object" "images" {
  count  = length(var.vm_images)
  name   = var.vm_images[count.index].name
  source = "${local.tmp_dir}/${var.vm_images[count.index].name}"
  bucket = google_storage_bucket.vm_images.name
  depends_on = [
    null_resource.download_images,
  ]
}
