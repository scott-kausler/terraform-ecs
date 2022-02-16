data "aws_iam_account_alias" "current" {}

resource "aws_s3_bucket" "tf_state" {
  bucket = "${data.aws_iam_account_alias.current.account_alias}-tf-state"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "tf_state" {
  value = aws_s3_bucket.tf_state.id
}