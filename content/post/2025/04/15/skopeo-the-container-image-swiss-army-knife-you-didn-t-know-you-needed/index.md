---
title: "Skopeo: The Container Image Swiss Army Knife You Didn't Know You Needed"
date: 2025-04-15T15:44:57+02:00
tags: ["kubernetes", "skopeo", "images", "gpg"]

showShare: false
showReadTime: true
usePageBundles: true
toc: true
draft: false

usePageBundles: false
---

Ever found yourself needing to peek inside a container image without the hassle of pulling it? Or perhaps you wished for a smoother way to transfer images between registries without the Docker daemon breathing down your neck? Enter Skopeo — the command-line tool that lets you inspect, copy, and even sign container images, all without the need for a local container runtime.

## Installing Skopeo

* macOS (via Homebrew)
```bash
brew install skopeo
```

* Ubuntu
```bash
sudo apt install skopeo
```
For other distributions and detailed instructions, refer to the [official installation guide](https://github.com/containers/skopeo/blob/main/install.md).

## Inspecting Images Without Pulling

Curious about what’s inside an image but don’t want to download it? Skopeo’s inspect command has you covered:

```bash
skopeo inspect docker://docker.io/library/nginx:latest
```

This command fetches metadata like layers, digests, and labels directly from the registry, saving you time and bandwidth. It’s like having X-ray vision for container images!

When using skopeo inspect on macOS, you might encounter the following error:

```bash
FATA[0001] Error parsing manifest for image: choosing image instance: no image found in image index for architecture "arm64", variant "v8", OS "darwin"
```

This occurs because the image you’re inspecting is a multi-architecture (multi-arch) image, and it doesn’t include a variant compatible with your system’s architecture and operating system. Skopeo attempts to select the appropriate image variant based on your current platform, and if it doesn’t find a match, it throws this error.

```bash
skopeo inspect \
  --override-arch amd64 \
  --override-os linux \
  docker://docker.io/library/nginx:latest
```

This command tells Skopeo to inspect the amd64 architecture variant for the linux operating system, bypassing the default behavior of matching your current platform.

```json
{
    "Name": "docker.io/library/nginx",
    "Digest": "sha256:09369da6b10306312cd908661320086bf87fbae1b6b0c49a1f50ba531fef2eab",
    "RepoTags": [
        "1",
        "1-alpine",
        "1-alpine-otel",
        "1-alpine-perl",
        "1-alpine-slim",
        "1-alpine3.17",
        "1-alpine3.17-perl",
        "1-alpine3.17-slim",
        ...
        "stable-bookworm",
        "stable-bookworm-otel",
        "stable-bookworm-perl",
        "stable-bullseye",
        "stable-bullseye-perl",
        "stable-otel",
        "stable-perl"
    ],
    "Created": "2025-02-05T21:27:16Z",
    "DockerVersion": "",
    "Labels": {
        "maintainer": "NGINX Docker Maintainers \u003cdocker-maint@nginx.com\u003e"
    },
    "Architecture": "amd64",
    "Os": "linux",
    "Layers": [
        "sha256:8a628cdd7ccc83e90e5a95888fcb0ec24b991141176c515ad101f12d6433eb96",
        "sha256:75b6425929919354127c44985ea613fa508df8d80dbd1beafeb629400efb7541",
        "sha256:553c8756fd6670dc339ab500b042fe404386f114673f9c8af8dff3c6ade96cc7",
        "sha256:10fe6d2248e3ac5eab320a5c240e1aabfb0249d7b4b438b136633a8cbdc2190f",
        "sha256:3b6e18ae4ce61fa7b74c27a0b077d76bd53699d7e55b9e6a438c62282c0153e7",
        "sha256:3dce86e3b08256a60ab97ef86944f0c2a1e5c90a2df7806043c9969decfd82e8",
        "sha256:e81a6b82cf648bedba69393d4a1c09839203d02587537c8c9a7703c01b37af49"
    ],
    "LayersData": [
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:8a628cdd7ccc83e90e5a95888fcb0ec24b991141176c515ad101f12d6433eb96",
            "Size": 28227259,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:75b6425929919354127c44985ea613fa508df8d80dbd1beafeb629400efb7541",
            "Size": 43954583,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:553c8756fd6670dc339ab500b042fe404386f114673f9c8af8dff3c6ade96cc7",
            "Size": 626,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:10fe6d2248e3ac5eab320a5c240e1aabfb0249d7b4b438b136633a8cbdc2190f",
            "Size": 952,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:3b6e18ae4ce61fa7b74c27a0b077d76bd53699d7e55b9e6a438c62282c0153e7",
            "Size": 399,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:3dce86e3b08256a60ab97ef86944f0c2a1e5c90a2df7806043c9969decfd82e8",
            "Size": 1210,
            "Annotations": null
        },
        {
            "MIMEType": "application/vnd.oci.image.layer.v1.tar+gzip",
            "Digest": "sha256:e81a6b82cf648bedba69393d4a1c09839203d02587537c8c9a7703c01b37af49",
            "Size": 1400,
            "Annotations": null
        }
    ],
    "Env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        "NGINX_VERSION=1.27.4",
        "NJS_VERSION=0.8.9",
        "NJS_RELEASE=1~bookworm",
        "PKG_RELEASE=1~bookworm",
        "DYNPKG_RELEASE=1~bookworm"
    ]
}
```

Alternatively, if you want to view all available architecture variants for a multi-arch image, you can use the --raw flag to output the raw manifest:

```bash
skopeo inspect \
  --raw docker://docker.io/library/nginx:latest | jq
```

```json
{
  "manifests": [
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "amd64",
        "org.opencontainers.image.base.digest": "sha256:4b44499bc2a6c78d726f3b281e6798009c0ae1f034b0bfaf6a227147dcff928b",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:45:51Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:b6653fca400812e81569f9be762ae315db685bc30b12ddcdc8616c63a227d3ca",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      },
      "size": 2295
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "amd64",
        "vnd.docker.reference.digest": "sha256:b6653fca400812e81569f9be762ae315db685bc30b12ddcdc8616c63a227d3ca",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:1fe8bc57e04d3add4c87bbc14f91569f392481a994ea47fc03b030a962a8a851",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm32v5",
        "org.opencontainers.image.base.digest": "sha256:bf7ee0e80bc3f33bb693584818c1125cc4e6f1a2e12abfac2dd5fe3a0e0b9e73",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:52:17Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:4bcba87eadc6ebb7b51ece2dadfb5493b1616ed5663cbfc6ac30e67dafabc44e",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v5"
      },
      "size": 2297
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm32v5",
        "vnd.docker.reference.digest": "sha256:4bcba87eadc6ebb7b51ece2dadfb5493b1616ed5663cbfc6ac30e67dafabc44e",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:e4b798256413dfb7b3b8c88d68d4b26b6c9e89e12c73059c9e01c8ef8645c3a3",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm32v7",
        "org.opencontainers.image.base.digest": "sha256:8ba74c566fcc810a50be428d44244c386d27cb93c055480fca8c3f9acf002d08",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:51:32Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:c50e8278e3d30be67e18be5cdf97280376dc90faf2b94ff99a214576aa7f6cd5",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "arm",
        "os": "linux",
        "variant": "v7"
      },
      "size": 2297
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm32v7",
        "vnd.docker.reference.digest": "sha256:c50e8278e3d30be67e18be5cdf97280376dc90faf2b94ff99a214576aa7f6cd5",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:fa8430d8826ed2d8107cca23a3246e7acc3d2b99369f5e6a66585447c2cf76e9",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm64v8",
        "org.opencontainers.image.base.digest": "sha256:912d8a461ca5f85380a40de97d7b38dfcc39972de210518de07136126dd0bfa9",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T02:15:21Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:846993cfd1ec2f814d7f3cfdc8df7aa67ecfe6ab233fd990c82d34eea47beb8e",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "arm64",
        "os": "linux",
        "variant": "v8"
      },
      "size": 2297
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "arm64v8",
        "vnd.docker.reference.digest": "sha256:846993cfd1ec2f814d7f3cfdc8df7aa67ecfe6ab233fd990c82d34eea47beb8e",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:41e936c6bb4d3fbcb5e0fd33db5287a78b5f6df40c455b0d9ed7337cd51cf209",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "i386",
        "org.opencontainers.image.base.digest": "sha256:546fc136c89a1b0554689e33bfe000687048faddee5157844b374acc03d773fd",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:11:42Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:31eefa9ba775ea648b8e5b9bd8ea834f3f0c86dbfb8513d34d6d6ae0645cc178",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "386",
        "os": "linux"
      },
      "size": 2294
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "i386",
        "vnd.docker.reference.digest": "sha256:31eefa9ba775ea648b8e5b9bd8ea834f3f0c86dbfb8513d34d6d6ae0645cc178",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:db10be2e0d2af5e97a58bf4317cc1534734f9aaf5c3bf071cf9fb0ec7b7c8a87",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "mips64le",
        "org.opencontainers.image.base.digest": "sha256:32127f41084d3360f90315ef0c7c0deb43c73ee02382035c35ce978dad94b35d",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T02:21:58Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:4a2475325e9bfd3afe7072826692a96265d3f8d21998f2053c1cfa4cb10ead7b",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "mips64le",
        "os": "linux"
      },
      "size": 2298
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "mips64le",
        "vnd.docker.reference.digest": "sha256:4a2475325e9bfd3afe7072826692a96265d3f8d21998f2053c1cfa4cb10ead7b",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:291f0ff112d6349f8e911e085ec08fd8573fd7cd2efe786dce2e2ec12edaa221",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 567
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "ppc64le",
        "org.opencontainers.image.base.digest": "sha256:6d08d69167c094bb6f76c99167391ff6c35ee237eb48f2e3ea7fdb65608ce4d2",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:48:12Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:fddb0f09b70b961b484c8694006384c04e245b4f8c35f28cc1e93ac89b34869d",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "ppc64le",
        "os": "linux"
      },
      "size": 2297
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "ppc64le",
        "vnd.docker.reference.digest": "sha256:fddb0f09b70b961b484c8694006384c04e245b4f8c35f28cc1e93ac89b34869d",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:634af8de5bdf18b1f6ff5614a6cc7a082d2390efa28f99f1dae67cab60713288",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "s390x",
        "org.opencontainers.image.base.digest": "sha256:604d86fd7ef6bb1e6dc5709e4149cb81953d5f006aa41f376aef84c7f152f332",
        "org.opencontainers.image.base.name": "debian:bookworm-slim",
        "org.opencontainers.image.created": "2025-04-08T01:48:17Z",
        "org.opencontainers.image.revision": "cffeb933620093bc0c08c0b28c3d5cbaec79d729",
        "org.opencontainers.image.source": "https://github.com/nginxinc/docker-nginx.git#cffeb933620093bc0c08c0b28c3d5cbaec79d729:mainline/debian",
        "org.opencontainers.image.url": "https://hub.docker.com/_/nginx",
        "org.opencontainers.image.version": "1.27.4"
      },
      "digest": "sha256:a99b7d9812dbb7527eab8161807e879c3e66951ddccf21c5302061a651289da6",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "s390x",
        "os": "linux"
      },
      "size": 2295
    },
    {
      "annotations": {
        "com.docker.official-images.bashbrew.arch": "s390x",
        "vnd.docker.reference.digest": "sha256:a99b7d9812dbb7527eab8161807e879c3e66951ddccf21c5302061a651289da6",
        "vnd.docker.reference.type": "attestation-manifest"
      },
      "digest": "sha256:a1e6f44bc7da1981130e18b36c1429d2a436a068642853d67ba36eaab952a2c6",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "platform": {
        "architecture": "unknown",
        "os": "unknown"
      },
      "size": 841
    }
  ],
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "schemaVersion": 2
}
```

This will display the manifest list, including all supported architectures and operating systems for the image.  ￼

By using these options, you can effectively inspect and work with multi-architecture images, even when your current platform isn’t directly supported by the image’s manifest.

## Copying Images Between Registries

Transferring images between registries can be a chore, especially when dealing with authentication and different formats. Skopeo simplifies this process:

```bash
skopeo copy \
  docker://source.registry.com/myimage:latest \
  docker://destination.registry.com/myimage:latest
```

Need to handle credentials? No problem:

```bash
skopeo copy \
  --dest-creds user:password \
  docker://source.registry.com/myimage:latest \
  docker://destination.registry.com/myimage:latest
```

You might need to check other authentication flags depending on your setup.

## Signing Images for Enhanced Security

In today’s security-conscious world, signing your container images is a best practice. Skopeo supports image signing using GPG:

1. Generate a GPG key:

```bash
gpg --generate-key
```

Follow the steps to generate, or use an existing one `gpg -K`

2. Sign the image during copy:

```bash
skopeo copy \
  --sign-by YOUR_KEY_ID \
  docker://source.registry.com/myimage:latest \
  docker://destination.registry.com/myimage:latest 
```

3. Verify a signed image

```bash
skopeo inspect --verify-signatures docker://destination.registry.com/myimage:latest
```

```json
{
  "Name": "destination.registry.com/myimage",
  "Digest": "sha256:...",
  "RepoTags": [
    "tag"
  ],
  "Created": "2025-04-15T12:34:56Z",
  "DockerVersion": "20.10.7",
  "Labels": {
    "maintainer": "you@example.com"
  },
  "Architecture": "amd64",
  "Os": "linux",
  "Layers": [
    "sha256:..."
  ]
}
```

If the verification fails, you would receive the following message:

```bash
FATA[0001] Signature for docker://destination.registry.com/myimage:latest is not valid: signature verification failed: no valid signatures found
```

That’s about it! Skopeo is a powerful and flexible tool that can seriously level up your container workflows. Whether you’re automating image promotion across environments, verifying signatures for security, or just avoiding the hassle of pulling and pushing images manually — Skopeo has your back. It plays well in CI pipelines, helps keep registries clean and in sync, and makes inspecting remote images a breeze. Give it a spin, and you might wonder how you ever managed without it.