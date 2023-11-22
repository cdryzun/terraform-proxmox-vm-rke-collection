output "cluster_nodes" {
  value = var.k8s_role
}

output "cluster_config_path" {
  value = local_file.cluster_config_yaml.filename
}

output "kube_config_path" {
  value = local_file.kube_cluster_yaml.filename
}
