
applications:
  root-apps:
    name: root-app
    namespace: argocd
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    project: default
    source:
      repoURL: ${github_repo_url}
      path: argocd-apps
      targetRevision: HEAD
    destination:
      namespace: root-app
      name: in-cluster
    syncPolicy:
      automated:
        selfHeal: true
        prune: true