resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.11"
  namespace  = "kube-system"

  set = {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [module.eks]
}
