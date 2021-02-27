variable "table_name" {
  description = "Name of the table to create"
  type = string
}

variable "hash_key" {
  type = string
  description = "The name of the hash (parition) key to use for the table"
}

variable "sort_key" {
  type = string
  description = "The name of the sort key to use for the table"
}

variable "hash_key_type" {
  type = string
  description = "The type of the hash (partition) key, defaults to 'S'"
  default = "S"
}

variable "sort_key_type" {
  type = string
  description = "The type of the sort key, defaults to 'S'"
  default = "S"
}
