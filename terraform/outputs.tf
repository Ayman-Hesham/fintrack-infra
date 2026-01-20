output "region" {
  value = var.aws_region
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "ecr_frontend_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "rds_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "rds_master_username" {
  value     = aws_db_instance.main.username
  sensitive = true
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "Add this to GitHub secrets as AWS_GITHUB_ACTIONS_ROLE_ARN"
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "argocd_server" {
  value = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "grafana_url" {
  value = "kubectl get svc kube-prometheus-stack-grafana -n observability -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "alertmanager_url" {
  description = "Command to get AlertManager URL"
  value       = "kubectl get svc kube-prometheus-stack-alertmanager -n observability -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "prometheus_url" {
  description = "Command to get Prometheus URL"
  value       = "kubectl port-forward -n observability svc/kube-prometheus-stack-prometheus 9090:9090"
}

output "access_urls" {
  description = "Quick access commands for all services"
  value = {
    argocd       = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    grafana      = "kubectl get svc kube-prometheus-stack-grafana -n observability -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    alertmanager = "kubectl get svc kube-prometheus-stack-alertmanager -n observability -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
    ingress      = "kubectl get svc ingress-nginx-controller -n application -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
  }
}

output "argocd_initial_password" {
  value     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  sensitive = true
}

output "estimated_hourly_cost" {
  value = "~$0.50-0.80/hour (EKS control plane + t3.small spots + db.t3.micro + minimal storage)"
}
