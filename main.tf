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

locals {
  os_type                = var.is_windows ? "Windows" : "Linux"
  use_exsiting_boot_disk = var.boot_disk_name == "" ? false : true
  boot_disk_name         = var.boot_disk_name == "" ? "${var.name}-boot-disk" : var.boot_disk_name
  use_advanced_compute   = var.is_guaranteed && var.dedicated_cpu

  compute_base = var.vm_type_name == "" ? {
    virtualMachineTypeName = ""
    cpu = {
      vcpus = var.vcpus
    }
    memory = {
      capacity = var.memory
    }
    guaranteed = var.is_guaranteed
    advancedCompute = local.use_advanced_compute ? {
      dedicatedCPUPlacement       = var.dedicated_cpu
      isolatedEmulatorThread      = var.isolated_emulator_thread
      hugePageSize                = var.hugepage_size
      numaGuestMappingPassthrough = var.numa_guest_mapping_passthrough ? {} : null
    } : null
    } : {
    virtualMachineTypeName = var.vm_type_name
    cpu                    = null
    memory                 = null
    guaranteed             = null
    advancedCompute        = null
  }
  compute = { for k, v in local.compute_base : k => v if v != null } # Remove the sections if they are null

  firmware = var.boot_loader_type == "" ? null : {
    bootloader = {
      type             = var.boot_loader_type
      enableSecureBoot = var.enable_secure_boot
    }
  }

  spec_base = {
    osType                           = local.os_type
    compute                          = local.compute
    scheduling                       = var.scheduling
    autoRestartOnConfigurationChange = var.auto_restart_on_config_change
    # autoInstallGuestAgent            = var.auto_install_guest_agent
    gpu      = var.vm_type_name == "" ? var.gpu : null
    firmware = local.firmware
    guestEnvironment = var.guest_environment == null ? null : {
      accessManagement = var.guest_environment.enable_access_management ? {
        enable = var.guest_environment.enable_access_management
      } : null
    }
    disks = concat([
      {
        boot                   = true
        autoDelete             = !local.use_exsiting_boot_disk
        virtualMachineDiskName = local.boot_disk_name
      }
      ], [for disk in var.extra_disks : {
        virtualMachineDiskName = disk["name"]
        readOnly               = disk["readonly"]
        autoDelete             = disk["auto_delete"]
    }])
    interfaces = concat([
      {
        name        = "eth0"
        networkName = "pod-network"
        default     = true
      }
      ], [for intf in var.extra_interfaces : {
        name        = intf["name"]
        networkName = intf["network"]
        ipAddresses = intf["ips"]
    }])
  }
  spec = { for k, v in local.spec_base : k => v if v != null } # Remove the sections if they are null
}

module "boot_disk" {
  count           = local.use_exsiting_boot_disk ? 0 : 1
  source          = "./modules/vm-disk"
  name            = local.boot_disk_name
  namespace       = var.namespace
  disk_size       = var.boot_disk_size
  gcs_source      = var.boot_disk_gcs_source
  http_source     = var.boot_disk_http_source
  registry_source = var.boot_disk_registry_source
}

resource "kubernetes_manifest" "vm_instance" {
  manifest = {
    apiVersion = "vm.cluster.gke.io/v1"
    kind       = "VirtualMachine"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = local.spec
  }
}
