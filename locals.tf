locals {
  # All server group grouping information.
  server_group_info = flatten([
    for cluster_name, server_group in var.cluster : [
      for cluster_server_group, server_info in server_group.server_group : {
        cluster_name         = cluster_name
        cluster_server_group = cluster_server_group
        server_info          = server_info
      }
    ]
  ])

  # All server group vm_servers_list grouping information.
  server_group_list_info = flatten([
    for server_info in local.server_group_info : [
      for vm_server_ip in server_info.server_info.vm_servers_list : {
        cluster_name         = server_info.cluster_name
        cluster_server_group = server_info.cluster_server_group
        server_info = {
          vm_servers_cores        = server_info.server_info.vm_servers_cores
          vm_servers_disk_size    = server_info.server_info.vm_servers_disk_size
          vm_servers_disk_storage = server_info.server_info.vm_servers_disk_storage
          vm_servers_list         = [vm_server_ip]
          vm_servers_memory       = server_info.server_info.vm_servers_memory
          vm_servers_target_node  = server_info.server_info.vm_servers_target_node
        }
      }
    ]
  ])

  # All agent group grouping information.
  agent_group_info = flatten([
    for cluster_name, agent_group in var.cluster : [
      for cluster_agent_group, agent_info in agent_group.agent_group : {
        cluster_name        = cluster_name
        cluster_agent_group = cluster_agent_group
        agent_info          = agent_info
      }
    ]
  ])

  # All agent group vm_agents_list grouping information.
  agent_group_list_info = flatten([
    for agent_info in local.agent_group_info : [
      for vm_agent_ip in agent_info.agent_info.vm_agents_list : {
        cluster_name        = agent_info.cluster_name
        cluster_agent_group = agent_info.cluster_agent_group
        agent_info = {
          vm_agents_cores        = agent_info.agent_info.vm_agents_cores
          vm_agents_disk_size    = agent_info.agent_info.vm_agents_disk_size
          vm_agents_disk_storage = agent_info.agent_info.vm_agents_disk_storage
          vm_agents_list         = [vm_agent_ip]
          vm_agents_memory       = agent_info.agent_info.vm_agents_memory
          vm_agents_target_node  = agent_info.agent_info.vm_agents_target_node
        }
      }
    ]
  ])

  agent_group_ip_list_info = { for agent in local.agent_group_list_info : agent.agent_info.vm_agents_list[0] => {
    cluster_name        = agent.cluster_name
    cluster_agent_group = agent.cluster_agent_group
    agent_info = {
      vm_agent_cores        = agent.agent_info.vm_agents_cores
      vm_agent_disk_size    = agent.agent_info.vm_agents_disk_size
      vm_agent_disk_storage = agent.agent_info.vm_agents_disk_storage
      vm_agent_memory       = agent.agent_info.vm_agents_memory
      vm_agent_target_node  = agent.agent_info.vm_agents_target_node
    }
  } }

  server_group_ip_list_info = { for server in local.server_group_list_info : server.server_info.vm_servers_list[0] => {
    cluster_name         = server.cluster_name
    cluster_server_group = server.cluster_server_group
    server_info = {
      vm_server_cores        = server.server_info.vm_servers_cores
      vm_server_disk_size    = server.server_info.vm_servers_disk_size
      vm_server_disk_storage = server.server_info.vm_servers_disk_storage
      vm_server_memory       = server.server_info.vm_servers_memory
      vm_server_target_node  = server.server_info.vm_servers_target_node
    }
  } }

  cluster_info = {
    for cluster_name, cluster_config in var.cluster :
    cluster_name => {
      cluster_kubernetes_version  = cluster_config.cluster_kubernetes_version != "" ? cluster_config.cluster_kubernetes_version : "v1.21.2-rancher1-1"
      cluster_onboot              = cluster_config.cluster_onboot
      private_registry            = cluster_config.private_registry != "" ? cluster_config.private_registry : "docker.io"
      rke_enable_private_registry = cluster_config.rke_enable_private_registry
      vm_clone_target             = cluster_config.vm_clone_target != "" ? cluster_config.vm_clone_target : "centos7"
      vm_ip_gw                    = cluster_config.vm_ip_gw != "" ? cluster_config.vm_ip_gw : "192.168.8.1"
      vm_ip_subnet                = cluster_config.vm_ip_subnet != "" ? cluster_config.vm_ip_subnet : "24"
      vm_pool                     = cluster_config.vm_pool != "" ? cluster_config.vm_pool : "devops"
      vm_ssh_port                 = cluster_config.vm_ssh_port != "" ? cluster_config.vm_ssh_port : "22"
      vm_ssh_private_key          = cluster_config.vm_ssh_private_key != "" ? cluster_config.vm_ssh_private_key : "~/.ssh/id_rsa"
      vm_ssh_user                 = cluster_config.vm_ssh_user != "" ? cluster_config.vm_ssh_user : "rke"
      cluster_name                = cluster_name
    }
  }

  server_list = keys(local.server_group_ip_list_info)
  agent_list  = keys(local.agent_group_ip_list_info)
}
