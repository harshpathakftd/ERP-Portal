########################################

# Terraform Kubernetes Deployment File

# Windows + Jenkins Compatible

########################################

terraform {

required_version = ">= 1.0"

required_providers {
kubernetes = {
source  = "hashicorp/kubernetes"
version = "~> 2.23"
}
}

}

########################################

# Variables from Jenkins

########################################

variable "docker_image" {
type = string
}

variable "image_tag" {
type = string
}

########################################

# Kubernetes Provider (Windows)

########################################

provider "kubernetes" {

config_path = "C:/Users/rahul/.kube/config"

}

########################################

# Deployment

########################################

resource "kubernetes_deployment" "erp" {

metadata {
name = "erp-deployment"

labels = {
  app = "erp-app"
}

}

spec {

replicas = 2

selector {
  match_labels = {
    app = "erp-app"
  }
}

template {

  metadata {
    labels = {
      app = "erp-app"
    }
  }

  spec {

    container {

      name  = "erp-container"

      image = "${var.docker_image}:${var.image_tag}"

      image_pull_policy = "Always"

      port {
        container_port = 8000
      }

    }

  }

}


}

}

########################################

# Service

########################################

resource "kubernetes_service" "erp_service" {

metadata {
name = "erp-service"
}

spec {

selector = {
  app = "erp-app"
}

port {
  port        = 8000
  target_port = 8000
  node_port   = 30007
}

type = "NodePort"

}

}
