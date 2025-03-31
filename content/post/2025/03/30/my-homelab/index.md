---
title: "My Homelab"
date: "2025-03-30T20:35:45+02:00"
tags: ["homelab", "kubernetes", "unifi"]

showShare: false
showReadTime: true
usePageBundles: true
toc: true
draft: true

# featureImage: 'image.png'
# featureImageAlt: 'Rack by ChatGPT'
# featureImageCap: 'Rack by ChatGPT'
# thumbnail: 'image.png'
# shareImage: 'image.png'

series: homelab
showRelatedInArticle:  true
showRelatedInSidebar: true
---

Why would anyone write about their homelab? Well, for one, so future me can remember why I set things up the way I did (and why it inevitably broke). But also, because homelabbing is a mix of art, science, and just enough chaos to keep things interesting. By sharing my setup, I hope others can learn from my mistakes, steal my good ideas, and maybe even tell me how to do things better. After all, half the fun of a homelab is comparing notes with fellow tinkerers who also think ‘just one more server’ is a reasonable life choice.

## Diagram

![My homelab diagram (Work in progress)](homelab-diagram.png)

## Hardware Components

* 1x [Unifi DreamMachine Pro](https://eu.store.ui.com/eu/en/products/udm-pro)
* 1x [Unifi Switch Pro Max 24 PoE](https://eu.store.ui.com/eu/en/products/usw-pro-max-24-poe)
* 1x [Unifi Switch Flex Mini](https://eu.store.ui.com/eu/en/products/usw-flex-mini)
* 2x [Unifi UAP AC Pro](https://eu.store.ui.com/eu/en/products/uap-ac-pro)
* 1x [Unifi UAP U6 Pro](https://eu.store.ui.com/eu/en/products/u6-pro)
* k3s cluster:
    * 3x [Intel NUCs](https://www.intel.de/content/www/de/de/content-details/810135) (4 Cores, 32GB RAM, 2x NVMe 250GB)
    * 1x [Intel NUCs](https://www.intel.de/content/www/de/de/content-details/810135) (4 Cores, 16GB RAM, 1x NVMe 250GB)
* 1x [Apple MacMini 2012](https://support.apple.com/en-gb/111926)
* 1x [RaspberryPi 3b](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/)
* 1x [RaspberryPi 4b](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
* 1x [Avocent PM3000 PDU](https://www.vertiv.com/en-emea/support/software-download/power-distribution/avocent-managed-rack-pdu---pm-1000-2000-3000-software-downloads/)
* 1x [Synology 918+](https://global.synologydownload.com/download/Document/Hardware/DataSheet/DiskStation/18-year/DS918%2B/ger/Synology_DS918_Plus_Data_Sheet_ger.pdf) (4x 8TB)

## Software/Applications

* Apple MacMini (loadbalancer.lab):
    * [haproxy](https://github.com/haproxy/haproxy) - The gatekeeper of my homelab, making sure traffic goes where it should (most of the time).
    * [pihole](https://github.com/pi-hole/pi-hole) - Blocks ads so I don’t have to see yet another “One Weird Trick” clickbait.
* NUC's (hive01.lab, hive02.lab, hive03.lab, hive04.lab):
    * [alertmanager-to-github](https://github.com/pfnet-research/alertmanager-to-github) - Turns my homelab alerts into GitHub issues, because why not make my monitoring social?
    * [argocd](https://github.com/argoproj/argo-cd) - The automation overlord that keeps my apps in check so I don’t have to.
    * [audiobookshelf](https://github.com/advplyr/audiobookshelf) - A small collection of audiobooks, mostly classics and tech, because sometimes it’s just nicer to listen than to read.
    * [cert-manager](https://github.com/cert-manager/cert-manager) - Keeps my Let’s Encrypt certificates fresh, like a good barista with coffee beans.
    * [changedetection](https://github.com/dgtlmoon/changedetection.io) - Stalking bike park schedules so I never miss an event.
    * [ddclient](https://github.com/ddclient/ddclient) - Telling the world my ever-changing IP, one update at a time.
    * [firefly-iii](https://github.com/firefly-iii/firefly-iii) - Managing my finances so I don’t end up questioning my life choices at the end of the month.
    * [freshrss](https://github.com/FreshRSS/FreshRSS) - Curating tech news so I can pretend I’m up-to-date.
    * [grafana](https://github.com/grafana/grafana) - Drowning in metrics but making them look pretty.
    * [graylog](https://github.com/graylog2) - Because everything that happens needs to be logged… forever.
    * [homeassistant](https://github.com/home-assistant) - The true ruler of my home, keeping me organized (and slightly paranoid).
    * [hugo](https://github.com/gohugoio/hugo) - hosts [gavriliu.com](https://gavriliu.com) like a minimalist champ.
    * [kasten-io](https://docs.kasten.io/latest/index.html) - Because having backups is cool, but restoring them is even cooler.
    * [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) - Alerting me when things go wrong (which is always at 3 AM).
    * [kubernetes-dashboard](https://github.com/kubernetes/dashboard) - I don’t need it, but it looks good.
    * [longhorn](https://github.com/longhorn/longhorn) - Because my cluster needs storage, and NFS felt too mainstream.
    * [mealie](https://github.com/mealie-recipes/mealie) - Saving recipes from my inevitable paper chaos.
    * [metallb](https://github.com/metallb/metallb) - Assigning external IPs like a generous ISP.
    * [netbox-community](https://github.com/netbox-community/netbox) - Helping me pretend I have my network under control.
    * [ntfy](https://github.com/binwiederhier/ntfy) - The homelab’s personal notification messenger.
    * [paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) - Because paper is so last century.
    * [renovate](https://github.com/renovatebot/renovate) - Updates my manifests so I don’t have to, like a personal assistant for my containers.
    * [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) - Encrypting my secrets so they stay secret (hopefully).
    * [traefik](https://github.com/traefik/traefik) - The traffic cop of my cluster.
    * [umami](https://github.com/umami-software/umami) - Watching over my website visitors (but in a totally ethical way).
    * [vaultwarden](https://github.com/dani-garcia/vaultwarden) - Because reusing passwords is a bad idea (no matter how tempting).
    * [wger](https://github.com/wger-project/wger) - Tracking workouts, but mostly tracking how often I skip them.
* RaspberryPi 3b:
    * [raspberrymatic](https://github.com/jens-maus/RaspberryMatic) - Keeping my smart home smart, even after my old Homematic CCU3 decided to ghost me.
* RaspberryPi 2:
    * [pihole](https://github.com/pi-hole/pi-hole) - Because online ads are the digital equivalent of mosquitoes.
* Synology 918+:
    * Plex
    * Backup Location
    * Paperless-NGX export for quick access

## ToDo's

* update diagram to include all devices
* update diagram to include applications
* move `slbz-06m.lab` to the IoT VLAN (`slzb-06m.iot`)
* move `raspberrymatic.lab` to the IoT VLAN (`raspberrymatic.iot`)