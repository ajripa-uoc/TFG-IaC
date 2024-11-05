# ArgoCD application of applications manifest that will be used to deploy the ArgoCD applications
applications:
  app-of-apps:
    name: app-of-apps
    namespace: argocd
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    project: default
    source:
      repoURL: ${github_repo_url} # This is the URL of the repository that contains the ArgoCD application manifests
      path: argocd-apps # This is the path within the repository that contains the ArgoCD application manifests
      targetRevision: HEAD
    destination:
      namespace: argocd
      name: in-cluster
    syncPolicy:
      automated:
        selfHeal: true # Automatically reapply the manifests if they are changed
        prune: true # Automatically delete resources that are not defined in the manifests