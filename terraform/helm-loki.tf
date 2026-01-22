resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.47.1" # Using newer loki chart (not loki-stack) for S3 support
  namespace  = kubernetes_namespace.observability.metadata[0].name

  values = [yamlencode({
    # Single binary mode for simplicity (good for learning/small scale)
    deploymentMode = "SingleBinary"

    loki = {
      # Use S3 for storage instead of filesystem
      storage = {
        type = "s3"
        s3 = {
          region      = var.aws_region
          bucketnames = aws_s3_bucket.loki.id
          # Use IRSA for authentication (no access keys needed)
          # The service account annotation handles authentication
        }
      }

      # Common config for all components
      commonConfig = {
        replication_factor = 1
      }

      # Schema configuration
      schemaConfig = {
        configs = [{
          from         = "2026-01-22"
          store        = "tsdb"
          object_store = "s3"
          schema       = "v13"
          index = {
            prefix = "index_"
            period = "24h"
          }
        }]
      }

      # Storage config
      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/loki/tsdb-index"
          cache_location         = "/var/loki/tsdb-cache"
        }
      }

      # Limits for cost optimization
      limits_config = {
        retention_period            = "168h" # 7 days retention
        ingestion_rate_mb           = 4
        ingestion_burst_size_mb     = 6
        max_streams_per_user        = 10000
        max_global_streams_per_user = 10000
      }
    }

    # Single binary configuration
    singleBinary = {
      replicas = 1
      persistence = {
        enabled = true
        size    = "2Gi" # Small local storage for WAL/cache only
      }
    }

    # Service account with IRSA annotation
    serviceAccount = {
      create = true
      name   = "loki"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.loki.arn
      }
    }

    # Disable components not needed for single binary mode
    backend = {
      replicas = 0
    }
    read = {
      replicas = 0
    }
    write = {
      replicas = 0
    }

    # Gateway configuration
    gateway = {
      enabled  = true
      replicas = 1
    }

    # Disable minio (we're using AWS S3)
    minio = {
      enabled = false
    }

    # Monitoring
    monitoring = {
      selfMonitoring = {
        enabled = false # Disable for cost savings
      }
      lokiCanary = {
        enabled = false
      }
    }

    # Test configuration
    test = {
      enabled = false
    }
  })]

  depends_on = [
    kubernetes_namespace.observability,
    aws_s3_bucket.loki,
    aws_iam_role_policy.loki_s3
  ]
}

# Fluent Bit for log collection (separate from Loki)
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.43.0"
  namespace  = kubernetes_namespace.observability.metadata[0].name

  values = [yamlencode({
    config = {
      outputs = <<-EOT
        [OUTPUT]
            Name        loki
            Match       kube.*
            Host        loki-gateway.observability.svc.cluster.local
            Port        80
            Labels      job=fluent-bit
            Auto_Kubernetes_Labels on
      EOT
    }
  })]

  depends_on = [helm_release.loki]
}
