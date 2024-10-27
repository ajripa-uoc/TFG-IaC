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
    # - Enable local admin user
    ## Ref: https://argo-cd.readthedocs.io/en/latest/faq/#how-to-disable-admin-user
    admin.enabled: false