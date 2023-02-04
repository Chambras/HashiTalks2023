packer {
  required_version = ">= 1.8.5"
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 1.3.1"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.1.6"
    }
    googlecompute = {
      source = "github.com/hashicorp/googlecompute"
      version = ">= 1.1.0"
    }
  }
}

locals {
  date = formatdate("HHmm", timestamp())
}

source "azure-arm" "ubuntu-lts" {
  client_id                         = var.arm_client_id
  client_secret                     = var.arm_client_secret
  subscription_id                   = var.arm_subscription_id

  os_type         = var.cloudConfig["azure"].os_type
  image_offer     = var.cloudConfig["azure"].image_offer
  image_publisher = var.cloudConfig["azure"].image_publisher
  image_sku       = var.cloudConfig["azure"].image_sku

  managed_image_resource_group_name = var.cloudConfig["azure"].managed_image_resource_group_name

  vm_size        = var.cloudConfig["azure"].vm_size
  ssh_username   = var.ssh_username
  ssh_agent_auth = false

  azure_tags = var.tags
}

source "amazon-ebs" "ubuntu-lts" {
  source_ami_filter {
    filters = {
      virtualization-type = var.cloudConfig["aws"].virtualization-type
      name                = var.cloudConfig["aws"].name
      root-device-type    = "ebs"
    }
    owners      = [var.cloudConfig["aws"].owners]
    most_recent = true
  }
  region = var.cloudConfig["aws"].region

  ami_name       = "${var.imageSuffix}-${local.date}"
  ami_regions    = [var.cloudConfig["aws"].region]
  instance_type  = var.cloudConfig["aws"].instance_type
  ssh_username   = var.ssh_username
  ssh_agent_auth = false

  tags = var.tags
}

source "googlecompute" "ubuntu-lts" {
  project_id = var.project_id

  source_image = var.cloudConfig["gcp"].source_image
  ssh_username = var.ssh_username
  zone = var.cloudConfig["gcp"].zone
  machine_type = var.cloudConfig["gcp"].machine_type
  image_name = "${var.imageSuffix}-${local.date}"

  image_labels = var.tags
}

build {
  source "source.azure-arm.ubuntu-lts" {
    name               = "hashitalks"
    location           = var.cloudConfig["azure"].azure_region
    managed_image_name = "${var.imageSuffix}-${local.date}"
  }

  source "source.amazon-ebs.ubuntu-lts" {
    name = "hashitalks"
  }

  sources = ["sources.googlecompute.ubuntu-lts"]

  # systemd unit for HashiCups service
  /*provisioner "file" {
    source      = "hashicups.service"
    destination = "/tmp/hashicups.service"
  }

  # Set up HashiCups
  provisioner "shell" {
    scripts = [
      "setup-deps-hashicups.sh"
    ]
  }*/

  # HCP Packer settings
  hcp_packer_registry {
    bucket_name = "multicloud-hashitalks"
    description = "This is an image for HashiTalks 2023."

    bucket_labels = {
      "Project" = "multicloud-hashitalks",
      "Owner" = "Marcelo",
    }
  }

  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }
}
