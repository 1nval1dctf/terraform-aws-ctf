

variable "kubernetes_deployment_node_selector" {
  type = map(string)
  default = {
    "kubernetes.io/os" = "linux"
  }
  description = "Node selectors for kubernetes deployment"
}

resource "kubernetes_deployment" "external_dns_challenge" {
  timeouts {
    create = "1m"
    update = "1m"
    delete = "1m"
  }
  metadata {
    name = "external-dns-challenge"
    namespace = "default"
  }

  spec {

    selector {
      match_labels = {
        app = "external-dns-challenge"
      }
    }

    template {
      metadata {
        labels = {
          app  = "external-dns-challenge"
          name = "external-dns-challenge"
        }
      }

      spec {
        container {
          name  = "external-dns"
          image = "registry.k8s.io/external-dns/external-dns:v0.15.1"
          args = concat([
            "--source=service",
            "--source=ingress",
            "--domain-filter=${var.chal_domain}",
            "--provider=aws",
            "--policy=upsert-only",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=external-dns"
          ])
          env {
            name = "AWS_DEFAULT_REGION"
            value = var.aws_region
          }
        }
        security_context {
          fs_group = 65534
        }
        node_selector = var.kubernetes_deployment_node_selector

        service_account_name            = "external-dns"
        automount_service_account_token = "true"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}