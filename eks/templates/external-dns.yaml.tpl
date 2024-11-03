provider: ${provider}
aws.zoneType: ${aws_zone_type}
txtOwnerId: ${txt_owner_id}
txtPrefix: "txt-"
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${iam_role_arn}
domainFilters:
  - ${domain_name}
