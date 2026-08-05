variable "bucket_name" {
  description = "Globally-unique bucket name (3-63 chars; lowercase letters, digits, hyphens, underscores, dots; must not start with \"goog\")."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 chars of lowercase letters, digits, '-', '_', '.', starting and ending alphanumeric."
  }

  validation {
    condition     = !startswith(var.bucket_name, "goog")
    error_message = "bucket_name must not start with the reserved prefix \"goog\"."
  }
}

variable "project_id" {
  description = "GCP project ID that owns the bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "location" {
  description = "Bucket location: region (e.g. us-central1), dual-region (e.g. nam4) or multi-region (US, EU, ASIA)."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Default storage class for objects."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "storage_class must be one of STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "versioning_enabled" {
  description = "Enable object versioning (pairs with the default noncurrent-version lifecycle rule)."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to destroy a non-empty bucket."
  type        = bool
  default     = false
}

variable "requester_pays" {
  description = "Enable Requester Pays (callers are billed for access)."
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "Full Cloud KMS key resource ID for CMEK (projects/.../cryptoKeys/...). If null, Google-managed encryption is used."
  type        = string
  default     = null
}

variable "autoclass_enabled" {
  description = "Enable Autoclass (automatic storage-class transitions). Requires storage_class = STANDARD."
  type        = bool
  default     = false
}

variable "autoclass_terminal_storage_class" {
  description = "Coldest class Autoclass may transition to: NEARLINE or ARCHIVE."
  type        = string
  default     = "NEARLINE"

  validation {
    condition     = contains(["NEARLINE", "ARCHIVE"], var.autoclass_terminal_storage_class)
    error_message = "autoclass_terminal_storage_class must be NEARLINE or ARCHIVE."
  }
}

variable "lifecycle_rules" {
  description = "Lifecycle rules. The default keeps the 10 newest noncurrent versions and aborts incomplete multipart uploads after 7 days. Set [] to disable."
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                        = optional(number)
      created_before             = optional(string)
      with_state                 = optional(string)
      matches_storage_class      = optional(list(string))
      matches_prefix             = optional(list(string))
      matches_suffix             = optional(list(string))
      num_newer_versions         = optional(number)
      days_since_noncurrent_time = optional(number)
    })
  }))
  default = [
    {
      action    = { type = "Delete" }
      condition = { num_newer_versions = 10, with_state = "ARCHIVED" }
    },
    {
      action    = { type = "AbortIncompleteMultipartUpload" }
      condition = { age = 7 }
    },
  ]

  validation {
    condition = alltrue([
      for r in var.lifecycle_rules : contains(["Delete", "SetStorageClass", "AbortIncompleteMultipartUpload"], r.action.type)
    ])
    error_message = "Lifecycle action type must be Delete, SetStorageClass or AbortIncompleteMultipartUpload."
  }

  validation {
    condition = alltrue([
      for r in var.lifecycle_rules : r.action.type != "SetStorageClass" || r.action.storage_class != null
    ])
    error_message = "SetStorageClass actions must set action.storage_class."
  }
}

variable "soft_delete_retention_seconds" {
  description = "Soft-delete retention in seconds: 0 disables, otherwise 604800 (7d) to 7776000 (90d). Default is GCP's 7 days."
  type        = number
  default     = 604800

  validation {
    condition     = var.soft_delete_retention_seconds == 0 || (var.soft_delete_retention_seconds >= 604800 && var.soft_delete_retention_seconds <= 7776000)
    error_message = "soft_delete_retention_seconds must be 0, or between 604800 (7 days) and 7776000 (90 days)."
  }
}

variable "retention_policy" {
  description = "WORM retention: objects cannot be deleted/overwritten for retention_period_seconds. is_locked = true is IRREVERSIBLE."
  type = object({
    retention_period_seconds = number
    is_locked                = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.retention_policy == null ? true : (var.retention_policy.retention_period_seconds > 0 && var.retention_policy.retention_period_seconds <= 3155760000)
    error_message = "retention_period_seconds must be between 1 and 3155760000 (100 years)."
  }
}

variable "access_log_bucket" {
  description = "Bucket name to receive access/storage logs. Null disables access logging."
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Object prefix for access logs."
  type        = string
  default     = null
}

variable "iam_members" {
  description = "Bucket IAM bindings keyed by a stable label: { role, member }. Public members are rejected — this bucket stays private."
  type = map(object({
    role   = string
    member = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for b in var.iam_members : !contains(["allUsers", "allAuthenticatedUsers"], b.member)
    ])
    error_message = "Public members (allUsers, allAuthenticatedUsers) are not allowed; public_access_prevention is enforced on this bucket."
  }

  validation {
    condition = alltrue([
      for b in var.iam_members : can(regex("^(roles/|projects/[^/]+/roles/|organizations/[^/]+/roles/)", b.role))
    ])
    error_message = "Each role must be a predefined (roles/...) or custom (projects|organizations/.../roles/...) role."
  }
}

variable "labels" {
  description = "Labels applied to the bucket."
  type        = map(string)
  default     = {}
}
