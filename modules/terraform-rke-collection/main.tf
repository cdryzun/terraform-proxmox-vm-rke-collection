resource "rke_cluster" "create_cluster" {
  cluster_yaml          = <<EOT
nodes:
%{for i, v in var.k8s_role.servers~}
  - address: "${v}"
    internal_address: "${v}"
    port: "${var.remote_ssh_port}"
    role:
      - controlplane
      - etcd
    hostname_override: "server${reverse(split(".", v))[0]}"
    user: "${var.rke_user}"
    docker_socket: "${var.docker_socket_path}"
%{endfor~}
%{for i, v in var.k8s_role.agents~}
  - address: "${v}"
    internal_address: "${v}"
    port: "${var.remote_ssh_port}"
    role:
      - worker
    hostname_override: "agent${reverse(split(".", v))[0]}"
    user: "${var.rke_user}"
    docker_socket: "${var.docker_socket_path}"
%{endfor~}
services:
  etcd:
    snapshot: true
    creation: 5m0s
    retention: 24h
    extra_args:
      auto-compaction-retention: 240
      quota-backend-bytes: '6442450944'
    extra_binds:
      - /etc/localtime:/etc/localtime
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: 30000-32767
    pod_security_policy: false
    extra_args:
      watch-cache: true
      default-watch-cache-size: 1500
      event-ttl: 1h0m0s
      max-requests-inflight: 800
      max-mutating-requests-inflight: 400
      kubelet-timeout: 5s
      audit-log-path: '-'
      delete-collection-workers: 3
      v: 4
  kube-controller:
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
    extra_args:
      node-cidr-mask-size: '22'
      node-monitor-period: 5s
      node-monitor-grace-period: 20s
      node-startup-grace-period: 30s
      pod-eviction-timeout: 1m
      concurrent-deployment-syncs: 5
      concurrent-endpoint-syncs: 5
      concurrent-gc-syncs: 20
      concurrent-namespace-syncs: 10
      concurrent-replicaset-syncs: 5
      concurrent-service-syncs: 1
      concurrent-serviceaccount-token-syncs: 5
      pvclaimbinder-sync-period: 15s
  scheduler:
    extra_args: {}
    extra_binds: []
    extra_env: []
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    generate_serving_certificate: true
    extra_args:
      allowed-unsafe-sysctls: kernel.msg*,net.core.somaxconn
      cluster-dns: 169.254.20.10
      pod-manifest-path: /etc/kubernetes/manifests/
      max-pods: "256"
      sync-frequency: 3s
      max-open-files: "2000000"
      kube-api-burst: "30"
      kube-api-qps: "15"
      serialize-image-pulls: "false"
      registry-burst: "10"
      registry-qps: "0"
      cgroups-per-qos: "true"
      enforce-node-allocatable: pods
      system-reserved: cpu=0.25,memory=100Mi
      kube-reserved: cpu=0.25,memory=300Mi
      eviction-hard: memory.available<300Mi,nodefs.available<10%,imagefs.available<15%,nodefs.inodesFree<5%
      node-status-update-frequency: 10s
      global-housekeeping-interval: 1m0s
      housekeeping-interval: 10s
      runtime-request-timeout: 2m0s
      volume-stats-agg-period: 1m0s
      volume-plugin-dir: /usr/libexec/kubernetes/kubelet-plugins/volume/exec
    extra_binds:
      - /usr/libexec/kubernetes/kubelet-plugins/volume/exec:/usr/libexec/kubernetes/kubelet-plugins/volume/exec
      - /etc/kubernetes/manifests/:/etc/kubernetes/manifests/
      - /etc/localtime:/etc/localtime
  kubeproxy:
    extra_args:
      proxy-mode: ipvs
      kube-api-burst: 20
      kube-api-qps: 10
    extra_binds: null
network:
  plugin: ${var.cni_plugin}
  options:
    canal_flannel_backend_type: ${var.cni_plugin_type}
authentication:
  strategy: x509|webhook
  webhook:
    cache_timeout: 5s
  sans:
    - kube-vip.treesir.pub
authorization:
  mode: rbac
%{if var.enable_private_registry}
private_registries:
  - url: "${var.private_registry}"
    user: "${var.private_registry_user}"
    password: "${var.private_registry_password}"
    is_default: true
%{endif}
ingress:
  provider: nginx
  options:
    map-hash-bucket-size: "1024"
    server-tokens: "false"
    worker-cpu-affinity: auto
    proxy-body-size: 100m
    proxy-connect-timeout: "1200"
    proxy-read-timeout: "1200"
    proxy-send-timeout: "1200"
cluster_name: ${var.cluster_name}
addon_job_timeout: 60
monitoring:
  provider: metrics-server
dns:
  provider: coredns
  nodelocal:
    ip_address: 169.254.20.10
EOT
  enable_cri_dockerd    = local.enable_cri_dockerd
  ignore_docker_version = local.ignore_docker_version
  kubernetes_version    = local.kubernetes_version
}

resource "local_file" "cluster_config_yaml" {
  filename = "${var.cluster_name}/cluster.yaml"
  content  = rke_cluster.create_cluster.cluster_yaml
  depends_on = [
    rke_cluster.create_cluster
  ]
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${var.cluster_name}/kube_config.yaml"
  content  = rke_cluster.create_cluster.kube_config_yaml
  depends_on = [
    rke_cluster.create_cluster
  ]
}

locals {
  kubernetes_version    = var.kubernetes_version
  enable_cri_dockerd    = true
  ignore_docker_version = true
}
