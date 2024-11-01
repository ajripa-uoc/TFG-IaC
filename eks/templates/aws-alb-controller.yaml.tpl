clusterName: ${cluster_name}
enableCertManager: true
serviceAccount:
  create: false
  name: aws-load-balancer-controller
  annotations:
    eks.amazonaws.com/role-arn: ${iam_role_arn}