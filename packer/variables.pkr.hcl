variable "neurodamus_script_commit" {
  type        = string
  description = "commit of neuordamus repository where ci/scripts is pulled from"
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

variable "aws_instance_type" {
  type    = string
  default = "c5.xlarge"
}

variable "az_region" {
  type    = string
  default = "East US" # XXX better default
}

variable "az_instance_type" {
  type    = string
  default = "Standard_E4s_v3" # XXX better default
}

variable "az_resource_group" {
  type    = string
  default = "obimgeastus" # XXX better default
}
