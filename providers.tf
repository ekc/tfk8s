terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  required_version = "~> 1.0"
}
