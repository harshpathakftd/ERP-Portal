terraform {

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

  }

}

# Kubernetes provider
# KUBECONFIG will be provided by Jenkins credential
provider "kubernetes" {
}

# ============================
# Variable for Docker Image
# ============================

variable "docker_image" {
  description = "Docker image with tag"
  default     = "shivsoftapp/devops-sonarqube-image:33"
}

# ============================
# Namespace
# ============================

resource "kubernetes_namespace" "devops_ns" {

  metadata {
    name = "devops-sonarqube"
  }

}

# ============================
# Deployment
# ============================

resource "kubernetes_deployment" "devops_app" {

  metadata {

    name      = "devops-sonarqube-app"
    namespace = kubernetes_namespace.devops_ns.metadata[0].name

    labels = {
      app = "devops-sonarqube"
    }

  }

  spec {

    replicas = 2

    selector {
      match_labels = {
        app = "devops-sonarqube"
      }
    }

    template {

      metadata {
        labels = {
          app = "devops-sonarqube"
        }
      }

      spec {

        container {

          name              = "devops-container"
          image             = var.docker_image
          image_pull_policy = "Always"

          port {
            container_port = 8000
          }

        }

      }

    }

  }

}

# ============================
# Service
# ============================

resource "kubernetes_service" "devops_service" {

  metadata {

    name      = "devops-sonarqube-service"
    namespace = kubernetes_namespace.devops_ns.metadata[0].name

  }

  spec {

    selector = {
      app = "devops-sonarqube"
    }

    port {

      port        = 8000
      target_port = 8000
      node_port   = 30007

    }

    type = "NodePort"

  }

}

# ============================
# Outputs
# ============================

output "namespace" {
  value = kubernetes_namespace.devops_ns.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.devops_app.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.devops_service.metadata[0].name
}

output "service_node_port" {
  value = kubernetes_service.devops_service.spec[0].port[0].node_port
}