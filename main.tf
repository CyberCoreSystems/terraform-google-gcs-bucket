# Hardened-by-default Cloud Storage bucket: uniform bucket-level access,
# enforced public-access prevention, versioning, opinionated lifecycle and
# soft-delete policies, optional CMEK, and least-privilege bucket IAM.
# Works with Terraform and OpenTofu.

resource "google_storage_bucket" "this" {
  name     = var.bucket_name
  project  = var.project_id
  location = var.location

  storage_class               = var.storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy
  requester_pays              = var.requester_pays
  labels                      = var.labels

  versioning {
    enabled = var.versioning_enabled
  }

  # CMEK: requires the Cloud Storage service agent to hold
  # roles/cloudkms.cryptoKeyEncrypterDecrypter on the key (see README).
  dynamic "encryption" {
    for_each = var.kms_key_name == null ? [] : [var.kms_key_name]
    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "autoclass" {
    for_each = var.autoclass_enabled ? [1] : []
    content {
      enabled                = true
      terminal_storage_class = var.autoclass_terminal_storage_class
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
      condition {
        age                        = lifecycle_rule.value.condition.age
        created_before             = lifecycle_rule.value.condition.created_before
        with_state                 = lifecycle_rule.value.condition.with_state
        matches_storage_class      = lifecycle_rule.value.condition.matches_storage_class
        matches_prefix             = lifecycle_rule.value.condition.matches_prefix
        matches_suffix             = lifecycle_rule.value.condition.matches_suffix
        num_newer_versions         = lifecycle_rule.value.condition.num_newer_versions
        days_since_noncurrent_time = lifecycle_rule.value.condition.days_since_noncurrent_time
      }
    }
  }

  # 0 disables soft delete; otherwise 7-90 days expressed in seconds.
  soft_delete_policy {
    retention_duration_seconds = var.soft_delete_retention_seconds
  }

  # WORM-style retention. Locking is irreversible — see README.
  dynamic "retention_policy" {
    for_each = var.retention_policy == null ? [] : [var.retention_policy]
    content {
      retention_period = retention_policy.value.retention_period_seconds
      is_locked        = retention_policy.value.is_locked
    }
  }

  dynamic "logging" {
    for_each = var.access_log_bucket == null ? [] : [var.access_log_bucket]
    content {
      log_bucket        = logging.value
      log_object_prefix = var.access_log_prefix
    }
  }

  lifecycle {
    precondition {
      condition     = !var.autoclass_enabled || var.storage_class == "STANDARD"
      error_message = "Autoclass requires storage_class = \"STANDARD\" (objects then transition automatically)."
    }
  }
}

# Least-privilege bucket IAM. Uniform bucket-level access means these bindings
# are the only access control — there are no object ACLs to drift.
resource "google_storage_bucket_iam_member" "this" {
  for_each = var.iam_members

  bucket = google_storage_bucket.this.name
  role   = each.value.role
  member = each.value.member
}
