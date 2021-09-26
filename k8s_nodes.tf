provider "digitalocean" {
}

resource "digitalocean_droplet" "masters" {
  region = var.settings["region"]
  image = var.settings["image"]
  name = "master"
  size   = var.settings["master_size"]
  ssh_keys = var.settings["ssh_keys"]
  tags = ["k8s", "master"]
}

resource "digitalocean_droplet" "workers" {
  region = var.settings["region"]
  image = var.settings["image"]
  name   = "${format("worker%02d", count.index + 1)}"
  size   = var.settings["worker_size"]
  ssh_keys = var.settings["ssh_keys"]
  tags = ["k8s", "worker"]
  count = var.settings["number_of_workers"]
}

resource "null_resource" "masters" {
  triggers = {
    masters_ids = join(",", digitalocean_droplet.masters.*.id)
  }

  provisioner "local-exec" {
    command = "echo \"$content\" > ${path.module}/inventory/masters"
    environment = {
      content = templatefile("${path.module}/templates/masters.tmpl",{
        hostipmap = {
          for key in digitalocean_droplet.masters.*: key.name => key.ipv4_address
        }
      })
    }
  }

  provisioner "local-exec" {
    command = "echo \"$content\" > ${path.module}/playbooks/vars/kubeadm_settings"
    environment = {
      content = templatefile("${path.module}/templates/kubeadm.tmpl",{
        ad_addr = digitalocean_droplet.masters.ipv4_address_private
      })
    }
  }
}

resource "null_resource" "workers" {
  triggers = {
    worker_ids = join(",", digitalocean_droplet.workers.*.id)
  }

  provisioner "local-exec" {
    command = "echo \"$content\" > ${path.module}/inventory/workers"
    environment = {
      content = templatefile("${path.module}/templates/workers.tmpl",{
        hostipmap = {
          for key in digitalocean_droplet.workers.*: key.name => key.ipv4_address
        }
      })
    }
  }
}

resource "null_resource" "clusters" {
  depends_on = [
    null_resource.masters,
    null_resource.workers
  ]

  provisioner "local-exec" {
    // disable host_key_checking while testing availability of SSH service on remote host
    // and add host key to .known_hosts
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible all -m wait_for_connection -a \"sleep=5 timeout=300\";ssh-keyscan -T 30 $hostlist >> ~/.ssh/known_hosts"
    environment = {
      hostlist = join(" ", concat(digitalocean_droplet.masters.*.ipv4_address, digitalocean_droplet.workers.*.ipv4_address))
    }
  }

  provisioner "local-exec" {
    command = "sleep 5;ansible-playbook setup.yml"
  }

  provisioner "local-exec" {
    when = destroy
    command = "ansible-playbook destroy.yml"
    on_failure = continue
  }
}


output "master_ip_address" {
  value = digitalocean_droplet.masters.*.ipv4_address
}

output "worker_ip_addresses" {
  value = digitalocean_droplet.workers.*.ipv4_address
}
