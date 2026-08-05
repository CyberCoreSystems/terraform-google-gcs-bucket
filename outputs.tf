output "bucket_name" {
  description = "The bucket name."
  value       = google_storage_bucket.this.name
}

output "bucket_self_link" {
  description = "Self link of the bucket."
  value       = google_storage_bucket.this.self_link
}

output "bucket_url" {
  description = "gs:// URL of the bucket."
  value       = google_storage_bucket.this.url
}

output "bucket_location" {
  description = "Resolved bucket location."
  value       = google_storage_bucket.this.location
}
