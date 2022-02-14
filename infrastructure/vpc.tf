resource "google_compute_network" "vpc_network" {
  project                 = "lustrous-maxim-341315"
  name                    = "custom-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}