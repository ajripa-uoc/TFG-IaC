# Install ALB Controller chart
# This controller integrates Kubernetes with AWS Application Load Balancers (ALBs),
# automatically creating and managing ALBs to route external traffic to services running in the EKS cluster.
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html


# Role-based access control (RBAC) configuration for the AWS ALB controller.
# This IAM role allows the AWS ALB controller to assume the role and manage Application Load Balancers.
# Reference: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
module "aws_alb_controller_role" {
  depends_on = [module.eks]
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "eks-aws-alb-controller-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

# Create a Kubernetes service account for the AWS ALB controller
resource "kubernetes_service_account" "aws-load-balancer-controller" {
  depends_on = [module.aws_alb_controller_role]
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_alb_controller_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

# Install AWS ALB Controller chart
resource "helm_release" "aws_alb_controller" {
  depends_on = [kubernetes_service_account.aws-load-balancer-controller]
  name       = "aws-alb-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.9.2"
  values  = [templatefile("templates/aws-alb-controller.yaml.tpl", {
    cluster_name    = module.eks.cluster_name,
    iam_role_arn    = module.aws_alb_controller_role.iam_role_arn
  })]
}

# Create a Kubernetes Ingress resource for the shared ALB
# This Ingress resource will be used to route external traffic to services in the EKS cluster
# using the shared Application Load Balancer (ALB) created by the AWS ALB controller.
# Default response action is configured to return a fixed response message.

resource "kubernetes_ingress_v1" "shared_public" {
  depends_on = [ helm_release.aws_alb_controller ]
  metadata {
    name      = "shared-alb-public"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/group.name"           = "shared-public"                       # Group name for shared ALB
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"                     # ALB scheme (e.g., public)
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"   # ALB listeners
      "alb.ingress.kubernetes.io/certificate-arn"      = module.acm.acm_certificate_arn        # ACM certificate ARN for HTTPS
      "alb.ingress.kubernetes.io/target-type"          = "ip"                                  # Target type as IP for Fargate/EKS
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"                                 # Redirect HTTP to HTTPS
      "external-dns.alpha.kubernetes.io/hostname"      = var.domain_name                       # Domain name for the ALB

      # Fixed response action configuration
      "alb.ingress.kubernetes.io/actions.fixed-response" = jsonencode({
        Type = "fixed-response",
        FixedResponseConfig = {
          ContentType = "text/plain",
          StatusCode  = "200",
          MessageBody = "TFG default response"
        }
      })
    }
  }

   spec {
    ingress_class_name = "alb"

    # Default response for root domain
    rule {
      host = var.domain_name
      http {
        path {
          path     = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "fixed-response"
              port {
                name = "use-annotation"
              }
            }
          }
        }
      }
    }

    # Default backend for the Ingress resource
    default_backend {
      service {
        name = "fixed-response"
        port {
          name = "use-annotation"
        }
      }
    }
  }
}

