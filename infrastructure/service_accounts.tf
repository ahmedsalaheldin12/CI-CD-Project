resource "google_service_account" "custom" {
account_id = "gke-service-acount"
display_name = "gke-service-acount"
}

resource "google_project_iam_binding" "role1" {
project = "lustrous-maxim-341315"
role = "roles/container.admin"
depends_on = [
google_service_account.custom
]
members = [
"serviceAccount:${google_service_account.custom.email}"
]
}

resource "google_project_iam_binding" "role2" {
project = "lustrous-maxim-341315"
role = "roles/visualinspection.serviceAgent"
depends_on = [
google_service_account.custom
]
members = [
"serviceAccount:${google_service_account.custom.email}"
]
}


resource "google_service_account" "vm_service_account" {
  account_id   = "vm-service-acount"
  display_name = "vm-service-acount"
}

resource "google_project_iam_binding" "vm_service_account_role" {
  project = "lustrous-maxim-341315"
  role    = "roles/container.admin"
  depends_on = [
    google_service_account.vm_service_account
  ]
  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}

resource "google_project_iam_binding" "vm_service_account_role2" {
  project = "lustrous-maxim-341315"
  role    = "roles/container.developer"
  depends_on = [
    google_service_account.vm_service_account
  ]
  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}"
  ]
}