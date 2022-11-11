# terraform-google-anthos-vm

This module will provide the capability to create [VMs on Anthos Bare Metal](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/vm-runtime/quickstart) clusters easily using Terraform.

This module doesn't interact with the GCP services but the Anthos Bare Metal clusters directly.

## Usage

Basic usage of this module is as follows:

```hcl
provider "kubernetes" {
  config_path = <CLUSTER_KUBECONFIG>
}

module "anthos_vm" {
  source  = "GoogleCloudPlatform/anthos-vm/google"
  version = "~> 0.1"

  name = "myvm"
  boot_disk_http_source = {
    url = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  }
  boot_disk_size = "20Gi"
  vcpus          = 2
  memory         = "8Gi"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_install\_guest\_agent | If auto install/upgrade the guest agent binary when bringing up a VM. | `bool` | `true` | no |
| auto\_restart\_on\_config\_change | whether to automatically restart a VM to pick up configuration changes. | `bool` | `false` | no |
| boot\_disk\_gcs\_source | url : "URL of the GCS source"<br>    secretRef : "A Secret reference needed to access the GCS source" | <pre>object({<br>    url       = string<br>    secretRef = optional(string)<br>  })</pre> | `null` | no |
| boot\_disk\_http\_source | url : "URL of the http(s) endpoint"<br>    secretRef : "A Secret reference which contains accessKeyId (user name) base64 encoded, and secretKey (password) also base64 encoded"<br>    certConfigMap : "A configmap reference which contains a Certificate Authority(CA) public key, and a base64 encoded pem certificate"<br>    extraHeaders : "A list of strings containing extra headers to include with HTTP transfer requests"<br>    secretExtraHeaders : "A list of Secret references, each containing an extra HTTP header that may include sensitive information" | <pre>object({<br>    url                = string<br>    secretRef          = optional(string)<br>    certConfigMap      = optional(string)<br>    extraHeaders       = optional(list(string))<br>    secretExtraHeaders = optional(list(string))<br>  })</pre> | `null` | no |
| boot\_disk\_name | The name of the existing boot disk in the same namespace. | `string` | `""` | no |
| boot\_disk\_registry\_source | url : "URL of the registry source (starting with the scheme: docker, oci-archive)"<br>    secretRef : "A Secret reference needed to access the Registry source"<br>    certConfigMap : "A configmap reference provides registry certs"<br>    imageStream : "The name of image stream for import"<br>    pullMethod : "pullMethod can be either "pod" (default import), or "node" (node docker cache based import)" | <pre>object({<br>    url           = string<br>    secretRef     = optional(string)<br>    certConfigMap = optional(string)<br>    imageStream   = optional(string)<br>    pullMethod    = optional(string)<br>  })</pre> | `null` | no |
| boot\_disk\_size | Boot disk size in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/). | `string` | `"20Gi"` | no |
| boot\_loader\_type | The initial machine booting options when powering on before loading the kernel. The supported boot options are uefi or bios. | `string` | `""` | no |
| cloudinit\_nocloud | cloud-init nocloud source https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html<br>    secretRef : "Then name of a k8s secret that contains the userdata."<br>    userDataBase64 : "Userdata as a base64 encoded string."<br>    userData : "Inline userdata."<br>    networkDataSecretRef : "The name of a k8s secret that contains the networkdata."<br>    networkDataBase64 : "Networkdata as a base64 encoded string."<br>    networkData : "Inline networkdata" | <pre>object({<br>    secretRef = optional(object({<br>      name = string<br>    }))<br>    userDataBase64 = optional(string)<br>    userData       = optional(string)<br>    networkDataSecretRef = optional(object({<br>      name = string<br>    }))<br>    networkDataBase64 = optional(string)<br>    networkData       = optional(string)<br>  })</pre> | `null` | no |
| create\_timeout | Timeout for the disk creation. | `string` | `"10m"` | no |
| dedicated\_cpu | If the VM should be allocated dedicated host CPU cores and each VM CPU core is pinned to each allocated host CPU core. | `bool` | `false` | no |
| delete\_timeout | Timeout for the disk deletion. | `string` | `"1m"` | no |
| enable\_secure\_boot | Whether to assist blocking modified or malicious code from loading. Only work with UEFI bootloader | `bool` | `true` | no |
| extra\_disks | A list of existing disks that will be used by the VM.<br>    name : "Name of the VM disk in the same namespace"<br>    readonly : "If the VM disk is readonly."<br>    auto\_delete : "If to delete the VM disk when the VM is deleted." | <pre>list(object({<br>    name        = string<br>    readonly    = optional(bool, false)<br>    auto_delete = optional(bool, false)<br>  }))</pre> | `[]` | no |
| extra\_interfaces | A list of existing disks that will be used by the VM.<br>    name : "Name of the network interface in the VM."<br>    network : "Name of the Anthos network object."<br>    ips : "A list of IP addresses from the network to be allocated to the VM." | <pre>list(object({<br>    name    = string<br>    network = string<br>    ips     = list(string)<br>  }))</pre> | `[]` | no |
| gpu | model : "The GPU model the VM want to reserve."<br>    quantity : "The number of GPU card for the specific GPU model the VM want to reserve." | <pre>object({<br>    model    = string<br>    quantity = number<br>  })</pre> | `null` | no |
| guest\_environment | The guest environment features.<br>    enable\_access\_management : "Whether the SSH access management feature should be enabled." | <pre>object({<br>    enable_access_management = optional(bool)<br>  })</pre> | <pre>{<br>  "enable_access_management": true<br>}</pre> | no |
| hugepage\_size | Use the huge page instead for the VM memory config. Valid huge pages are 2Mi or 1Gi. | `string` | `""` | no |
| is\_guaranteed | If the resources of the VM are in the guaranteed tier | `bool` | `false` | no |
| is\_windows | If the VM is a windows VM | `bool` | `false` | no |
| isolated\_emulator\_thread | If one more dedicated host CPU core should be allocated to the VM for the QEMU emulator thread. | `bool` | `false` | no |
| memory | Memory capacity in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/). | `string` | `"4Gi"` | no |
| name | Name of the VM | `string` | n/a | yes |
| namespace | Namespace where the VM belongs to | `string` | `"default"` | no |
| numa\_guest\_mapping\_passthrough | It creates an efficient guest topology based on container NUMA topology | `bool` | `false` | no |
| scheduling | nodeSelector : "The node labels that the host node of this VM must have."<br>    affinity : "The affinity rules of the VM. The object needs to align with the k8s Affinity type."<br>    tolerations : "Allows the VM to schedule onto nodes with matching taints. The list elements should have the type align with k8s Toleration type." | <pre>object({<br>    nodeSelector = optional(map(string))<br>    affinity     = optional(any)<br>    tolerations  = optional(list(any))<br>  })</pre> | `null` | no |
| startup\_scripts | A list of startup scripts of the VM.<br>    name : "The name of a script."<br>    script : "The plain text string of the script."<br>    scriptBase64 : "The base64 encoded string of the script."<br>    scriptSecretRef : "The name of a k8s secret that contains the script." | <pre>list(object({<br>    name         = string<br>    script       = optional(string)<br>    scriptBase64 = optional(string)<br>    scriptSecretRef = optional(object({<br>      name = string<br>    }))<br>  }))</pre> | `null` | no |
| storage\_class | The name of storage class used to provision the disks | `string` | `"local-shared"` | no |
| update\_timeout | Timeout for the disk udpate. | `string` | `"10m"` | no |
| vcpus | Number of VCPUs | `number` | `1` | no |
| vm\_type\_name | Name of the exsiting virtual machine type | `string` | `""` | no |
| wait\_conditions | A list of conditions to wait for. | <pre>list(object({<br>    type   = string<br>    status = string<br>  }))</pre> | `[]` | no |
| wait\_fields | A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use `*` for any value. | `map(string)` | <pre>{<br>  "status.state": "Running"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| vm\_name | n/a |
| vm\_namespace | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v1.3
- [Terraform Provider for Kubebernetes][terraform-provider-kubernetes] plugin v2.15

### Environment

Unlike the other GCP Terraform module, this module interact with the Anthos Bare Metal clusters directly. Therefore, it needs to be executed in the environment that has the access to the Anthos Bare Metal cluster.

### Service Account

The service account has to bind the `kubevm.edit` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) using [RoleBinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding).

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

Other references:
* [iam-module](https://registry.terraform.io/modules/terraform-google-modules/iam/google)
* [project-factory-module](https://registry.terraform.io/modules/terraform-google-modules/project-factory/google)
* [terraform-provider-kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
* [terraform-provider-gcp](https://www.terraform.io/docs/providers/google/index.html)
* [terraform](https://www.terraform.io/downloads.html)

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
