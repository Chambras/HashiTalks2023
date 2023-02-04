variable "imageSuffix" {
  type = string
  default = "hashitalks"
}

variable "ssh_username" {
  type = string
  default = "ubuntu"
}

variable "cloudConfig" {
  type = map(map(string))
  default = {
    azure = {
      os_type = "Linux"
      image_offer = "0001-com-ubuntu-server-jammy"
      image_publisher = "Canonical"
      image_sku = "22_04-lts"
      managed_image_resource_group_name = "HashiTalks2023"
      azure_region = "eastus"
      vm_size = "Standard_B1ls"
    }
    aws = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      owners              = "099720109477"
      region              = "us-east-1"
      instance_type       = "t2.micro"
    }
    gcp = {
      source_image = "ubuntu-2204-jammy-v20230114"
      zone = "us-east1-b"
      machine_type = "e2-micro"
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    "environment" = "dev"
    "project"     = "hashitalks"
    "billingcode" = "internal"
    "owner"       = "marcelo"
    "team"        = "cloud-automation"
  }
  description = "tags to be applied to the resource."
}

#Azure
variable "arm_client_id" {
  type = string
  default = env("ARM_CLIENT_ID")
}

variable "arm_client_secret" {
  type = string
  default = env("ARM_CLIENT_SECRET")
}

variable "arm_subscription_id" {
  type = string
  default = env("ARM_SUBSCRIPTION_ID")
}

variable "azure_resource_group" {
  type = string
  default = "HashiTalks2023"
}

#AWS

#GCP
variable "project_id" {
  type = string
  default = "presentations-375803"
}
