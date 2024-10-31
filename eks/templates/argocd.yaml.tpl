global:
  domain: ${domain}
configs:
  cm:
    dex.config: |
        connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${clientid}
            clientSecret: ${clientsecret}
    rbac:
      policy.csv: |
       g, org:admin, role:admin
    admin.enabled: false # Disable admin user. We are using GitHub OAuth.
repositories:
  - url: https://github.com/ajripa-uoc/TFG-GitOps