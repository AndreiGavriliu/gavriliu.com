---
title: "Kubernetes Pod Affinity and Anti-Affinity: Scheduling With Style"
date: 2025-06-10T03:00:00+02:00
tags: ["kubernetes", "learn", "scheduling"]

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

Imagine Kubernetes as a big party where pods are the guests. Some guests (pods) want to sit together — they’re best friends! Others… well, they’d rather not be anywhere near each other. Kubernetes, being the polite party host it is, lets you manage these social dynamics using Pod Affinity and Pod Anti-Affinity.

## What Is Pod Affinity?

Pod Affinity lets you tell the scheduler: “*Hey, I want my pod to be placed on the same node (or zone) as another pod — they get along.*”

This is useful when pods benefit from being co-located, like sharing local storage or minimizing network latency.

Example: Web + Cache BFFs
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - cache
          topologyKey: "kubernetes.io/hostname"
```

This says:
* “*I want to be scheduled on a node with a pod labeled app: cache.*”
* The `topologyKey` defines the domain — here, it’s the same node.

## What Is Pod Anti-Affinity?

Pod Anti-Affinity is the opposite. It’s telling Kubernetes: “*Please don’t put me near that other pod.*”

This is useful for high availability — for instance, if you don’t want multiple replicas of the same app on one node.

Example: Avoiding Sibling Rivalry
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - backend
          topologyKey: "kubernetes.io/hostname"
```

Now the scheduler will make sure no two backend pods land on the same node.

## Required vs. Preferred

Kubernetes is pretty accommodating. With affinity and anti-affinity, you can say:
* `requiredDuringSchedulingIgnoredDuringExecution`: This must be met during scheduling. But if pods move later, Kubernetes won’t care.
* `preferredDuringSchedulingIgnoredDuringExecution`: A nice-to-have. “*I’d like this… but I won’t throw a tantrum if it doesn’t happen.*”

Example: Soft Affinity
```yaml
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchLabels:
          app: my-app
      topologyKey: "kubernetes.io/hostname"
```

## Topology Keys: Define the Neighborhood

The topologyKey decides how broadly to apply affinity:
* `kubernetes.io/hostname`: Same node
* `topology.kubernetes.io/zone`: Same zone (great for cloud setups)
* Custom keys: If you’re feeling fancy

## Use Cases

1. Keep Pods Together (Pod Affinity)
* Microservices with tight coupling
* Shared memory/cache
* Debugging/logging sidecars

2. Spread Pods Out (Pod Anti-Affinity)
* Replicas of a Deployment
* Fault tolerance
* Minimize noisy neighbors

## Gotchas and Good Practices

* Affinity only applies at scheduling time. Once the pod is scheduled, it can live happily even if affinity is later violated.
* Use anti-affinity for HA across nodes or zones.
* Don’t go wild with required rules unless you’re sure your cluster can satisfy them — or pods may never get scheduled.
* `MatchLabels` vs. `MatchExpressions`: Use whichever suits your label setup.

## A Real-World Scenario

You’re running a distributed cache with multiple replicas:
* You want each replica on a different node (anti-affinity).
* You want your web pods close to a cache pod (affinity).

Apply both rules to your pod specs, and Kubernetes becomes your smart matchmaker.

## Wrapping Up

Pod Affinity and Anti-Affinity let you fine-tune where your workloads land in a Kubernetes cluster. They help with performance, reliability, and fault tolerance — and sometimes just keeping the peace between grumpy pods.

Remember:
* Use required rules carefully
* preferred rules are great for flexibility
* Always test in staging before enforcing in prod

And yes, affinity can be… magnetic.