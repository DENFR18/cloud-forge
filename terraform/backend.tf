# Remote state — à configurer si besoin avec Scaleway Object Storage
# Pour l'instant on utilise le state local
#
# terraform {
#   backend "s3" {
#     bucket                      = "cloud-forge-tfstate"
#     key                         = "terraform.tfstate"
#     region                      = "fr-par"
#     endpoint                    = "https://s3.fr-par.scw.cloud"
#     skip_credentials_validation = true
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#   }
# }
