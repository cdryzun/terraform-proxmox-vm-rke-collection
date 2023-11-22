terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.4.2"
    }
  }
  required_version = ">= 0.14"
}
