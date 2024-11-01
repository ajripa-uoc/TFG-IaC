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

# Install AWS ALB Controller chart
resource "helm_release" "aws_alb_controller" {
  depends_on = [module.aws_alb_controller_role]
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

