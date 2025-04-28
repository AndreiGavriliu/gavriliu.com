---
title: "Kubernetes Ingress: Your Cluster's Traffic Director"
date: 2025-05-06T03:00:00+02:00
tags: ["kubernetes", "learn", "ingress"]

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

# series: kubernetes
# showRelatedInArticle:  true
# showRelatedInSidebar: true
---

Your app is running in Kubernetes. Great! But now you want users to actually reach it — without remembering 15 different NodePorts or manually messing with LoadBalancers. Enter the hero we need but rarely understand at first: **Ingress**.

Today, we’re breaking down what Ingresses are, how they work, and how they can route traffic like air traffic controllers on espresso.

---

## What Is an Ingress?

An **Ingress** is a Kubernetes resource that **manages external access** to your services, typically over HTTP(S).

It acts as:

- A smart **router** based on URLs or hostnames
- A **TLS terminator** (offloading HTTPS)
- A single point for **path or domain-based routing**

And the best part? **One external IP** can serve many services.

---

## Ingress vs Ingress Controller

You need to know two key pieces:

| Thing              | What It Does                                                    |
| ------------------ | --------------------------------------------------------------- |
| Ingress Resource   | The *rules* ("route `/api` to service A, `/shop` to B")         |
| Ingress Controller | The *software* that enforces those rules (NGINX, Traefik, etc.) |

An Ingress by itself does **nothing**. It's like writing a menu without a waiter. You need an **Ingress Controller** deployed in your cluster to make it actually work.

---

## A Basic Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
      - path: /shop
        pathType: Prefix
        backend:
          service:
            name: shop-service
            port:
              number: 80
```

What’s happening here?

- Requests to `myapp.example.com/api` get routed to `api-service`
- Requests to `myapp.example.com/shop` get routed to `shop-service`

All through a single Ingress endpoint!

---

## Path-Based vs Host-Based Routing

**Path-based routing** = one domain, many paths:

- `/api`
- `/shop`
- `/blog`

**Host-based routing** = multiple domains:

```yaml
- host: api.example.com
- host: shop.example.com
```

Use whichever fits your app’s vibe — or mix both like a networking ninja.

---

## Adding TLS (HTTPS)

Kubernetes Ingress can also handle **TLS termination**:

```yaml
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: my-tls-secret
```

- `my-tls-secret` contains your TLS certificate and key.
- Now your users get that sweet, sweet padlock in the browser.

(You’re welcome, compliance team.)

---

## Annotations: Special Sauce for Ingress Controllers

Each Ingress Controller may support **annotations** to customize behavior.

Example for NGINX:

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
```

Other cool things you can configure:

- Request timeouts
- Connection limits
- IP whitelisting
- Authentication

Each controller has its own "dialect," so check their docs!

---

## What About IngressClass?

With modern Kubernetes (v1.18+), you should use the `spec.ingressClassName` field to declare which Ingress Controller handles your Ingress.

```yaml
spec:
  ingressClassName: nginx
```

**The old way using annotations (**`kubernetes.io/ingress.class: "nginx"`**) is deprecated!**\
Stick with `ingressClassName` to be future-proof.

---

## Popular Ingress Controllers

- **NGINX Ingress Controller**: The classic
- **Traefik**: Easy, modern, has cool dashboards
- **HAProxy Ingress**: For the performance purists
- **Istio Gateway**: If you’ve gone full service mesh (you brave soul)

Each has pros, cons, and their own tuning knobs.

---

## Quick Visual Recap

```
User --> Ingress Controller --> Ingress Rules --> Service --> Pod
```

- Ingress Controller listens on a public IP
- It reads Ingress resources
- Routes traffic according to the rules

Simple. Beautiful. Sometimes frustrating. (But mostly beautiful.)

---

## Ingress Is Great For:

- Consolidating public endpoints
- HTTPS termination
- Path-based or hostname-based routing
- Reducing LoadBalancers in the cloud (\$\$\$)

---

## Ingress Is *Not* Always the Best Choice For:

| Situation                                 | Why Ingress Might Not Be Ideal                                                                                                                                           | What to Use Instead                                                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Non-HTTP/S traffic**                    | Ingress is designed only for HTTP and HTTPS. It can’t handle raw TCP, UDP, gRPC (without extra config) directly.                                                         | Use a `Service` (type: `LoadBalancer` or `NodePort`), or an Ingress Controller with TCP/UDP support (like Traefik). |
| **Ultra-low-latency needs**               | Ingress adds an extra hop: User → LoadBalancer → Ingress → Service → Pod. For very latency-sensitive apps (e.g., real-time games, financial apps), this can be too slow. | Direct `LoadBalancer` Services (`Service.type: LoadBalancer`) or HostNetwork deployments.                           |
| **Quick external exposure of non-HTTP/S** | If you just want to quickly expose a database, SSH, MQTT broker, or other TCP/UDP service, Ingress won't help.                                                           | Use `Service.type: LoadBalancer` if your cloud provider supports it, or manually assign `externalIPs` on a Service. |
| **Very simple local dev clusters**        | Setting up Ingress Controllers locally (like on minikube, kind) can be extra work. Sometimes a `NodePort` is easier.                                                     | Use `Service.type: NodePort` in dev for fast local access.                                                          |

### Quick Tip About Services

- **NodePort**: Opens a port on every node. Access at `<node IP>:<nodePort>`.
- **LoadBalancer**: Automatically gets a public IP (in the cloud).
- **ExternalIPs**: Manually expose services (common in bare metal setups).
- **HostNetwork**: Pods share the host's network stack. Careful with security!

---

## Wrapping It Up

Ingress is the Kubernetes way to **bring order to the networking chaos**. It:

- Routes traffic like a boss
- Terminates TLS like a pro
- Consolidates access points
- Saves you from spinning up 47 LoadBalancers and explaining your cloud bill

Just remember: Ingress resources need a Controller. Choose wisely. Configure thoughtfully. And maybe add a TLS certificate so your users don't panic.

Because when your apps are live, your routing rules shouldn’t just exist — they should **slay**.

