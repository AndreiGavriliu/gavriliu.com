---
title: "Kubernetes Ingress: 7 Common Mistakes (and How to Avoid Them)"
date: 2025-05-13T03:00:00+02:00
tags: ["kubernetes", "learn", "ingress"]

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

You've finally tamed Kubernetes Ingress — or so you think. Then weird routing errors, downtime, and mysterious 404s show up. Welcome to the club! 🎩

Let's save you some headaches. Here are **7 common Kubernetes Ingress mistakes**, how they happen, and how to dodge them like a pro.

---

## Quick Mistakes Checklist

| Mistake | Symptom | Quick Fix |
|:---|:---|:---|
| No Ingress Controller | No traffic reaching apps | Install a controller (NGINX, Traefik, etc.) |
| Mixing Path and Host | Wrong backend routing | Match host **then** path properly |
| Missing PathType | Paths don't match | Set `pathType: Prefix` or `Exact` |
| TLS Failures | HTTPS broken | Create & reference correct TLS Secret |
| Missing IngressClass | Ingress ignored | Set `spec.ingressClassName` |
| Backend Service Issues | 502/503 errors | Verify Service names, ports, selectors |
| Health Check Problems | 504 Gateway Timeout | Add `/health`, tune timeouts |

---

### Forgetting to Deploy an Ingress Controller

**Symptom:**
- Your Ingress resource is happily created... but no traffic ever reaches your app.

**Why:**
- Ingress **needs a controller** (like NGINX, Traefik, HAProxy).
- Kubernetes doesn't come with one by default.

**How to Avoid:**
- Install an Ingress Controller manually.
- Use something like:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

- Make sure it’s running and ready.

**Pro Tip:** If you see `no matches for kind "Ingress"`, check your controller is alive.

---

### Mixing Up Path vs Host Routing

**Symptom:**
- Traffic goes to the wrong backend.

**Why:**
- Forgetting that Ingress matches **hosts first**, **then paths**.

**How to Avoid:**
- Know the flow:
  1. Match `host`
  2. Then match `path`

- Example:

```yaml
- host: api.example.com
  path: /
- host: shop.example.com
  path: /cart
```

**Wrong:** expecting `/cart` at `api.example.com` to route!

**Right:** set both host and path carefully.

---

### Ignoring PathType

**Symptom:**
- Ingress works on some URLs but not others.

**Why:**
- Kubernetes **requires `pathType`** (since v1.18+).
- Defaults aren't what you expect.

**How to Avoid:**

Set your pathType!

```yaml
pathType: Prefix
```

Options:
- `Prefix`: Match any path starting with `/foo`
- `Exact`: Match exactly `/foo`
- `ImplementationSpecific`: (aka Controller decides — spooky)

Prefer `Prefix` unless you love surprises.

---

### TLS Configuration Failures

**Symptom:**
- HTTPS connections fail. Browser shows "Connection not secure."

**Why:**
- Missing or invalid TLS secret.
- Wrong secret name.
- Controller not picking it up.

**How to Avoid:**
- Create your TLS secret:

```bash
kubectl create secret tls my-tls-secret --cert=cert.pem --key=key.pem
```

- Reference it properly:

```yaml
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: my-tls-secret
```

**Checklist:**
- Secret in the **same namespace** as the Ingress!
- Correct secret name.
- Controller supports TLS (NGINX, Traefik do).

---

### Wrong or Missing IngressClass

**Symptom:**
- Ingress resource is ignored.

**Why:**
- Kubernetes 1.18+ uses `spec.ingressClassName` to match Controllers.
- If it doesn’t match, your Ingress won’t be picked up.

**How to Avoid:**
- Set it explicitly:

```yaml
spec:
  ingressClassName: nginx
```

- Match whatever your Controller reports as `IngressClass`.

You can check installed classes:
```bash
kubectl get ingressclass
```

---

### Incorrect Backend Service Configuration

**Symptom:**
- Ingress routes traffic but you get 502/503 errors.

**Why:**
- Ingress is fine, but the **Service** points to nowhere.
- Wrong service name or port.

**How to Avoid:**
- Double-check backend services.

Example:

```yaml
backend:
  service:
    name: api-service
    port:
      number: 80
```

- Service must exist.
- Service must target Pods correctly (selectors right).

**Debug Tip:**
- Check your service endpoints:
```bash
kubectl get endpoints
```
- If it's empty, your Pods don't match.

---

### Overlooking Health Checks

**Symptom:**
- Random 504 Gateway Timeouts.

**Why:**
- Ingress Controllers perform health checks on Services.
- If your app doesn’t respond fast enough, it’s marked unhealthy.

**How to Avoid:**
- Make sure your app is ready!
- Expose health endpoints (`/health`, `/readyz`)
- Tune Controller's timeout settings via annotations:

Example for NGINX:

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "30"
```


---

## Bonus: Pro Moves

- **Version mismatch:** Check your Ingress resource version (`networking.k8s.io/v1`)!
- **Custom error pages:** Many Controllers allow custom 404/503 pages. Nice for UX.
- **Rate limiting:** Protect your services from abuse with Controller-specific options.


---

## Wrapping Up

Kubernetes Ingress is powerful but a little... temperamental. 😉

Avoid these 7 common mistakes and your cluster will reward you with:
- Faster deployments
- Cleaner networking
- Happier users (and fewer 2 a.m. calls)

You got this!