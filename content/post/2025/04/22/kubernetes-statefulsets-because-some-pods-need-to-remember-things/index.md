---
title: "Kubernetes StatefulSets: Because Some Pods Need to Remember Things"
date: 2025-04-22T08:30:35+02:00
tags: ["kubernetes", "learn", "statefulset"]

showShare: false
showReadTime: true
usePageBundles: true
toc: true
draft: false

# featureImage: 'image.png'
# featureImageAlt: 'Rack by ChatGPT'
# featureImageCap: 'Rack by ChatGPT'
# thumbnail: 'image.png'
# shareImage: 'image.png'

series: kubernetes
showRelatedInArticle:  true
showRelatedInSidebar: true
---

You’ve learned about Deployments, and now you’re deploying stateless apps like a boss. But then you hit a wall - maybe it’s a database, a cache, or something that *cares* about identity and storage. Enter: **StatefulSets**.

StatefulSets are like that one friend who always insists on sitting in the same seat - and gets mad if they can't.

## What is a StatefulSet?

A **StatefulSet** is a Kubernetes controller used to manage stateful applications. Unlike Deployments, StatefulSets:

- Give each Pod a **stable, unique network identity**
- Retain **persistent storage** even when a Pod is deleted
- Ensure Pods are created, updated, and deleted **in order**

In short, StatefulSets are what you use when your app:
- Can’t just be randomly killed and restarted
- Needs to store and retain data
- Needs stable DNS names to communicate with peer Pods

## A Real-Life Analogy

- **Deployment:** "Hey, you’re a worker. Grab any desk and get to it."
- **StatefulSet:** "You're Dave. You sit at Desk #3. Your coffee mug is there. If you move, your entire routine is ruined."

## A Basic StatefulSet Example

Here’s a simplified YAML to show what a StatefulSet looks like:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: "redis"
  replicas: 3
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7
        ports:
        - containerPort: 6379
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

Let’s unpack this like your app depends on it (because it does):

- `replicas: 3` - We want 3 Pods. But not just any Pods. These will be called:
  - `redis-0`
  - `redis-1`
  - `redis-2`
- `serviceName: redis` - Each Pod gets a stable DNS name like `redis-0.redis.default.svc.cluster.local`.
- `volumeClaimTemplates` - Each Pod gets its own PersistentVolumeClaim (PVC), like a personal journal. Data is **not** shared between Pods.

## Why the Order Matters

With StatefulSets, **order is everything**:

- Pods are created *sequentially*: `redis-0` → `redis-1` → `redis-2`
- Pods are deleted *in reverse*: `redis-2` → `redis-1` → `redis-0`
- When updating, K8s updates Pods **one at a time**, waiting for each to be ready

This makes StatefulSets ideal for apps that need quorum, coordination, or recovery - think **databases** like Cassandra, MongoDB, or distributed systems like Zookeeper.

## Persistent Storage: Your Pod’s Sock Drawer

With Deployments, Pods are ephemeral - they come and go, and all local data goes with them. StatefulSets, on the other hand, give each Pod a PVC that sticks around.

Even if the Pod gets deleted and recreated, its storage (and name) remain the same. It’s like saving a named workspace in the cloud instead of scribbling notes on a whiteboard.

## Headless Services and DNS

A StatefulSet needs a **headless service** to manage DNS for its Pods. Why?

Because each Pod gets a DNS name like:

```text
redis-0.redis.default.svc.cluster.local
```

You define the headless service like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  clusterIP: None
  selector:
    app: redis
  ports:
  - port: 6379
```

Notice the `clusterIP: None`? That’s what makes it headless - so K8s won’t load balance, and DNS queries return **individual Pod IPs**, not a single shared one.

## StatefulSet Lifecycle: The Long, Orderly March

Let’s say you create a 3-replica StatefulSet.

Here’s what happens:

1. `redis-0` is created. Kubernetes waits until it’s ready.
2. `redis-1` is created next. Again, K8s waits.
3. Finally, `redis-2`.

If `redis-1` fails health checks, `redis-2` will not be created. K8s will just sit patiently, tapping its fingers.

It’s like assembling IKEA furniture - if Step 2 fails, you don’t even *think* about Step 3.

## Deleting a StatefulSet: What Stays and What Goes

Deleting a StatefulSet does **not** delete the PVCs by default.

So even if your Pods are gone, their data remains - like ghosts in the persistent volume. You can manually clean them up if needed, but Kubernetes is trying to help you avoid accidental data loss.

## What StatefulSets Are Great For

- Databases (Postgres, MySQL, MongoDB)
- Distributed systems (Kafka, Zookeeper, etcd)
- Apps that require stable identities
- Any service where order, identity, and persistent data matter

## What They’re Not Great For

- Stateless apps (just use Deployments!)
- Services that can scale randomly
- Apps that don’t need individual storage or DNS identity

If you try to use StatefulSets for a simple web app, you’re probably over-engineering it. It’s like renting a forklift to carry a sandwich.

## Wrapping It Up: The Stateful Life

Here’s your tl;dr:

- StatefulSets give your Pods stable identities and persistent storage.
- Pods are created and deleted in order.
- Great for stateful apps like databases and clusters.
- Backed by headless services for DNS magic.
- PVCs stick around even if Pods don’t.

StatefulSets are Kubernetes’ way of saying: *“This app has trust issues - let’s treat it with care, give it a fixed name, a personal volume, and never move its stuff without asking.”*
