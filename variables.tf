variable "project_name" {
  type        = string
  description = "The name of the project to instanciate the instance at."
  default     = "mts-gcp-dev-environment"
}

variable "region_name" {
  type        = string
  description = "The region that this terraform configuration will instanciate at."
  default     = "us-central1"
}

variable "zone_name" {
  type        = string
  description = "The zone that this terraform configuration will instanciate at."
  default     = "us-central1-c"
}

variable "machine_size" {
  type        = string
  description = "The size that this instance will be."
  default     = "e2-medium"
}

variable "image_name" {
  type        = string
  description = "The kind of VM this instance will become"
  default     = "centos-7"
}

variable "script_path" {
  type        = string
  description = "Where is the path to the script locally on the machine?"
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key used to connect to the instance"
}

variable "public_key_path" {
  type        = string
  description = "The path to the public key used to connect to the instance"
}

variable "username" {
  type        = string
  description = "The name of the user that will be used to remote exec the script"
}