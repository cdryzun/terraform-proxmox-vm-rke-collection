module "rke-server" {
  source   = "git::https://github.com/cdryzun/terraform-proxmox-vm-collection.git//?ref=main"
  for_each = toset(sort(local.server_list))
  groups = {
    "${local.server_group_ip_list_info[each.value].cluster_name}-${local.server_group_ip_list_info[each.value].cluster_server_group}-${reverse(split(".", each.key))[0]}" = {
      desc              = "rke ${local.server_group_ip_list_info[each.value].cluster_name} server ${local.server_group_ip_list_info[each.value].cluster_server_group}"
      target_node       = local.server_group_ip_list_info[each.value].server_info.vm_server_target_node
      onboot            = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].cluster_onboot
      target_clone_name = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].vm_clone_target
      pool              = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].vm_pool
      cores             = local.server_group_ip_list_info[each.value].server_info.vm_server_cores
      memory            = local.server_group_ip_list_info[each.value].server_info.vm_server_memory
      ip                = each.key
      disk_size         = local.server_group_ip_list_info[each.value].server_info.vm_server_disk_size
      storage           = local.server_group_ip_list_info[each.value].server_info.vm_server_disk_storage
      ip_subnet         = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].vm_ip_subnet
      dns               = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].vm_ip_gw
      ip_gw             = local.cluster_info[local.server_group_ip_list_info[each.value].cluster_name].vm_ip_gw
    }
  }
}

resource "null_resource" "prepare_server" {
  for_each = {
    for idx, server_info in local.server_group_list_info : idx => server_info
  }
  connection {
    type        = "ssh"
    user        = local.cluster_info[each.value.cluster_name].vm_ssh_user
    private_key = file(local.cluster_info[each.value.cluster_name].vm_ssh_private_key)
    host        = each.value.server_info.vm_servers_list[0]
    port        = local.cluster_info[each.value.cluster_name].vm_ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "useradd ${var.rke_user} -G docker",
      "echo ${var.rke_user_passwd}|passwd ${var.rke_user} --stdin"
    ]
  }

  provisioner "local-exec" {
    command = "sshpass -p ${var.rke_user_passwd} ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.rke_user}@${each.value.server_info.vm_servers_list[0]}"
  }

  depends_on = [
    module.rke-server
  ]
}


module "rke-agent" {
  source   = "git::https://github.com/cdryzun/terraform-proxmox-vm-collection.git//?ref=main"
  for_each = toset(sort(local.agent_list))
  groups = {
    "${local.agent_group_ip_list_info[each.value].cluster_name}-${local.agent_group_ip_list_info[each.value].cluster_agent_group}-${reverse(split(".", each.key))[0]}" = {
      desc              = "rke ${local.agent_group_ip_list_info[each.value].cluster_name} agent ${local.agent_group_ip_list_info[each.value].cluster_agent_group}"
      target_node       = local.agent_group_ip_list_info[each.value].agent_info.vm_agent_target_node
      onboot            = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].cluster_onboot
      target_clone_name = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].vm_clone_target
      pool              = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].vm_pool
      cores             = local.agent_group_ip_list_info[each.value].agent_info.vm_agent_cores
      memory            = local.agent_group_ip_list_info[each.value].agent_info.vm_agent_memory
      ip                = each.key
      disk_size         = local.agent_group_ip_list_info[each.value].agent_info.vm_agent_disk_size
      storage           = local.agent_group_ip_list_info[each.value].agent_info.vm_agent_disk_storage
      ip_subnet         = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].vm_ip_subnet
      dns               = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].vm_ip_gw
      ip_gw             = local.cluster_info[local.agent_group_ip_list_info[each.value].cluster_name].vm_ip_gw
    }
  }
}

resource "null_resource" "prepare_agent" {
  for_each = {
    for idx, agent_info in local.agent_group_list_info : idx => agent_info
  }

  connection {
    type        = "ssh"
    user        = local.cluster_info[each.value.cluster_name].vm_ssh_user
    private_key = file(local.cluster_info[each.value.cluster_name].vm_ssh_private_key)
    host        = each.value.agent_info.vm_agents_list[0]
    port        = local.cluster_info[each.value.cluster_name].vm_ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "useradd ${var.rke_user} -G docker",
      "echo ${var.rke_user_passwd}|passwd ${var.rke_user} --stdin"
    ]
  }

  provisioner "local-exec" {
    command = "sshpass -p ${var.rke_user_passwd} ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.rke_user}@${each.value.agent_info.vm_agents_list[0]}"
  }

  depends_on = [
    module.rke-agent
  ]
}

module "rancher_rke" {
  source   = "./modules/terraform-rke-collection"
  for_each = local.cluster_info

  rke_user                = var.rke_user
  cluster_name            = each.value.cluster_name
  kubernetes_version      = each.value.cluster_kubernetes_version
  enable_private_registry = each.value.rke_enable_private_registry
  private_registry        = each.value.private_registry
  cert_sans               = local.server_list
  remote_ssh_port         = each.value.vm_ssh_port
  k8s_role = {
    servers = local.server_list
    agents  = local.agent_list
  }
  depends_on = [
    null_resource.prepare_server,
    null_resource.prepare_agent,
  ]
}
