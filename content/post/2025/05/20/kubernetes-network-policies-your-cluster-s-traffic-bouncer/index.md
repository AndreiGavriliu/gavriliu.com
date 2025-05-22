---
title: "Kubernetes Network Policies: Your Cluster’s Traffic Bouncer"
date: 2025-05-21T03:00:00+02:00
tags: ["kubernetes", "learn", "networking", "security"]

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

## What Are Network Policies?

In Kubernetes, a `NetworkPolicy` is like a bouncer for your pods. It checks who’s allowed to talk to whom and kicks out anything not on the guest list.

By default, Kubernetes is a friendly party where everyone can chat with everyone else—great for sociability, terrible for security. Network Policies let you enforce boundaries, like:

* Only letting frontend pods sweet-talk the backend  
*  Blocking pods from gossiping with the internet  
*  Keeping your top-secret service away from curious neighbors

[Official Docs](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

## Default Behavior: Open Doors

Out of the box, Kubernetes is basically a mosh pit. Every pod can talk to every other pod. No firewalls. No curfews. Chaos.

But the moment you apply a `NetworkPolicy` to a pod, it’s like hiring a security team with a clipboard: only explicitly allowed traffic is permitted. Everything else? Hard no.

---

## A Basic Network Policy Example

Say you want to restrict access to your backend pods so that only frontend pods can call them. Here's how you write that policy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

What this does:

* Allows pods labeled `app: frontend` to talk to pods labeled `app: backend`
* Blocks everything else from talking to those backend pods

If your database tries to get chatty with the backend? Nope. Denied. This policy is all about that frontend-backend duo and nobody else.

## Let’s Talk Egress (Because Your Pod Wants to Talk Too)

Now imagine you have a pod that should only talk to your in-cluster database, and not go surfing the internet for cat memes.

Here’s an egress policy to block all outbound traffic except traffic to a pod labeled app: database:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
  policyTypes:
  - Egress
```

Once applied, your backend pods can no longer egress to the internet, other services, or anything not labeled `app: database`. No more unauthorized outbound traffic.

## Locking It Down: No Ingress, No Egress

Sometimes, you want a pod that’s completely isolated. No calls in. No calls out. Just a digital monk meditating in the corner of your cluster.

Behold:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: complete-isolation
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: hermit
  policyTypes:
  - Ingress
  - Egress
```

No ingress or egress rules are defined, so everything is blocked. This is perfect for honeypots, air-gapped workloads, or that one app you’re just not sure you trust yet.

## Using Namespaces in Policies

Sometimes, you don’t want to define rules by pod label, but by namespace. Maybe your monitoring namespace is allowed to scrape metrics, and nothing else.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: app-space
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          team: monitoring
```

Now pods in the app-space namespace with label app: web will only accept connections from pods in a namespace labeled team: monitoring.

Namespaces = powerful boundaries. Use them wisely.

## Ingress vs. Egress: The TL;DR

| Rule Type | Controls | Default Without Rules | Effect When Rule Exists |
|:---|:---|:---|:---|
| Ingress | Who can talk to your pod | Anyone | Only what’s explicitly allowed |
| Egress | Who your pod can talk to | Anyone | Only what’s explicitly allowed |

Just remember: as soon as you define a rule of one type, it overrides the default. So define them carefully—especially egress, which can break things in wonderfully confusing ways.

## CNI Plugins: The Real Muscle

Kubernetes doesn’t actually enforce these rules itself. That’s the job of your CNI plugin. If your CNI doesn’t support `NetworkPolicy`, then you’re basically writing love letters no one reads.

Here are some CNIs that do enforce Network Policies:
* Calico – Reliable, fast, and popular in production
* Cilium – Uses eBPF for fancy L7 (Layer 7) controls and shiny observability
* Weave Net – Simpler but still policy-aware
* Kube-Router – Not super common, but supports policies too

Before rolling out policies, make sure your cluster is using a policy-aware CNI—or you’ll be left wondering why nothing is being blocked.

## Best Practices (aka “How Not to Break Everything”)
* Start in audit mode: Use network monitoring tools before enforcing anything. Understand the traffic first.
* Label everything: Labels are your friends. Policies without proper labels are like locks with no keys.
* Use namespaces for segmentation: Divide and conquer your traffic.
* Incrementally apply policies: Don’t YOLO a full lockdown. Apply one policy at a time.
* Use visualization tools: Tools like Hubble help you see what your policies are doing.
* Document your intentions: Future-you (and teammates) will thank you.

## Wrapping It Up

Network Policies are Kubernetes’ version of a velvet rope. They keep the right packets in, the wrong packets out, and your cluster just a little bit saner.

Remember:
* Without policies, it’s a free-for-all
* With them, it’s a carefully curated social circle
* They’re only as good as your CNI and your labels

So label thoughtfully, start small, and don’t be afraid to lock it down. Your cluster deserves some boundaries.

No label? No entry.