# Remote state: the tfstate file tracks every resource Terraform manages,
# including things that look sensitive (subnet IDs, security group rules).
# It must never be a local file that only exists on one laptop — an S3
# backend with native locking (the `use_lock_file` flag) means a teammate
# running `terraform apply` from a different machine sees the same state,
# and two applies can't race each other and corrupt it.
#
# Deliberately commented out: initializing this backend requires a real,
# already-created S3 bucket. `terraform init -backend=false` is how this
# project validates without one. Uncomment and fill in the bucket to use a
# real backend.
#
# terraform {
#   backend "s3" {
#     bucket       = "REPLACE-ME-job-board-tfstate"
#     key          = "kubernetes-iac-deployment/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true  # GA since Terraform 1.11 — replaces the old DynamoDB-table lock
#   }
# }
