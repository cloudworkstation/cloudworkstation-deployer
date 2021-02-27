resource "aws_dynamodb_table" "auth_table" {
  name            = var.table_name
  billing_mode    = "PAY_PER_REQUEST"
  hash_key        = var.hash_key
  range_key       = var.sort_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  attribute {
    name = var.sort_key
    type = var.sort_key_type
  }

  point_in_time_recovery {
    enabled = true
  }
}