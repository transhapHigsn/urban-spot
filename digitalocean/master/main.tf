resource "digitalocean_project" "urban-spot" {
  name        = "urban-spot"
  description = "A project to test urban spot."
  purpose     = "k3s ha setup"
  environment = "development"
}

# resource "digitalocean_ssh_key" "urban-spot" {
#   name       = "Urban Spot SSH"
#   public_key = file(var.ssh_public_key_path)
# }

data "digitalocean_ssh_key" "urban-spot" {
  name = "saitama"
}

resource "digitalocean_vpc" "urban-spot-vpc" {
  name     = "urban-spot"
  region   = "blr1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "master-1"
  region = "blr1"
  size   = "s-2vcpu-2gb"
  vpc_uuid = digitalocean_vpc.urban-spot-vpc.id
  ssh_keys = [data.digitalocean_ssh_key.urban-spot.id]
  tags = ["grandmaster", "k3s"]
}
