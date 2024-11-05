
applications:
  root-apps:
    name: app-of-apps
    namespace: argocd
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    project: default
    source:
      repoURL: ${github_repo_url}
      path: argocd-apps
      targetRevision: HEAD
    destination:
      namespace: argocd
      name: in-cluster
    syncPolicy:
      automated:
        selfHeal: true
        prune: true