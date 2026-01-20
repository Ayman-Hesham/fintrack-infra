resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [yamlencode({
    server = {
      service = {
        type = "LoadBalancer"
      }
      replicas = 1 # Cost optimization
    }
    controller = {
      replicas = 1 # Cost optimization
    }
    repoServer = {
      replicas = 1 # Cost optimization
    }
    configs = {
      params = {
        "server.insecure" = true
      }
    }
  })]

  depends_on = [kubernetes_namespace.argocd]
}
