# sample settings to override defaults in variables.tf
settings = {
  region = "sfo3"
  image = "centos-8-x64"
  master_size = "s-2vcpu-2gb"
  worker_size = "s-2vcpu-2gb"
  number_of_workers = 1
  ssh_keys = [26798816]
}
