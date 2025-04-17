---
title: "Kubernetes Deployments: Like a Boss (Who Delegates Everything)"
date: 2025-04-17T08:30:35+02:00
tags: ["kubernetes", "learn", "deployment"]

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

So you’ve heard about Kubernetes and now you’re swimming in YAML like it’s alphabet soup. Let’s break down one of its most useful concepts - the almighty **Deployment** - and figure out how it works without having to learn an arcane spellbook.

## What’s a Deployment, Anyway?

A Kubernetes **Deployment** is like your project manager. It doesn’t do the actual work (that's what Pods are for), but it makes sure your app:

- Gets deployed correctly
- Stays running
- Gets updated safely
- Survives when something crashes
- Scales like a beast (or kitten, if you ask nicely)

In short, it’s a declarative way to manage **ReplicaSets**, which in turn manage **Pods**. You tell it what you want, and it handles the how.

## Anatomy of a Deployment

Let’s look at a simple example and break it down:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-cool-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cool
  template:
    metadata:
      labels:
        app: cool
    spec:
      containers:
      - name: cool-container
        image: mycoolapp:latest
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
```

**What’s happening here?**

- `replicas: 3` - “Hey K8s, I want 3 copies of this Pod. No more, no less.”
- `selector` - Tells the Deployment how to find the Pods it manages.
- `template` - This is the actual Pod spec that ReplicaSets will use to launch Pods.
- `resources` - Requests and limits for CPU and memory. More on this in a sec.

## Labels and Selectors: The Kubernetes Dating App

In Kubernetes, labels are like stickers on your containers: they tell the rest of the system what something is. Selectors are how components find each other.

In the Deployment above:
```yaml
labels:
  app: cool
```
matches with:
```yaml
selector:
  matchLabels:
    app: cool
```

It’s basically saying: *“I only manage Pods that are also into cool stuff.”*

No label? No match. Kubernetes is strict like that.

## Requests and Limits: Keep Your Pods on a Diet

Kubernetes is a multi-tenant system. Without resource limits, one greedy container could hog everything like it’s an all-you-can-eat buffet.

- **Requests** = The minimum CPU/memory a Pod needs to function.
- **Limits** = The maximum it’s allowed to consume.

If your container goes beyond its limit, Kubernetes might throttle it. Or evict it. Or just silently judge you.

**Always set these** - they protect both your app *and* your cluster.

## A Bit More on ReplicaSets: The Middle Manager You Don’t See

Every Deployment creates a **ReplicaSet** to do the actual work of launching Pods and keeping the correct number alive.

And when you update your Deployment - like changing the image version - Kubernetes **creates a new ReplicaSet** for the new spec.

You can see them with:

```bash
kubectl get replicasets
```

They’ll have names like `my-cool-app-7fd56c9b89`, with that funky hash showing it’s tied to a specific Pod spec.

**Bonus Tip:** Want to roll back your app to the previous version?

```bash
kubectl rollout undo deployment my-cool-app
```

Because mistakes were made. And Kubernetes understands.

## Update Strategies: Because Downtime is So Last Decade

When your app updates, Kubernetes doesn’t just slam everything shut and hope for the best. It uses **update strategies** to roll things out safely.

### RollingUpdate (Default)

This strategy is like slowly replacing airplane engines mid-flight... and somehow it works.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

- `maxUnavailable: 1` = Only one Pod can be down at a time.
- `maxSurge: 1` = One extra Pod can be spun up temporarily.

#### Use it when:
- Your app can run multiple versions at once.
- You want **zero downtime**.
- Your service can gracefully handle rolling changes.

**Example:** Updating a Node.js REST API from v1.0 to v1.1? `RollingUpdate` is perfect.

### Recreate

This is the “turn it off and on again” strategy.

```yaml
strategy:
  type: Recreate
```

Kubernetes terminates *all* old Pods, then starts new ones. No overlap.

#### Use it when:
- Only **one version of the app** can run at a time.
- Your app uses **exclusive resources** (like a local DB file).
- You’re in dev/test and just want a clean slate.

**Example:** A monolithic app using a SQLite database. You can’t have two instances writing to it. `Recreate` is the way.

## What Happens When You Deploy?

Let’s tie it all together:

1. You create a Deployment.
2. Kubernetes creates a ReplicaSet.
3. ReplicaSet launches Pods based on your template.
4. K8s watches them like a hawk. If a Pod dies, it gets replaced.
5. You update your Deployment - K8s creates a new ReplicaSet and does a rolling update.
6. You drink coffee and take credit.

## Wrapping It Up (Without Wrapping Your Head Around It)

Deployments are your way of telling Kubernetes: “Here’s what I want. Please keep it that way.” And Kubernetes obliges.

**With Deployments, you get:**
- Automated scaling
- Self-healing Pods
- Easy rollbacks
- Safe rolling updates
- More time to do literally anything else

So the next time someone says, *“Just use a Deployment”*, you can smile and say, *“Already did, boss.”*
