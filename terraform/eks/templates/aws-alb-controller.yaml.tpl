clusterName: ${cluster_name}
enableCertManager: false
serviceAccount:
  create: false
  name: aws-load-balancer-controller
  annotations:
    eks.amazonaws.com/role-arn: ${iam_role_arn}