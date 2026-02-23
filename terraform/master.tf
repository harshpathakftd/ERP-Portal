terraform {

  required_version = ">= 1.3.0"

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

  }

}

# ============================
# Kubernetes Provider
# ============================

provider "kubernetes" {

  config_path = "~/.kube/config"

}

# ============================
# Namespace
# ============================

resource "kubernetes_namespace" "devops_ns" {

  metadata {

    name = "devops-sonarqube"

    labels = {
      environment = "production"
      project     = "devops-sonarqube"
    }

  }

}

# ============================
# Deployment
# ============================

resource "kubernetes_deployment" "devops_app" {

  metadata {

    name      = "devops-sonarqube-deployment"
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

          name  = "devops-sonarqube-container"

          image = "shivsoftapp/devops-sonarqube-image:33"

          image_pull_policy = "Always"

          port {

            container_port = 8000

          }

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

    labels = {
      app = "devops-sonarqube"
    }

  }

  spec {

    selector = {
      app = "devops-sonarqube"
    }

    port {

      port        = 8995
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

output "application_access" {

  value = "Access your app using: http://<NODE-IP>:30007"

}