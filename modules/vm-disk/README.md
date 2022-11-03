## VM Disk Submodule for Anthos VM
The module is to create individual VM disks that will be used by Anthos VMs.
It supports both the empty disk or disk with images from given data sources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| disk\_size | Disk size in k8s quantity format(https://kubernetes.io/docs/reference/kubernetes-api/common-definitions/quantity/). | `string` | `"20G"` | no |
| gcs\_source | url : "URL of the GCS source"<br>    secretRef : "A Secret reference needed to access the GCS source" | <pre>object({<br>    url       = string<br>    secretRef = optional(string)<br>  })</pre> | `null` | no |
| http\_source | url : "URL of the http(s) endpoint"<br>    secretRef : "A Secret reference which contains accessKeyId (user name) base64 encoded, and secretKey (password) also base64 encoded"<br>    certConfigMap : "A configmap reference which contains a Certificate Authority(CA) public key, and a base64 encoded pem certificate"<br>    extraHeaders : "A list of strings containing extra headers to include with HTTP transfer requests"<br>    secretExtraHeaders : "A list of Secret references, each containing an extra HTTP header that may include sensitive information" | <pre>object({<br>    url                = string<br>    secretRef          = optional(string)<br>    certConfigMap      = optional(string)<br>    extraHeaders       = optional(list(string))<br>    secretExtraHeaders = optional(list(string))<br>  })</pre> | `null` | no |
| name | Name of the VM disk | `string` | n/a | yes |
| namespace | Namespace of the VM disk | `string` | `"default"` | no |
| registry\_source | url : "URL of the registry source (starting with the scheme: docker, oci-archive)"<br>    secretRef : "A Secret reference needed to access the Registry source"<br>    certConfigMap : "A configmap reference provides registry certs"<br>    imageStream : "The name of image stream for import"<br>    pullMethod : "pullMethod can be either "pod" (default import), or "node" (node docker cache based import)" | <pre>object({<br>    url           = string<br>    secretRef     = optional(string)<br>    certConfigMap = optional(string)<br>    imageStream   = optional(string)<br>    pullMethod    = optional(string)<br>  })</pre> | `null` | no |
| storage\_class | The name of storage class used to provision the disks | `string` | `"local-shared"` | no |

## Outputs

| Name | Description |
|------|-------------|
| disk\_name | Name of the VM disk. |
| disk\_namespace | Namespace of the VM disk. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
