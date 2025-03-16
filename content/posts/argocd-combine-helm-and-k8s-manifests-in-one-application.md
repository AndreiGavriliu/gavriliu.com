+++
title = "Combine Helm and K8s Manifests in One ArgoCD Application"
date = "2025-03-14T18:34:06+01:00"
#dateFormat = "2006-01-02" # This value can be configured for per-post date formatting
author = ""
authorTwitter = "" #do not include @
cover = ""
tags = ["argocd", "application", "helm"]
keywords = ["", ""]
description = ""
showFullContent = false
readingTime = false
hideComments = false
+++

I feel pretty dumb right now. I used 2 ArgoCD applications for the same thing—one for my Helm chart, the other for flat manifest YAML files. Apparently, thinking isn’t my strong suit. I mean, I could barely remember where I put my coffee, let alone plan a proper ArgoCD setup! So, like any reasonable person, I had to RTFM (read the fine manual, of course), and eventually stumbled upon the brilliant solution.

```bash
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kasten
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: kasten-io
  project: default
  sources:
  - repoURL: https://charts.kasten.io
    chart: k10
    targetRevision: "7.5.7"
    helm:
      valueFiles:
      - $values/clusters/hive/apps/kasten-io/helm/values.yaml
  - repoURL: 'git@github.com:AndreiGavriliu/homelab.git'
    targetRevision: main
    ref: values
  - repoURL: 'git@github.com:AndreiGavriliu/homelab.git'
    targetRevision: main
    path: clusters/hive/apps/kasten-io/k8s-manifests
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
```

Look at how simple that was! How did I not think of this sooner? My brain must’ve been on vacation.