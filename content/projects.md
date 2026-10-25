+++
draft = false
title = 'Projects'
ToC = true
showShare = false
showReadTime = false
showDate = false
comments = false
+++

## Homelab

My homelab is running on 4 Intel NUCs, all happily chugging along with k3s. The network backbone is a UniFi setup, featuring a UDMPro and a UniFi Switch 24 Pro POE. Right now, it’s a cozy 1GB network, but I’m planning to bump it up to 2.5GB soon—because, well, who doesn’t love faster speeds? The only thing slowing me down at the moment is the backup process—Longhorn and Kasten.io backups are giving me a bit of a bottleneck, with everything stored safely on my trusty old Synology DS918+.

A few details about what makes it all work smoothly:
* [Traefik](https://traefik.io/) (Dynamic ingress controller)
* [ArgoCD](https://argo-cd.readthedocs.io) (GitOps continuous delivery)
* [Kasten.io](https://www.veeam.com/products/cloud/kubernetes-data-protection.html) (Kubernetes backup solution)
* [Longhorn](https://longhorn.io/) (Cloud-native storage)
* [Bitnami Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) (Encrypted secrets management)
* [Graylog](https://graylog.org/) (Centralized log management)
* [RenovateBot](https://github.com/renovatebot/renovate) (Automated dependency updates)
* [MetalLB](https://metallb.io/) (Load balancing for bare-metal)
* [cert-manager](https://cert-manager.io/) (TLS certificate management)
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (Monitoring stack)
    * [Grafana](https://grafana.com/) (Data visualization)
    * [Prometheus](https://prometheus.io/) (Metrics collection)
    * [AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) (Alert management)

```mermaid
graph TD
    fritz-box["AVM FRITZ!Box"]
    fritz-box --> unifi-dream-machine-pro

    unifi-dream-machine-pro["Uifi<br/>Dream Machine Pro"]

    subgraph VPN["VPN networks"]
        vpn-homelab["Homelab VPN"]
    end
    unifi-dream-machine-pro -.- VPN

    unifi-usw-pro-max-24-poe["USW Pro Max 24 PoE"]
    unifi-dream-machine-pro ==>|"10G"| unifi-usw-pro-max-24-poe

    subgraph hive
        hive-01["hive-01"]
        hive-02["hive-02"]
        hive-03["hive-03"]
        hive-04["hive-04"]
    end
    synology-ds918-plus["Synology DS918+"]
    pihole-01["pihole-01/HAProxy"]
    openccu["OpenCCU (HomeMatic)"]
    power-distribution-unit-01["PDU-01"]
    slzb-06m["SLZB-06M"]

    unifi-usw-flex-mini["USW Flex Mini"]
    unifi-usw-pro-max-24-poe -->|"1G"| hive-01
    unifi-usw-pro-max-24-poe -->|"1G"| hive-02
    unifi-usw-pro-max-24-poe -->|"1G"| hive-03
    unifi-usw-pro-max-24-poe -->|"1G"| hive-04
    unifi-usw-pro-max-24-poe -->|"1G"| unifi-usw-flex-mini
    unifi-usw-pro-max-24-poe -->|"1G"| synology-ds918-plus
    unifi-usw-pro-max-24-poe -->|"100M"| pihole-01
    unifi-usw-pro-max-24-poe -->|"100M"| openccu
    unifi-usw-pro-max-24-poe -->|"1G"| power-distribution-unit-01
    unifi-usw-pro-max-24-poe -->|"100M"| slzb-06m

    subgraph hive-externalip["ExternalIP Services"]
        externalip-01(["mqtt"])
        externalip-02(["homeassistant"])
        externalip-03(["ingressVIP"])
    end
    hive -.-> externalip-02
    hive -.-> externalip-01
    hive -.-> externalip-03

    %% ---------- Office ----------
    unifi-usw-flex-mini -->|"1G"| office-pc-01["Office PC 01"]
    unifi-usw-flex-mini -->|"1G"| printer-01["Printer 01"]
    unifi-usw-flex-mini -->|"100M"| pikvm-01["PiKVM 01"]

    %% ---------- Access points ----------
    subgraph access-points["Access Points"]
        unifi-uap-u6-pro-01["Unifi<br/>UAP U6 Pro"]
        unifi-uap-ac-pro-01["Unifi<br/>UAP AC Pro"]
        unifi-uap-ac-pro-02["Unifi<br/>UAP AC Pro"]
    end
    unifi-usw-flex-mini -->|"1G"| unifi-uap-u6-pro-01
    unifi-usw-flex-mini -->|"1G"| unifi-uap-ac-pro-01
    unifi-uap-ac-pro-01 -. "wireless mesh uplink" .-> unifi-uap-ac-pro-02

    subgraph wifi-clients["WiFi Clients"]
        appletv-01["Apple TV 01"]
        appletv-02["Apple TV 02"]
        sony-playstation["Sony Playstation"]
        nintendo-switch["Nintendo Switch"]
        iot-devices["IoT Devices"]
        security-camera-01["Security Camera 01"]
        security-camera-02["Security Camera 02"]
    end
    access-points -.-> wifi-clients

    %% ---------- VLAN colours ----------
    classDef infra fill:#e5e7eb,stroke:#374151,color:#111
    classDef lab fill:#dbeafe,stroke:#1d4ed8,color:#111
    classDef vip fill:#eff6ff,stroke:#1d4ed8,stroke-dasharray:4 3,color:#111
    classDef iot fill:#fef3c7,stroke:#b45309,color:#111
    classDef cctv fill:#fee2e2,stroke:#b91c1c,color:#111
    classDef home fill:#dcfce7,stroke:#15803d,color:#111
    classDef down fill:#f9fafritz-box,stroke:#9ca3af,stroke-dasharray:4 3,color:#6b7280

    class fritz-box,unifi-dream-machine-pro,unifi-usw-pro-max-24-poe,unifi-usw-flex-mini,unifi-uap-u6-pro-01,unifi-uap-ac-pro-01,unifi-uap-ac-pro-02 infra
    class hive-01,hive-02,hive-03,hive-04,synology-ds918-plus,pihole-01,office-pc-01 lab
    class externalip-01,externalip-02,VIP43,externalip-03 vip
    class pikvm-01,iot-devices,slzb-06m,printer-01,openccu,power-distribution-unit-01 iot
    class security-camera-01,security-camera-02 cctv
    class appletv-01,appletv-02,sony-playstation,nintendo-switch home
    class vpn-homelab down
```

... more details about the cluster and what Apps I am hosting, in my [homelab series](series/homelab)

## Home Assistant

[Home Assistant](https://www.home-assistant.io/) is like my home’s personal assistant, but instead of scheduling meetings, it’s reminding me to take the trash out and telling me when the washer’s done. It’s got some quirks, though—sometimes it seems to know me better than I know myself, like when it randomly turns on the lights at 3 AM and I’m left wondering if it’s just being helpful or trying to send me a message. At least it’s not sending passive-aggressive reminders… yet.

A few integrations I use:
* [Alarmo](https://github.com/nielsfaber/alarmo)
* [Google Calendar](https://www.home-assistant.io/integrations/google/)
* [Homematic(IP) Local](https://github.com/SukramJ/custom_homematic)
* [InfluxDB](https://www.home-assistant.io/integrations/influxdb/)
* [Nintendo Switch Parental Controls](https://github.com/pantherale0/ha-nintendoparentalcontrols)
* [ONVIF](https://home.gavriliu.com/config/integrations/integration/onvif)
* [OpenWeatherMap](https://www.home-assistant.io/integrations/openweathermap/)
* [OpenWeatherMap History](https://github.com/petergridge/openweathermaphistory)
* [SMLIGHT](https://www.home-assistant.io/integrations/smlight/)
* [Tasmota](https://www.home-assistant.io/integrations/tasmota/)
* [UniFi Network](https://www.home-assistant.io/integrations/unifi/)
* [UniFi Protect](https://www.home-assistant.io/integrations/unifiprotect/)
* [Waze Travel Time](https://www.home-assistant.io/integrations/waze_travel_time/)

<!-- ... and more on my [GitHub Repository](https://github.com/AndreiGavriliu/homelab/cluster/hive/apps/homeassistant/k8s-manifests) -->
... more details about my Home Assistant instance and what Integrations I am using, in my [homeassistant series](series/homeassistant)

## Tasmin

I’m building Tasmin — a GitOps-like manager for your Tasmota devices that not only updates, configures, and backs them up, but also checks for changes in the config and corrects them when the devices finally decide to show up on the network. Think of it like [TasmoAdmin](https://github.com/TasmoAdmin/TasmoAdmin) and [TasmoBackup](https://github.com/danmed/TasmoBackupV1), but with a ‘because I can’ attitude. Powered by [FastAPI](https://fastapi.tiangolo.com/) and a sprinkle of ‘I can do this better… probably’ energy!

I’m too ashamed of my code right now, so the repository will be posted at a later date… after I make it look like I know what I’m doing.