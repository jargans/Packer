packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Variables
variable "region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "source_ami" {
  type    = string
  default = "ami-0ea3c35c5c3284d82"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# Sources (Builders)
source "amazon-ebs" "demo" {
  region         = var.region
  source_ami     = var.source_ami
  instance_type  = var.instance_type
  ssh_username   = "ubuntu"
  ami_name       = "packer-demo-ami-${local.timestamp}"
}

# Builds
build {
  sources = [
    "source.amazon-ebs.demo",
  ]

  # Provisioners
  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo apt-get install docker.io -y"
    ]
  }

  # Post-processors
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      "timestamp" = local.timestamp
      "region"    = var.region
    }
  }
}
