terraform {

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

  }

}

# IMPORTANT: Do NOT use config_path
# Jenkins will provide kubeconfig via KUBECONFIG environment variable

provider "kubernetes" {
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

          name  = "devops-container"
          image = "shivsoftapp/devops-sonarqube-image:33"

          image_pull_policy = "Always"

          port {
            container_port = 8000
          }

          # Recommended resources for production

          resources {

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }

            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }

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