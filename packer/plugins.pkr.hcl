packer {
  required_plugins {
    docker = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/docker"
    }
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

