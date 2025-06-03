---
title: "Kubernetes Volumes: Where Pods Keep Their Stuff"
date: 2025-06-03T03:00:00+02:00
tags: ["kubernetes", "learn", "storage"]

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

*Or: “How to Give Your Containers a Place to Put Their Shoes”*

In the beginning, there was the container. And it was stateless. Ephemeral. Disposable. Like a temporary pop-up tent in the cloud. But then… someone said, “Hey, where do I put my logs? My files? My database?”

Enter **Kubernetes Volumes** — the answer to the age-old question: *“Where does my pod keep its stuff?”*

## Why Volumes Matter (a.k.a. The Tragic Tale of /tmp)

Let’s say you write a file in your container, and the pod restarts. Surprise! The file’s gone. That’s because containers are built for immutability. Any data written inside the container is gone when it crashes or gets rescheduled.

**Volumes provide a stable place for data that outlives the container.**

> A Volume in Kubernetes is like a shared hard drive your containers can access. It's attached to a Pod, not the individual container.

## A Quick Look at Volume Types

There are several volume types, each with different behaviors. Here's a table to keep your brain organized:

| Volume Type                                              | Description                                              |
| -------------------------------------------------------- | -------------------------------------------------------- |
| `emptyDir`                                               | Temporary directory, wiped on pod deletion               |
| `hostPath`                                               | Mounts a file or dir from the node’s filesystem (risky!) |
| `persistentVolumeClaim (PVC)`                            | Connects to persistent storage like a cloud disk or NFS  |
| `configMap` / `secret`                                   | Mounts ConfigMaps or Secrets as files in the container   |
| `nfs`, `awsElasticBlockStore`, `longhorn-storage`, etc.  | Specific storage providers                               |
| `projected`                                              | Combines several sources into one volume                 |
| `ephemeral`                                              | Like a PVC but declared inline in the pod spec           |

Let’s dive into a few common ones.

## emptyDir – The Not-So-Permanent Roommate

This is the simplest volume type. It’s created when a Pod is assigned to a Node and exists as long as the Pod lives.

```yaml
volumes:
  - name: scratch-space
    emptyDir: {}
```

Mount it like this in a container:

```yaml
volumeMounts:
  - name: scratch-space
    mountPath: /tmp/data
```

**Great for**: temporary files, caches, or sharing data between containers in the same pod.

**Bad for**: storing anything you want to keep after the pod is deleted or moved.

## hostPath – Mounting the Node's Basement

You can mount a file or directory from the node directly:

```yaml
volumes:
  - name: log-storage
    hostPath:
      path: /var/log/myapp
      type: DirectoryOrCreate
```

**Warning**: This is very node-specific. If your pod gets moved to another node, and the directory isn’t there...

## Persistent Volume Claims – Now We’re Talking Durable

This is where Kubernetes gets serious about storage. Instead of directly mounting a volume, you:

1. Create a `PersistentVolume` (PV) – like a cloud disk or NFS share.
2. Request it via a `PersistentVolumeClaim` (PVC).
3. Mount the PVC to your pod.

### PVC Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

Mount it in your pod:

```yaml
volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: my-pvc
```

And in your container:

```yaml
volumeMounts:
  - name: storage
    mountPath: /data
```

**Perfect for**: databases, file uploads, or any data that needs to stick around even if your pod doesn’t.

### Bonus: StorageClass for Dynamic Provisioning

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
```

PVC with StorageClass:

```yaml
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

Kubernetes automatically provisions a volume when the PVC is created. Magic!

## ReadWriteOnce? ReadOnlyMany? What’s With These Modes?

* `ReadWriteOnce` (RWO): One node can read/write.
* `ReadOnlyMany` (ROX): Multiple nodes can read (but not write).
* `ReadWriteMany` (RWX): Multiple nodes can read/write (great for shared filesystems like NFS or CephFS).

## Volumes in Multi-Container Pods

Got a pod with two containers that need to talk? Volumes to the rescue!

```yaml
volumes:
  - name: shared-logs
    emptyDir: {}

containers:
  - name: app
    volumeMounts:
      - mountPath: /var/log/myapp
        name: shared-logs

  - name: sidecar
    volumeMounts:
      - mountPath: /data/logs
        name: shared-logs
```

Your app writes logs. The sidecar reads and ships them elsewhere. Classic.

## ConfigMap & Secret Volumes – Mounting Configuration Like a Pro

```yaml
volumes:
  - name: config-vol
    configMap:
      name: my-config

  - name: secret-vol
    secret:
      secretName: db-credentials
```

Mounting in containers:

```yaml
volumeMounts:
  - name: config-vol
    mountPath: /etc/config
  - name: secret-vol
    mountPath: /etc/secrets
    readOnly: true
```

These volumes are ideal for mounting configuration files, TLS certs, and other secrets.

## Gotchas to Avoid

* Mounting the same volume to the same path in multiple containers without coordination? Race conditions.
* Writing secrets to a PVC that doesn’t get cleaned up? That's how breaches happen.
* Assuming your volume is replicated or backed up? Check your storage class—**assume nothing**.
* Using `emptyDir` for anything you actually care about.

## Pro Tips

* Use **StorageClasses** to automate PVC provisioning.
* Use **init containers** to set up volume contents before your main container starts.
* Mount **readOnly: true** if the container doesn’t need to write. It’s safer.
* Monitor your disk usage. It’s easy to run out of space when you store *everything* in `/data`.
* Consider volume **expansion** if your PVC supports it:

```yaml
resources:
  requests:
    storage: 20Gi
```

## Wrapping It Up

Kubernetes Volumes give your containers somewhere to put their things—and not just temporary things that go poof when the pod dies. With Volumes and PersistentVolumeClaims, you unlock **stateful apps**, **shared logs**, **sidecar patterns**, and **secure configuration delivery**.

📦 So remember:

* `emptyDir` is temporary.
* `hostPath` is dangerous.
* PVCs are durable (and sane).
* Volume types abound—choose wisely.

Let your pods keep their stuff, but make sure they clean up after themselves.
