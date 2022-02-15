resource "google_compute_subnetwork" "private-subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc_network.id
}
resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.private-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}
########################################################
resource "google_compute_router_nat" "nat" {
  name                               = "my-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.private-subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

}
#########################################################
resource "google_compute_instance" "private_vm" {
  name         = "private"
  machine_type = "e2-micro"
  zone         = "europe-west2-b"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.private-subnet.id

  }
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = <<SCRIPT
  sudo adduser --disabled-password --gecos "" ansible;
  usermod -aG sudo ansible;
  sudo chown -R ansible:ansible /home/ansible/;
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl;
  chmod +x ./kubectl;
  sudo mv ./kubectl /usr/local/bin/kubectl;
  sudo apt-get update;
  sudo apt-get install -y ansible;
  runuser -l ansible -c 'ansible-galaxy collection install kubernetes.core' ;
  runuser -l ansible -c 'ansible-galaxy collection install cloud.common' ;
  sudo apt update ;
  sudo apt -y install python3-pip ;
  sudo pip install kubernetes ;
  SCRIPT

}
## subnet without access to the internet.
resource "google_compute_subnetwork" "Restricted" {
  name          = "restricted-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc_network.id

}

resource "google_compute_router" "router2" {
  name    = "my-router2"
  region  = google_compute_subnetwork.Restricted.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat2" {
  name                               = "my-nat2"
  router                             = google_compute_router.router2.name
  region                             = google_compute_router.router2.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.Restricted.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

}