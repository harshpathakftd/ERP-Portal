terraform {

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

  }

}

provider "kubernetes" {

  config_path = "~/.kube/config"

}

# ============================
# Create Namespace
# ============================

resource "kubernetes_namespace" "devops_ns" {

  metadata {

    name = "devops-sonarqube"

  }

}

# ============================
# Create Deployment
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

          port {

            container_port = 8000

          }

        }

      }

    }

  }

}

# ============================
# Create Service
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