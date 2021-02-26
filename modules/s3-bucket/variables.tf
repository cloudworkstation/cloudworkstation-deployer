variable "encrypt_bucket" {
  type = bool
  description = "Should we encrypt the bucket contents, defaults to true"
  default = true
}

variable "bucket_prefix" {
  type = string
  description = "Name to prefix the bucket with"
}