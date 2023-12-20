# VM Example

This example illustrates how to configure the `anthos-vm` scheduling.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gcs\_images | Map of the image name and GCS URL. | `map(string)` | n/a | yes |
| gcs\_secret | The secret name to pull from GCS bucket. | `string` | n/a | yes |
| kubeconfig\_path | The path to the kubeconfig file. | `string` | n/a | yes |
| workers | List of worker nodes. | `list(string)` | n/a | yes |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
