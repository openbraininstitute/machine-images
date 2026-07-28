variable "neurodamus_script_commit" {
  type        = string
  description = "commit of neurodamus repository where ci/scripts is pulled from"
}

variable "libsonatareport_commit" {
  type        = string
  description = "libsonatareport commit"
}

variable "libsonata_commit" {
  type        = string
  description = "libsonata commit"
}

variable "python_version" {
  type        = string
  description = "Python version to install"
}

variable "uv_version" {
  type        = string
  description = "uv package manager version"
}

variable "neuron_commit" {
  type        = string
  description = "NEURON git commit or tag to build"
}

variable "neurodamus_commit" {
  type        = string
  description = "Neurodamus git commit or tag to build"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_vpc_id" {
  type    = string
  default = "vpc-0f0a57d191d06588b" # SBO_poc
}
variable "aws_subnet_id" {
  type    = string
  default = "subnet-064de2163c1b2ae2d" # public_a
}

variable "aws_instance_type" {
  type    = string
}

variable "az_region" {
  type    = string
}

variable "az_instance_type" {
  type    = string
}

variable "az_resource_group" {
  type    = string
}
