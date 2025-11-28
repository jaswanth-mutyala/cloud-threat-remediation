# This generates a random suffix so your bucket name is unique globally
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. The "Honeypot" Bucket (The Bait)
resource "aws_s3_bucket" "honeypot_bucket" {
  bucket        = "confidential-finance-data-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allows deleting bucket even if it has files
  
  tags = {
    Name = "Honeypot-Bucket"
    Type = "Decoy"
  }
}

# 2. The Log Bucket (The Storage)
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "security-logs-archive-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# Block public access to the Log bucket (Best Practice)
resource "aws_s3_bucket_public_access_block" "log_bucket_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}