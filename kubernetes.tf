resource "helm_release" "s3_csi_driver" {
  name       = "aws-mountpoint-s3-csi-driver"
  repository = "https://awslabs.github.io/mountpoint-s3-csi-driver"
  chart      = "aws-mountpoint-s3-csi-driver"
  version    = "1.14.1"
  namespace  = "kube-system"

  values = [
    yamlencode({
      node = {
        serviceAccount = {
          create = true
          name   = "s3-csi-controller-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.aws_s3_csi_driver_role.arn
          }
        }
      }
    })
  ]
}

resource "helm_release" "external_dns" {
  name       = "jit-external-dns"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.16.1"

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "env[0].name"
    value = "CF_API_TOKEN"
  }

  set {
    name  = "env[0].valueFrom.secretKeyRef.name"
    value = kubernetes_secret.cloudflare_api_secret.metadata[0].name
  }

  set {
    name  = "env[0].valueFrom.secretKeyRef.key"
    value = "api-token"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "domainFilters[0]"
    value = data.cloudflare_zones.cloudflare_zones.zones[0].name
  }

  set {
    name  = "txtOwnerId"
    value = module.eks.cluster_name
  }

  set {
    name  = "sources[0]"
    value = "ingress"
  }
}

resource "helm_release" "cert_manager" {
  name       = "jit-cert-manager"
  namespace  = "kube-system"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.17.2"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "extraArgs"
    value = "{--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\\,1.1.1.1:53}"
  }
}

resource "kubernetes_secret" "cloudflare_api_secret" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "kube-system"
  }

  data = {
    "api-token" = var.cloudflare_api_token
  }
}

resource "kubernetes_manifest" "letsencrypt_issuer" {
  count = var.initial_setup ? 0 : 1
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cloudflare-issuer"
    }
    spec = {
      acme = {
        email  = var.cloudflare_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "lets-encrypt-account-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                email = var.cloudflare_email
                apiTokenSecretRef = {
                  name = kubernetes_secret.cloudflare_api_secret.metadata[0].name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "jit-nginx"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.0"

  values = [
    yamlencode({
      controller = {
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
        ingressClassResource = {
          name    = "nginx"
          enabled = true
          default = true
        }
        ingressClass = "nginx"
        serviceAccount = {
          create = true
          name   = "jit-nginx"
        }
      }
    })
  ]
}
