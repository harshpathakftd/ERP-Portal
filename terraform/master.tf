#############################################

# TERRAFORM MASTER FILE

# Complete Kubernetes Deployment for ERP

# Jenkins + DockerHub + Kubernetes Compatible

#############################################

terraform {

required_version = ">= 1.0"

required_providers {

```
kubernetes = {

  source  = "hashicorp/kubernetes"

  version = "~> 2.23"

}
```

}

}

#############################################

# PROVIDER CONFIGURATION

#############################################

provider "kubernetes" {

config_path = "C:/Users/rahul/.kube/config"

}

#############################################

# VARIABLES

#############################################

variable "app_name" {

description = "Application Name"

default = "erp-project"

}

variable "docker_image" {

description = "Docker Image Name"

default = "shivsoftapp/sonar-erp"

}

variable "image_tag" {

description = "Docker Image Tag from Jenkins"

default = "latest"

}

variable "replicas" {

default = 2

}

variable "container_port" {

default = 8000

}

variable "node_port" {

default = 30007

}

#############################################

# KUBERNETES DEPLOYMENT

#############################################

resource "kubernetes_deployment" "erp_deployment" {

metadata {

```
name = var.app_name

labels = {

  app = var.app_name

}
```

}

spec {

```
replicas = var.replicas

selector {

  match_labels = {

    app = var.app_name

  }

}

template {

  metadata {

    labels = {

      app = var.app_name

    }

  }

  spec {

    container {

      name  = var.app_name

      image = "${var.docker_image}:${var.image_tag}"

      image_pull_policy = "Always"

      port {

        container_port = var.container_port

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
```

}

}

#############################################

# KUBERNETES SERVICE

#############################################

resource "kubernetes_service" "erp_service" {

metadata {

```
name = "${var.app_name}-service"
```

}

spec {

```
selector = {

  app = var.app_name

}

port {

  port        = 80

  target_port = var.container_port

  node_port   = var.node_port

}

type = "NodePort"
```

}

}

#############################################

# OUTPUTS

#############################################

output "deployment_name" {

value = kubernetes_deployment.erp_deployment.metadata[0].name

}

output "service_name" {

value = kubernetes_service.erp_service.metadata[0].name

}

output "service_url" {

value = "[http://localhost:${var.node_port}](http://localhost:${var.node_port})"

}

#############################################

# END OF FILE

#############################################
