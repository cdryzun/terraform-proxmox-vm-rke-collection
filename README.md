
# Usage

```bash
module "example-demo" {
  source = "git::https://github.com/cdryzun/terraform-proxmox-vm-rke-collection.git//?ref=main"
  cluster = {
    example-demo = {
      server_group = {
        server1 = {
          vm_servers_list         = ["192.168.8.140"]
          vm_servers_memory       = "4096"
          vm_servers_cores        = "2"
          vm_servers_disk_size    = "40G"
          vm_servers_disk_storage = "sd"
          vm_servers_target_node  = "amd"
        }
      }
      agent_group = {
        agent1 = {
          vm_agents_list         = ["192.168.8.141"]
          vm_agents_memory       = "8192"
          vm_agents_cores        = "4"
          vm_agents_disk_size    = "100G"
          vm_agents_disk_storage = "sd"
          vm_agents_target_node  = "amd"
        }
      }
      rke_enable_private_registry = false
      private_registry            = ""
      vm_ssh_port                 = "22"
      vm_ssh_user                 = "root"
      vm_ssh_private_key          = "${path.root}/id_rsa"
      vm_ip_gw                    = "192.168.8.1"
      vm_pool                     = "devops"
      vm_clone_target             = "centos7"
      vm_ip_subnet                = "24"
      cluster_kubernetes_version  = "v1.26.4-rancher2-1"
      cluster_onboot              = "false"
    }
  }
  rke_user        = var.rke_user
  rke_user_passwd = var.rke_user_passwd
}
```
Then perform the following commands on the root folder:

- generate SSH public and private keys.

  ```bash
  ssh-keygen -b 2048 -t rsa -f ./id_rsa -q -N ""
  ```

- terraform init to get the plugins
- terraform plan to see the infrastructure plan
- terraform apply to apply the infrastructure build
- terraform destroy to destroy the built infrastructure

# Inputs

## Provider `proxmox` request

```bash
export PM_API_URL=https://xx:8006/api2/json
export PM_USER=root@pam
export PM_PASS='xxx'
```

---

| Name                        | Description                                              | Type          | Default            | Required |
| --------------------------- | -------------------------------------------------------- | ------------- | ------------------ | -------- |
| example-demo                | cluster = { example-demo = {} } `cluster-name`           | `string`      |                    | yes      |
| vm_servers_list             | master host list ip                                      | `string list` |                    | yes      |
| vm_servers_memory           | master host memory size                                  | `string`      |                    | yes      |
| vm_servers_disk_size        | master host disk size                                    | `string`      |                    | yes      |
| vm_servers_disk_storage     | master host use storage  pool                            | `string`      |                    | yes      |
| vm_servers_target_node      | master host running node                                 | `string`      |                    | yes      |
| vm_servers_cores            | master host vcpu size                                    | `string`      |                    | yes      |
| vm_agents_list              | worker host list ip                                      | `string list` |                    | yes      |
| vm_agents_memory            | worker host memory size                                  | `string`      |                    | yes      |
| vm_agents_cores             | worker host vcpu size                                    | `string`      |                    | yes      |
| vm_agents_disk_size         | worker host disk size                                    | `string`      |                    | yes      |
| vm_agents_disk_storage      | worker host use storage  pool                            | `string`      |                    | yes      |
| vm_agents_target_node       | worker host running node                                 | `string`      |                    | yes      |
| rke_enable_private_registry | whether to use a private image address to pull the image | `bool`        | false              | yes      |
| private_registry            | private image address                                    | `string`      |                    | no       |
| vm_ssh_port                 | the port used when managing user connections.            | `string`      | 22                 | yes      |
| vm_ssh_user                 | manage the user used when connecting.                    | `string`      |                    | yes      |
| vm_ssh_private_key          | manage user keys used for connection.                    | `string`      |                    |          |
| vm_ip_gw                    | vm default gateway                                       | `string`      | 192.168.8.1        | yes      |
| vm_pool                     | PVE virtualization platform vm pool                      | `string`      | devops             | yes      |
| vm_clone_target             | virtual machine template used                            | `string`      | centos7            | yes      |
| vm_ip_subnet                | vm default subnet                                        | `string`      | 24                 | yes      |
| cluster_kubernetes_version  | rke create k8s cluster version                           | `string`      | v1.21.2-rancher1-1 | yes      |
| cluster_onboot              | whether the cluster is bootstrapped or not               | `string`      |                    | yes      |
| rke_user                    | new rke template user                                    | `string`      | rke                |          |
| rke_user_passwd             | new rke template user password                           | `string`      |                    | yes      |



# Output

| Name                               | Description                           |
| ---------------------------------- | ------------------------------------- |
| ./${cluster-name}/cluster.yaml     | rke cluster template                  |
| ./${cluster-name}/kube_config.yaml | kubectl connecting to kubernetes file |