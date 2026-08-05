terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0, < 8.0"
    }
  }
}

provider "google" {
  project = "example-project-123456"
  region  = "us-central1"
}

module "bucket" {
  source      = "../../"
  bucket_name = "iacbazaar-example-bucket-12345"
  project_id  = "example-project-123456"
  location    = "us-central1"

  iam_members = {
    app_reader = {
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:app@example-project-123456.iam.gserviceaccount.com"
    }
  }

  labels = {
    environment = "example"
    managed_by  = "iac-bazaar"
  }
}

output "bucket_url" {
  value = module.bucket.bucket_url
}
