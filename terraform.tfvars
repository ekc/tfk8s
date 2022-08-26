# sample settings to override defaults in variables.tf
settings = {
  region = "sfo3"
  image = "rockylinux-8-x64"
  master_size = "s-2vcpu-2gb"
  worker_size = "s-2vcpu-2gb"
  number_of_workers = 2
  ssh_keys = [26798816]
  pod_network_cidr = "10.16.0.0/12"
  network_addon = "weave"
}
