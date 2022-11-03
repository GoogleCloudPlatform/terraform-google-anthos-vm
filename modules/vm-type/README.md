## VM Type Submodule for Anthos VM
The module is to create common compute types that can be referenced in Anthos VMs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dedicated\_cpu | If the VM should be allocated dedicated host CPU cores and each VM CPU core is pinned to each allocated host CPU core. | `bool` | `false` | no |
| gpu | model : "The GPU model the VM want to reserve."<br>    quantity : "The number of GPU card for the specific GPU model the VM want to reserve." | <pre>object({<br>    model    = string<br>    quantity = number<br>  })</pre> | `null` | no |
| hugepage\_size | Use the huge page instead for the VM memory config. Valid huge pages are 2Mi or 1Gi. | `string` | `""` | no |
| is\_guaranteed | If the resources of the VM are in the guaranteed tier | `bool` | `false` | no |
| isolated\_emulator\_thread | If one more dedicated host CPU core should be allocated to the VM for the QEMU emulator thread. | `bool` | `false` | no |
| memory | Memory capacity in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/). | `string` | n/a | yes |
| name | Name of the VM type | `string` | n/a | yes |
| numa\_guest\_mapping\_passthrough | It creates an efficient guest topology based on container NUMA topology | `bool` | `false` | no |
| vcpus | Number of VCPUs | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vm\_type\_name | Name of the VM type. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
