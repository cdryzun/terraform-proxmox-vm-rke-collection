
variable "rke_user" {
  type        = string
  description = "RKE use this name connection to remote host"
}

variable "remote_ssh_port" {
  type        = number
  description = "Remote Host SSH Port"
  default     = 22
}

variable "k8s_role" {
  type = object({
    servers = list(string)
    agents  = list(string)
  })
  description = "Kubernetes Roles"
}

variable "docker_socket_path" {
  type        = string
  description = "Docker deamon socket path"
  default     = "/var/run/docker.sock"
}

# https://github.com/rancher/rke/releases/tag/v1.4.2
variable "k8s_version" {
  type        = string
  description = "Rancher Kubernetes Version"
  default     = "v1.24.9-rancher1-1"
}

variable "kubeproxy_mode" {
  type        = string
  description = "Kubernetes Network Proxy Mode"
  default     = "ipvs"
}

variable "cni_plugin" {
  type        = string
  description = "Kubernetes CNI Network Plugin"
  default     = "canal"
}

variable "cni_plugin_type" {
  type        = string
  description = "Kubernetes CNI Network Plugin Backend Type"
  default     = "host-gw"
}

variable "ingress_provider" {
  type        = string
  description = "Kubernetes Ingress Controller"
  default     = "nginx"
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes Cluster Name"
}

variable "enable_private_registry" {
  type        = bool
  description = "Use Private Registry to Pull Images"
  default     = false
}

variable "private_registry" {
  type        = string
  description = "Private Registry"
  default     = "nexus.treesir.pub"
}

variable "private_registry_user" {
  type        = string
  description = "Private Registry User"
  default     = ""
  sensitive   = true
}

variable "private_registry_password" {
  type        = string
  description = "Private Registry Password"
  default     = ""
  sensitive   = true
}

variable "cert_sans" {
  type        = list(string)
  description = "Kubernetes Certificate Sans"
}


variable "kubernetes_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "v1.24.9-rancher1-1"
}
