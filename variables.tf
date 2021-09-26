variable "settings" {
  type = object({ region=string, image=string, master_size=string, worker_size=string, number_of_workers=number, ssh_keys=list(number)})
  default = {
    region = "sfo3"
    image = "centos-8-x64"
    master_size = "s-1vcpu-2gb"
    worker_size = "s-1vcpu-2gb"
    number_of_workers = 2
    # list of ssh-key from command doctl compute ssh-key list
    ssh_keys=[]
  }
}
