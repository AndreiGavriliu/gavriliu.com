---
title: "Kubernetes Endpoints & EndpointSlices: Who’s Really Behind That Service?"
date: 2025-05-27T03:00:00+02:00
tags: ["kubernetes", "learn", "networking"]

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

## What Are Endpoints?

Ever wondered how a `Service` in Kubernetes actually knows which pods to forward traffic to? Enter the **Endpoint**, Kubernetes’ behind-the-scenes phonebook.

When you create a `Service`, Kubernetes auto-generates an `Endpoint` object. It’s a simple list of pod IPs and ports that match the `Service`’s selector. Basically:

> “Hey Service X, your pods are at 10.42.0.12:8080 and 10.42.0.15:8080. Go get ‘em, tiger.”

You can check them out with:

```bash
kubectl get endpoints
```

Or the cooler kids do:

```bash
kubectl describe endpoints my-service
```

But wait—there’s a plot twist.

## The EndpointSlice Era Has Begun

`Endpoints` were fine… until they weren’t. They hit scaling issues. Imagine having thousands of pods—Kubernetes would cram them all into one giant `Endpoint` object. That’s a lot of YAML for one API call.

So Kubernetes introduced **EndpointSlices** in v1.17, and they became the default in v1.21. They break up those massive lists into smaller, manageable chunks.

Think of it like this:

- **Endpoints**: A party guest list scribbled on a napkin  
- **EndpointSlices**: Alphabetized spreadsheets with tabs, filters, and color-coding

## What’s Inside an EndpointSlice?

An `EndpointSlice` contains:

- A list of **endpoints** (IP + port)
- Their **conditions** (e.g., is the pod ready?)
- Metadata like **hostname**, **nodeName**, and **topology**
- Ports and protocols (TCP/UDP/SCTP — Kubernetes doesn’t judge)

```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-abc123
  labels:
    kubernetes.io/service-name: my-service
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 8080
endpoints:
  - addresses:
      - 10.42.0.12
    conditions:
      ready: true
    nodeName: node-1
    topology:
      zone: us-west1-a
```

Pro tip: If you’re using headless Services (`ClusterIP: None`), the EndpointSlice is your DNS source of truth.

## Comparing Endpoints vs. EndpointSlices

| Feature             | Endpoints                  | EndpointSlices              |
|---------------------|----------------------------|-----------------------------|
| Scale               | Struggles beyond ~100 pods | Scales to thousands of pods |
| API Version         | `v1`                       | `discovery.k8s.io/v1`       |
| Default in v1.21+   | no                         | yes                         |
| Grouped by port/IP  | All in one                 | Sliced by 100 endpoints max |
| Extensible metadata | Basic                      | Rich (conditions, topology) |

So yeah, EndpointSlices are the cool, scalable, modern replacement. But don’t worry—your `kubectl get endpoints` still works. Kubernetes quietly builds the `Endpoints` object *from* the EndpointSlices for backward compatibility.

Like a polite butler translating your outdated commands into the new API.

## Debugging: Who’s Behind the Service?

If you’re wondering *which pods* your Service actually targets:

```bash
kubectl get endpoints my-service -o yaml
```

Or go full slice-mode:

```bash
kubectl get endpointslices -l kubernetes.io/service-name=my-service -o yaml
```

This gives you a peek behind the curtain. You’ll see the actual IPs that the Service routes to, which is super handy when something breaks and you want to blame DNS (but it’s actually your selector).

## Advanced Example: Headless Service with StatefulSet

Headless Services (`ClusterIP: None`) let each pod in a StatefulSet get its own DNS record. That’s useful for databases like Cassandra, RabbitMQ, or anyone who hates load balancers.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-db
spec:
  clusterIP: None
  selector:
    app: my-db
  ports:
  - port: 9042
    name: cql
```

Combined with a StatefulSet, you get stable DNS like: `my-db-0.my-db.default.svc.cluster.local`

And yes, EndpointSlices make this possible.

## When Things Go Weird

Sometimes you have a Service, but the Endpoints are… empty.

No IPs! Just vibes.

Common causes:

- The selector doesn’t match any pod labels  
- The pods aren’t `Ready`  
- You’re using a headless Service and didn’t configure DNS properly  
- The network plugin (CNI) is misbehaving  
- The Service and pods are in different namespaces (rookie mistake, we’ve all been there)

Use `kubectl describe service my-service` and `kubectl get pods --show-labels` to troubleshoot.

## Best Practices

- **Don’t touch Endpoints manually**: They’re auto-generated. Editing them is like editing `/proc`: mostly a bad idea.
- **Use labels wisely**: Services live and die by their selectors.
- **Use readiness probes**: Kubernetes won’t route traffic to a pod unless it’s `Ready`. No probe = no traffic.
- **Headless Services + StatefulSets = ❤️**: Want stable DNS for individual pods? Use `ClusterIP: None` with StatefulSets and enjoy DNS like `web-0.my-service`.
- **Use `kubectl get endpointslices` for clarity**: It’s the future. Embrace it.

## Wrapping It Up

Endpoints and EndpointSlices are the invisible magic behind every Kubernetes Service. They keep traffic flowing to the right pods, even as your cluster scales or reshuffles.

**TL;DR**:

- **Endpoints** are the OGs—still around, but slowly being phased out  
- **EndpointSlices** are the scalable future  
- Kubernetes maintains both for compatibility, but you should understand slices  
- Don’t forget to check them when debugging—services aren’t psychic

So next time you hit your `Service` and it works, thank your Endpoints. Or better yet, thank your EndpointSlices—they’re doing most of the heavy lifting now.

Because behind every good Service is a slice... or two.
