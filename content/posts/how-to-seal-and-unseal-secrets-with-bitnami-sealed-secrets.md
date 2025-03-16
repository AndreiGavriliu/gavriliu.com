+++
title = "How to seal and unseal secrets with Bitnami Sealed-Secrets"
date = "2025-03-14T16:41:25+01:00"
cover = ""
tags = ["bitnami", "sealed-secrets", "security"]
keywords = ["", ""]
description = ""
showFullContent = false
readingTime = false
hideComments = false
+++

I decided to push my Kubernetes manifests to GitHub because running Git locally on the same k3s cluster as ArgoCD seemed like asking for trouble. I mean, what happens if something goes wrong? Suddenly, you’re locked out of your repository, and your applications just sit there looking sad, like ‘Hey, I need a home!’ Pushing everything - including secrets — straight to GitHub? That’s like sending your passwords in a postcard: ‘Hey, here’s all my private stuff for the world to see!’ So, I decided to use Bitnami’s Sealed Secrets. At least now, my secrets are sealed tighter than my New Year’s resolution to work out!

## What is Bitnami’s Sealed Secrets?

> **Problem**: "I can manage all my K8s config in git, except Secrets."\
**Solution**: Encrypt your Secret into a SealedSecret, which is safe to store - even inside a public repository. The SealedSecret can be decrypted only by the controller running in the target cluster and nobody else (not even the original author) is able to obtain the original Secret from the SealedSecret. (from the official [project's GitHub Repository](https://github.com/bitnami-labs/sealed-secrets))

You might be wondering what it actually looks like

## How to seal secrets

### Sensitive information

For instance, if you need to seal the following credentials:

* `POSTGRES_HOST`: `10.20.1.45`
* `POSTGRES_PORT`: `5432`
* `POSTGRES_DB`: `fbi_undercover_agents`
* `POSTGRES_USER`: `admin`
* `POSTGRES_PASSWORD`: `superSecr3tPassw0rd`

### Create a secret

The values of each key in `secret.yaml` must be base64 encoded

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: fbi-agents
  namespace: fbi
data:
  POSTGRES_HOST: MTAuMjAuMS40NQ==
  POSTGRES_PORT: NTQzMg==
  POSTGRES_DB: ZmJpX3VuZGVyY292ZXJfYWdlbnRz
  POSTGRES_USER: YWRtaW4=
  POSTGRES_PASSWORD: c3VwZXJTZWNyM3RQYXNzdzByZA==
```

### Seal the secret

```bash
$ cat secret.yaml | kubeseal \
    --controller-name=sealed-secrets \
    --controller-namespace=sealed-secrets \
    --format=yaml \
    --scope=cluster-wide > sealed-secret.yaml
```

* `--controller-name`: Name of sealed-secrets controller. (default "sealed-secrets-controller"). Since I installed via helm, the controller name is `sealed-secrets`
* `--controller-namespace`: Namespace of sealed-secrets controller. (default "kube-system")
* `--format`: Output format for sealed secret. Either json or yaml (default "json")
* `--scope`: Set the scope of the sealed secret: `strict`, `namespace-wide`, `cluster-wide` (defaults to `strict`). Mandatory for `--raw`, otherwise the `sealedsecrets.bitnami.com/cluster-wide` and `sealedsecrets.bitnami.com/namespace-wide` annotations on the input secret can be used to select the scope. (default `strict`)

This generates the file `sealed-secret.yaml`

### Check the sealed secret file

Check `metadata.name`, `metadata.namespace`, `spec.template.metadata.name` and `spec.template.metadata.namespace` are correct. Ensure these match your intended Secret deployment to avoid issues when applying the SealedSecret

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  annotations:
    sealedsecrets.bitnami.com/cluster-wide: "true"
  creationTimestamp: null
  name: fbi-agents
  namespace: fbi
spec:
  encryptedData:
    POSTGRES_DB: AgCimSDyG7/fDlP9f6lLjr1iVfL2UDcOYsrdkGAUipqIMO+Nd9/aVokfWVveKqAmF0ZFx1tDp2BO8YGv54A7oJVKCiLE3EYVMcsAa76Q3IrUtfbY3Qp5Kk9dLP0IuDn8zykZqpG4RSYqC4ZT+9hnaPRDp+BoeQysJJEoL5txyr/b39LbkUXmH/fuwbHT8ZmYZ7p1wkBxRVKL6vXnqO0GEYi9X8wxBw2ptQuvrt/JD9VUPByLoJTvqLXMfkGcnJ3Is6l5S54vU5Z9HQIodVSVBI34o1WUcP48K1Kj96MXvJ2UgremjmgNgFmrpc0T2cLsIIMAPhWj8g2KTDy2aB5zW2P48wVNW7Uu0foAP9rXgybPexSSA52Vv06ZYwED9zzVQJvvZlAt0Q78+7goB8MzlsU31R4LDs2FcKV1uxATKau+CKe+kKhAN/GBI+vLaLFHdmVIDdmNT3jIapoY00iFL9Xcrv7GdecWrMrov3ZC2co//1E2eZnb+aX71Jl9riYCNXP7J/TXlGc+LcQ4RPxQyWfJ8/r83MipMTfB+iqUjuvOTgVE/5Qf2HtU/1HPWOHgmGJTmiglyRYeLLzug45NBTeFimcIX/2JwqTJwF/sHcdqwu/iotNHNmYf1O/vbjIeWgHFVX8DqtZ/j/0G6zTWPBdEE0tcuKwwvGwYzhcQgj4SjVb9NoYpzkXZXH/p2NXHSnIIBcEynwsNphx71Q9FjtEkGCax5OQ=
    POSTGRES_HOST: AgBQFZiZaZCeRVzWqAqOaxGuoSRAGPHmITd6XvW5K0NTvA8ZE+yrheKK4sQHS7htQQeFzBOEz99GrRxNLmhQbMDgA0GGd7qCm/kGsVEpNcf8C8yJ6KzRlCCyQdP9PcOIjwAvPxpisGJvStobcsxQXl9VWlCh/4VpkWED7JYJh8TlYd0XaXMR2i+6Q581C3cVPUH0V07EUPiPxstI4w18l8HqAfFqKZiT+uk9EsVXl/IPOqg9Dxg/SksrWuY7EP3R1lrubzQr+RM02LInw5cLh6iX9x3ZNiuF3BbnKKDgA5/tT1+qOP4bljE2JwHMOdo1oJZnrvw2ny4/x9nKOzkAa8KjogSTdFonDnlBV0bRXZ4G3RSZPNcp9l2TG5Q7itZNX1WcOMa+o5OJQUsVf6Y6aSTr+QB1LxeCk8tASPsu1HnaZSSzECr3fxMJ1gDRz6l8SFHLM9XQ0j9MN6QrnNSmWOUWnhAsa22uX+nYM43jGm6oELrlXo/fNLn0oPuY2xaKpO+5YNZ3AM+xGFFioPs+e2Hl+gBsXwY4ZmEou7vZ5/mSIVuTMBkmedi/sdhfpYmOwhVXfqsVa7Rh+ov6Ab6zOEC+xEnVmyxclesEY7wHonCNK4M4YiIXQalHo1M0mi4q78HvvXrOSzmqqRWBg3V8R8mwhypgg1aIgkx7Jti1HRqvXb9hg2rFU+R+fx3vnravYmNO4mt3ePs274GZ
    POSTGRES_PASSWORD: AgCEGEVwbWu4GeNgqJDWPO+XgdsMj5j5vMguARiMLFIEz3asEqETItVqMoY+TaF4Cb0jQ51SuhpQYQwy/0LBJbriy9Nj/YxHEBg9q2M11kkd15S4Lwrnan44PiLKYwLjkpM5GkzHek60eT56MxeT2O4gX9muGfYvRle5W71eGba2JMktu8ERXnMStulOUf0Oqfx4DCD7YRgvhsdlFqBMLs9uAcefrXkWjXKuyJhkIdFJBIS9JLjbw68DyQXPWmwHTAbhXWetKIQHYAe+Yr//VZUolAfeqb7xW2NwcLr5WKrdbk9fHgxWKUwPP6KpcmlF2MlwJbntEzOF6ZYBy9IY1Gw4XEu+4ayT8KXYTK8y1gXzBgbFUINs0YNlJoxK7XMIcTj3gBCpg2e4cPHolBpi7bGhAuHJ5vh7d9HZ4KhhxXqcbQ6cin/V5zEK91okpFUyBtiZphlFWJTcgwnaqGbvuCTuh7XHYTEUKWaE+1ha4PV0qLqHzz9d6P2/lobYZyJ+xsczwrdaUyKz7/WgHlDk4Y/xy79ZL9xIOTyUYymEwrzgO2mSN3PAof87ryTM49cpQZd25BxtSa1Y/asYmd6FrpHdaQmxMndAPATugSp4t3XJoKpCVn7+JN4K5dEawAqJyKVqoB/8URcjHnPcgx/Fp4LOJ919WvmR/+wZpjx3eFnOC/+QOqE3H/DzPVhVwsOOUWWbktS2rHM0afy8YATqRI6W8Eja
    POSTGRES_PORT: AgAOH0MigGUSP2Dh88jMdLV0aFURvlYNM9OChDHCeZSSELa0vnAR7f4rAMLQhO00EupMZj+EcVozXTY2ZoB8u1PKC0/WxjoHTvzHARwFHGMW/SjZFw4YXsBP8lIcFz0aHIHQcGE/vkF0KYPOgH3Gi9r7x3zT8bpHaDrSWtgcsw2Ijzx5bidBcvuGIPfi4R6bMrZxBhz1F+/AY360IVRwXxluCVoXmb+2X2Bp01XqAk2f6fh4dQDz9G+kDyvV7O0eW5KxLqmYHME+AzpEq+M7zE1xlPzE6vb1TB7DOJBBeeejGu/Iq3Yx26D8jAoSAMHsj4kPKEiYTwYZ0mbq6H789MYnnn/PIOkPHqo/2i6lHwJbxoAkGzIkBI6wKZGP5um1PCJFJv2n2DPMEDsTlxkL8j1l0TI607R00jJ5gc7f7Czepi+BXhyadn+wbnmEu/7yAEO13uKNa8M4DKcKUzuTFg/PghjLjK8PnUw14NdAcP8XjEvWtqtjo4QkPFsalAUmvEYZEODol0DiaG0jT50d8IYgXp6Hx5qlC1L1g0p3xPrO6QH8BVda8h/NePISB4rBo/PmQgvz1GyTRSgs14stt1RsjNAKzpNBACysCY0+MNpeAsqg8bLsGkBcl7bfac5HdrY45fR4lS6dIDLlLbW6htEWwBlDeOPX3HznSnnxDvf2ywdakpMzVLsLVII9qmcgDf4riTNo
    POSTGRES_USER: AgBC8nVi5UKfNCOzMnzGm1GPafXu2TgAYHqlEfCyHD5DA8btqX8dWpbJehUuXhG39qJnrZe/f3vUwpUIWfgTma2+HUfBz71cyUgrrcvY0HczAvzqs8pz34KjeuZF5GD64rkcWgc0aP663F8ANGsFklsq3fsHzY2xH3dFiKukH6b2jLcitwfrhm55JcUtmnHfeGqwMYSj3MXwf49f07E84zdFH5PgImUOoA4KgzdlcnBzzyqutjSF8omTbTcAq4nmjO8Qa3+pN+gjxU5B2ATC6mtYdfO87DXEG60SasnTsWcS9vR9AKH8CpUX1VR/Q72KyJf5DNCSZsXUVm9kag6RC4KAH3P7xUX5OTlTHZkZsGUi0jI7wP6QtxSdQK9E8t7fHuvlBd7oEwdFYo6gOlLFanO8vHbGE1ZeJSYg3Fhl+bCevXnPRBU7xrqhnvg7VG/Ek9ctmjZHGGen/XrDa7cMpExjjVPuW6Ax+MFQmB+tryHwxDSJ0VTzFbax4yJK84iyvqmxai5xdedetAI6ZbQqcCZx/Hn8QfaKLAObEruA2ryBmyOIbo7Ymx5TLb0E8ZaAoPqW3Joa3dBd+OMhCEGZ0ts0CXKqBaIEEPs6rdz78afCd2WAFcCNJgT+KH596Z5OEfg9q3nD/Gs+WN4HKy+M20CkPo19kQlbcnIpTLNY5oSRGJSpvn9lovYvp6kN8ZQnlKtBmaDJfA==
  template:
    metadata:
      annotations:
        sealedsecrets.bitnami.com/cluster-wide: "true"
      creationTimestamp: null
      name: fbi-agents
      namespace: fbi
```

## How to unseal secrets

### Download sealed secret key
```bash
$ kubectl get secret \
    -n sealed-secrets \
    -l sealedsecrets.bitnami.com/sealed-secrets-key<uniqueId> \
    -o yaml > sealed-secrets-key.yaml
```

### Unseal secret using downloaded key
```bash
$ kubeseal --controller-name=sealed-secrets \
    --controller-namespace=sealed-secrets < sealed-secret.yaml \
    --recovery-unseal \
    --recovery-private-key=sealed-secrets-key -o yaml
```
