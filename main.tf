terraform {
  required_version = ">= 1.7.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.88"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {

  host                   = module.eks_windows.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_windows.eks_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_windows.eks_cluster_name]
  }
}

module "eks_windows" {
  source                                         = "1nval1dctf/eks-windows/aws"
  version                                        = "0.5.0"                   
  eks_autoscaling_group_linux_min_size           = 1
  eks_autoscaling_group_linux_desired_capacity   = 1
  eks_autoscaling_group_linux_max_size           = 2
  eks_autoscaling_group_windows_min_size         = 0
  eks_autoscaling_group_windows_desired_capacity = 0
  eks_autoscaling_group_windows_max_size         = 0
  enable_metrics_server                          = false
  enable_cluster_autoscaler                      = false
  enable_cloudwatch_exported                     = false
  external_dns_support                           = true
  eks_cluster_name                               = "ctf-eks"
  enable_calico_network_polices                  = true
  aws_region                                     = var.aws_region
  eks_cluster_version                            = var.eks_cluster_version
}

resource "kubernetes_namespace" "challenges" {
  metadata {
    name = "challenges"
  }
}


resource "kubernetes_secret" "regcred" {
  count = var.registry_username == null ? 0 : 1
  metadata {
    name = "regcred"
    namespace = kubernetes_namespace.challenges.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}



module "ctfd" {
  source                            = "1nval1dctf/ctfd/aws"
  version                           = "1.1.8"     
  force_destroy_challenge_bucket    = true
  force_destroy_log_bucket          = true
  db_deletion_protection            = false
  elasticache_cluster_instances     = 2
  elasticache_cluster_instance_type = "cache.t3.micro"
  db_serverless                     = true
  db_skip_final_snapshot            = true
  registry_server                   = var.registry_server
  registry_username                 = var.registry_username
  registry_password                 = var.registry_password
  ctfd_image                        = var.ctfd_image
  ctf_domain                        = var.ctf_domain
  ctf_domain_zone_id                = var.ctf_domain_zone_id
  https_certificate_arn             = var.https_certificate_arn
  aws_region                        = var.aws_region
}


# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name = "nginx"
#     labels = {
#       app = "nginx"
#     }
#   }

#   spec {
#     replicas = 1
#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }
#       spec {
#         container {
#           image             = "nginx:latest"
#           name              = "nginx"
#           image_pull_policy = "Always"

#           port {
#             container_port = 80
#           }
#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80
#             }
#             initial_delay_seconds = 10
#             period_seconds        = 20
#             timeout_seconds       = 5
#           }

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#         }
#         node_selector = {
#           "kubernetes.io/os"   = "linux"
#           "kubernetes.io/arch" = "amd64"
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_service" "nginx" {
#   metadata {
#     name = "nginx"
#     annotations = {
#       "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
#       "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
#       "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
#     }
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.nginx.spec[0].template[0].metadata[0].labels.app
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }
#     type                = "LoadBalancer"
#     load_balancer_class = "service.k8s.aws/nlb"
#   }
#   depends_on = [module.eks_windows.load_balancer_controller_helm_release_version]
# }
