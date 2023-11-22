variable "cluster" {
  type = map(object({
    server_group = map(object({
      vm_servers_list         = list(string)
      vm_servers_memory       = string
      vm_servers_cores        = string
      vm_servers_disk_size    = string
      vm_servers_disk_storage = string
      vm_servers_target_node  = string
    }))
    agent_group = map(object({
      vm_agents_list         = list(string)
      vm_agents_memory       = string
      vm_agents_cores        = string
      vm_agents_disk_size    = string
      vm_agents_disk_storage = string
      vm_agents_target_node  = string
    }))
    rke_enable_private_registry = bool
    private_registry            = string
    vm_ssh_port                 = string
    vm_ssh_user                 = string
    vm_ssh_private_key          = string
    vm_ip_gw                    = string
    vm_ip_subnet                = string
    vm_pool                     = string
    vm_clone_target             = string
    cluster_kubernetes_version  = string
    cluster_onboot              = bool
  }))
  default = {
  }

  // "Only one cluster is supported
  validation {
    condition     = length(keys(var.cluster)) == 1
    error_message = "Only one cluster is supported"
  }
}


variable "rke_user" {
  type    = string
  default = "rke"
}


variable "rke_user_passwd" {
  type      = string
  default   = "rke"
  sensitive = true
}
