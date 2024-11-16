global:
  domain: ${domain_name}
server:
  ingress:
    enabled: true
    ingressClassName: alb
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/group.name: shared-public
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      external-dns.alpha.kubernetes.io/hostname: ${domain_name}
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    hosts:
      - host: ${domain_name}
    paths:
      - /
configs:
  cm:
    dex.config: |
        connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${github_app_client_id}
            clientSecret: ${github_app_client_secret}
    #admin.enabled: false # Disable admin user. We use Github credentials.
    accounts.gitops: apiKey # api key to be used in pipelines
  rbac:
    scopes: '[group, email]'
    policy.csv: |
      p, role:devops, applications, *, */*, allow
      p, role:devops, projects, *, *, allow
      g, gitops, role:devops
      g, ${argocd_admin_user}, role:admin
