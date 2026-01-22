# S3 bucket for Loki log storage
resource "aws_s3_bucket" "loki" {
  bucket = "${var.project_name}-loki-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "${var.project_name}-loki"
    Environment = var.environment
    Purpose     = "Loki log storage"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "loki" {
  bucket = aws_s3_bucket.loki.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for data protection (optional, can disable for cost savings)
resource "aws_s3_bucket_versioning" "loki" {
  bucket = aws_s3_bucket.loki.id
  versioning_configuration {
    status = "Disabled" # Enable if you need versioning
  }
}

# Lifecycle rule to manage storage costs
resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    # Move to cheaper storage after 7 days
    transition {
      days          = 7
      storage_class = "STANDARD_IA"
    }

    # Delete logs after 7 days (adjust based on retention needs)
    expiration {
      days = 7
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
