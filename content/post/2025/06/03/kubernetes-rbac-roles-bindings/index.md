---
title: "Kubernetes RBAC: Who Can Do What, and Where?"
date: 2025-06-03T03:00:00+02:00
tags: ["kubernetes", "learn", "security"]

showShare: false
showReadTime: true
usePageBundles: true
toc: true
draft: false

# featureImage: 'header.png'
# featureImageAlt: 'by ChatGPT'
# featureImageCap: 'by ChatGPT'
thumbnail: 'header.png'
shareImage: 'header.png'

series: kubernetes
showRelatedInArticle:  true
showRelatedInSidebar: true
---

Let’s be honest: giving everyone admin access to your cluster is fast… until it isn’t. Enter **RBAC**, short for **Role-Based Access Control**—Kubernetes’ way of saying “hold up, who let you in here?”

RBAC defines **who** can perform **what actions** on **which resources**—like a VIP list for your Kubernetes API server.

## What Is RBAC?

RBAC in Kubernetes is all about permissions. It answers:

- **Who** is making the request? (a user, group, or service account)
- **What** are they trying to do? (e.g., list pods, delete deployments)
- **Where** are they trying to do it? (namespace or cluster)

RBAC is made up of four core objects:

| Object               | Description                                         |
|----------------------|-----------------------------------------------------|
| `Role`               | Set of permissions *within a namespace*             |
| `ClusterRole`        | Set of permissions *cluster-wide* or reusable       |
| `RoleBinding`        | Grants a Role to a user or group *in a namespace*   |
| `ClusterRoleBinding` | Grants a ClusterRole to a user/group *cluster-wide* |

## Roles: The Namespace Enforcer

A `Role` is like a door key, but it only works in one hallway (namespace).

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

This allows whoever holds this Role to list and watch pods *in the `dev` namespace*. Elsewhere? No access.

## ClusterRoles: Permissions for the Big Leagues

`ClusterRoles` can do everything a `Role` can—but they also work **cluster-wide**, and can cover non-namespaced resources like `nodes` or `persistentvolumes`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
```

If your Role is a floor pass, a ClusterRole is the building master key.

## RoleBinding: Assign the Role

Roles don’t mean anything until they’re bound to someone. Enter the `RoleBinding`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: dev
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

This says: "Hey Kubernetes, let Alice use the `pod-reader` Role—but only in `dev`."

You can bind:

- `User` – for human users
- `Group` – for teams or groups via identity provider
- `ServiceAccount` – for workloads inside the cluster

## ClusterRoleBinding: Global Permission Giver

If you want to bind a `ClusterRole` across the whole cluster—whether for users or service accounts—use a `ClusterRoleBinding`.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: global-read-nodes
subjects:
- kind: User
  name: bob
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

Now Bob can read nodes in any namespace. Dangerous? Could be. Useful? Also yes.

## Common Use Cases

| Use Case                                 | Use This                                   |
|------------------------------------------|--------------------------------------------|
| Read-only access to a namespace          | Role + RoleBinding                         |
| Cluster-wide audit permissions           | ClusterRole + ClusterRoleBinding           |
| ServiceAccount for an app to list pods   | Role + RoleBinding (to the ServiceAccount) |
| Admin team access to all resources       | ClusterRole (e.g. `cluster-admin`)         |
| Namespace-isolated dev environments      | Role per namespace                         |

## Gotchas and Tips

- **RBAC is default-deny**: No access unless explicitly granted.
- **ClusterRoleBindings ignore namespaces**: They're global.
- **Don’t bind `cluster-admin` casually**: It's the nuclear option.
- **Use Groups**: Managing permissions by group is more scalable than binding dozens of users individually.
- **Use `kubectl auth can-i`** to debug access issues:

```bash
kubectl auth can-i create deployments --as=alice --namespace=dev
```

## Example: Read-Only Access for Devs

You want devs to view deployments and pods in `staging`, but not mess things up. Here’s how:

### Create a Role:

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: staging
  name: read-only
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments"]
  verbs: ["get", "list", "watch"]
```

### Bind it:

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: devs-read
  namespace: staging
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: read-only
  apiGroup: rbac.authorization.k8s.io
```

Boom. Devs can now read pods and deployments—but not delete them.

## Cleaning Up

When roles change or people leave:

- Delete old RoleBindings and ClusterRoleBindings
- Use `kubectl describe clusterrolebinding` to audit who’s got what

## Wrapping It Up

RBAC gives you fine-grained control over who can do what in your cluster. It’s essential for:

- Security
- Compliance
- Sanity

**Remember**:

- Use `Roles` and `RoleBindings` for namespace-scoped access
- Use `ClusterRoles` and `ClusterRoleBindings` for cluster-wide or non-namespaced resources
- Least privilege is your friend

RBAC is your cluster’s bouncer. Use it wisely—and don’t let just anyone into the kube-VIP lounge.