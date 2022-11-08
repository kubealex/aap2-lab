
terraform {
 required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
      configuration_aliases = [ libvirt ]
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

module "libvirt_resources" {
  source = "./modules/00_libvirt_resources"

# Variables
  domain = var.domain
  network_cidr = var.network_cidr
  libvirt_pool_path = var.libvirt_pool_path
  libvirt_network = var.libvirt_network
  libvirt_pool = var.libvirt_pool
}

module "conroller_instance" {
  source = "./modules/01_controller_instance"
  depends_on = [module.libvirt_resources]
  count = tobool(lower(var.controller_setup)) ? 1 : 0

# Variables
  domain = var.domain
  libvirt_network = var.libvirt_network
  libvirt_pool = var.libvirt_pool
  disk_size = var.disk_size
}

module "hub_instance" {
  source = "./modules/02_hub_instance"
  depends_on = [module.libvirt_resources]
  count = tobool(lower(var.hub_setup)) ? 1 : 0

# Variables
  domain = var.domain
  libvirt_network = var.libvirt_network
  libvirt_pool = var.libvirt_pool
  disk_size = var.disk_size
}

module "servicecatalog_instance" {
  source = "./modules/03_sc_instance"
  depends_on = [module.libvirt_resources]
  count = tobool(lower(var.servicecatalog_setup)) ? 1 : 0

# Variables
  domain = var.domain
  libvirt_network = var.libvirt_network
  libvirt_pool = var.libvirt_pool
  disk_size = var.disk_size
}
module "sso_instance" {
  source = "./modules/04_sso_instance"
  depends_on = [module.libvirt_resources]
  count = tobool(lower(var.servicecatalog_setup)) ? 1 : 0

# Variables
  domain = var.domain
  libvirt_network = var.libvirt_network
  libvirt_pool = var.libvirt_pool
  disk_size = var.disk_size
}


