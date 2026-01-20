resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
    annotations = {
      "iam.amazonaws.com/permitted" = aws_iam_role.external_secrets.arn
    }
  }
  depends_on = [module.eks]
}
