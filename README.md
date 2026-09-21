# Cloud Storage Bucket

[![IaC Bazaar: live-tested](https://www.iac-bazaar.com/api/artifacts/gcp-gcs-bucket/badge)](https://www.iac-bazaar.com/catalog/gcp-gcs-bucket?utm_source=syndication&utm_medium=readme&utm_campaign=artifact)

Hardened GCS bucket with uniform access, versioning, lifecycle/soft-delete policies, CMEK and least-privilege IAM.

This module was **applied to a real Google Cloud account, verified, and destroyed** on 2026-06-30 - not just `terraform validate`d.

## Usage

```hcl
module "gcs_bucket" {
  source  = "registry.terraform.io/CyberCoreSystems/gcs-bucket/google"
  version = "~> 1.0"

  # See variables.tf for the full input contract.
}
```

## Why this module

Every module we publish goes through the same checks before release:

| check | what it means |
|---|---|
| `tofu validate` + `tflint` | it parses and lints clean |
| `checkov` | scanned for insecure defaults |
| **live test** | **really applied to a cloud account, outputs verified, then destroyed** |

That last row is the one most module catalogues skip. A module that has never
been applied has never been proven.

## Provider compatibility

```
google >= 7.0, < 8.0
```

## More modules

This is one of **673 Terraform modules across 19 cloud platforms** on
IaC Bazaar, 113 of them live-tested:
AWS, Azure, GCP, Oracle OCI, Cloudflare, Akamai, DigitalOcean, Linode, Hetzner,
Vultr, Scaleway, Alibaba, IBM, UpCloud, Civo, Exoscale, OVH, Tencent and Huawei.

Browse the full catalogue at **[www.iac-bazaar.com](https://www.iac-bazaar.com)**, including
production landing zones for AWS, Azure and GCP that have each been live-tested
as a single composed apply.

- Terraform module 1.0.0, live-tested on IaC Bazaar: [Cloud Storage Bucket](https://www.iac-bazaar.com/catalog/gcp-gcs-bucket?utm_source=syndication&utm_medium=readme&utm_campaign=artifact)
- How verification works: [https://www.iac-bazaar.com/verified](https://www.iac-bazaar.com/verified)

## Licence

See [LICENSE](./LICENSE).
