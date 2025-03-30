---
title: "How Rearranging a Kid's Room Broke My Zigbee Network (and How I Fixed It)"
date: "2025-03-28T10:38:06+01:00"
tags: ["zigbee2mqtt", "slzb-06m", "troubleshoot", "homeassistant"]

showShare: false
showReadTime: true
usePageBundles: true
toc: true

# featureImage: 'image.png'
# featureImageAlt: 'IoT network by ChatGPT'
# featureImageCap: 'IoT network by ChatGPT'
# thumbnail: 'image.png'
# shareImage: 'image.png'

series: homeassistant
showRelatedInArticle:  true
showRelatedInSidebar: true
---

A few days ago, my wife decided that we - sorry, I — needed to rearrange our kid's room. This involved unplugging various things, including my [IKEA VINDSTYRKA](https://www.ikea.com/de/de/p/vindstyrka-luftqualitaetssensor-smart-00498231/) air quality sensor.

Fast forward to today: I noticed my `zigbee2mqtt` container had been restarting multiple times. Weird. 
<!--more-->
But everything seemed to be working fine — devices were updating, automations were triggering, life was good. Then I plugged the sensor back in, and... Home Assistant didn’t recognize it. Did I forget to pair it after playing around with it? Who knows. But no problem, right? Just press the button four times and let the magic happen.

Well, magic didn't happen. Instead, my `zigbee2mqtt` container restarted. Uh-oh.

## The Troubleshooting Rabbit Hole

At this point, I had a feeling something was off. So I tried the usual troubleshooting steps:

1. Restarted my SLZB-06M Zigbee coordinator (connected via Ethernet).
1. Restarted the `zigbee2mqtt` and `mqtt` containers.
1. Tried to rejoin the sensor again.

Same result. Failure. Logs weren’t helpful, just cryptic messages from the Zigbee underworld.

```bash
Using '/app/data' as data directory
Starting Zigbee2MQTT without watchdog.
[2025-03-28 09:30:49] info: 	z2m: Logging to console, file (filename: log.log)
[2025-03-28 09:30:49] info: 	z2m: Starting Zigbee2MQTT version 2.1.3 (commit #ba337bd329aeb4ca17735c0cf09b31293c8cff06)
[2025-03-28 09:30:49] info: 	z2m: Starting zigbee-herdsman (3.2.7)
[2025-03-28 09:30:49] info: 	zh:ember: Using default stack config.
[2025-03-28 09:30:49] info: 	zh:ember: ======== Ember Adapter Starting ========
[2025-03-28 09:30:49] info: 	zh:ember:ezsp: ======== EZSP starting ========
[2025-03-28 09:30:49] info: 	zh:ember:uart:ash: ======== ASH Adapter reset ========
[2025-03-28 09:30:49] info: 	zh:ember:uart:ash: Socket ready
[2025-03-28 09:30:49] info: 	zh:ember:uart:ash: ======== ASH starting ========
[2025-03-28 09:30:51] info: 	zh:ember:uart:ash: ======== ASH connected ========
[2025-03-28 09:30:51] info: 	zh:ember:uart:ash: ======== ASH started ========
[2025-03-28 09:30:51] info: 	zh:ember:ezsp: ======== EZSP started ========
[2025-03-28 09:30:51] info: 	zh:ember: Adapter EZSP protocol version (14) lower than Host. Switched.
[2025-03-28 09:30:51] info: 	zh:ember: Adapter version info: {"ezsp":14,"revision":"8.0.2 [GA]","build":397,"major":8,"minor":0,"patch":2,"special":0,"type":170}
[2025-03-28 09:30:51] info: 	zh:ember: [STACK STATUS] Network up.
[2025-03-28 09:30:52] info: 	zh:ember: [INIT TC] Adapter network matches config.
[2025-03-28 09:30:52] info: 	zh:ember: [CONCENTRATOR] Started source route discovery. 1246ms until next broadcast.
[2025-03-28 09:30:52] info: 	z2m: zigbee-herdsman started (resumed)
[...]
[2025-03-28 09:22:37] info: 	zh:controller: Interview for '0xd44867fffe5b1c0c' started
[2025-03-28 09:22:37] info: 	z2m: Device '0xd44867fffe5b1c0c' joined
[2025-03-28 09:22:37] info: 	z2m: Starting interview of '0xd44867fffe5b1c0c'
[2025-03-28 09:22:37] info: 	z2m:mqtt: MQTT publish: topic 'zigbee2mqtt/bridge/event', payload '{"data":{"friendly_name":"0xd44867fffe5b1c0c","ieee_address":"0xd44867fffe5b1c0c"},"type":"device_joined"}'
[2025-03-28 09:22:37] info: 	z2m:mqtt: MQTT publish: topic 'zigbee2mqtt/bridge/event', payload '{"data":{"friendly_name":"0xd44867fffe5b1c0c","ieee_address":"0xd44867fffe5b1c0c","status":"started"},"type":"device_interview"}'
[2025-03-28 09:22:37] error: 	zh:ember:uart:ash: Received ERROR from adapter, with code=ERROR_EXCEEDED_MAXIMUM_ACK_TIMEOUT_COUNT.
[2025-03-28 09:22:37] error: 	zh:ember:uart:ash: ASH disconnected | Adapter status: ASH_NCP_FATAL_ERROR
[2025-03-28 09:22:37] error: 	zh:ember:uart:ash: Error while parsing received frame, status=ASH_NCP_FATAL_ERROR.
[2025-03-28 09:22:37] error: 	zh:ember: Adapter fatal error: HOST_FATAL_ERROR
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash: ASH COUNTERS since last clear:
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Total frames: RX=92, TX=134
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Cancelled   : RX=0, TX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   DATA frames : RX=72, TX=41
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   DATA bytes  : RX=1284, TX=501
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Retry frames: RX=17, TX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   ACK frames  : RX=0, TX=91
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   NAK frames  : RX=0, TX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   nRdy frames : RX=0, TX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   CRC errors      : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Comm errors     : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Length < minimum: RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Length > maximum: RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Bad controls    : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Bad lengths     : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Bad ACK numbers : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Out of buffers  : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Retry dupes     : RX=17
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   Out of sequence : RX=0
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash:   ACK timeouts    : RX=0
[2025-03-28 09:22:37] error: 	zh:ember:uart:ash: Error while parsing received frame, status=ASH_NCP_FATAL_ERROR.
[2025-03-28 09:22:37] info: 	zh:ember:uart:ash: ======== ASH stopped ========
[2025-03-28 09:22:37] info: 	zh:ember:ezsp: ======== EZSP stopped ========
[2025-03-28 09:22:37] info: 	zh:ember: ======== Ember Adapter Stopped ========
[2025-03-28 09:22:37] error: 	z2m: Adapter disconnected, stopping
[2025-03-28 09:22:49] info: 	z2m:mqtt: MQTT publish: topic 'zigbee2mqtt/bridge/state', payload '{"state":"offline"}'
[2025-03-28 09:22:49] info: 	z2m: Disconnecting from MQTT server
[2025-03-28 09:22:49] info: 	z2m: Stopping zigbee-herdsman...
[2025-03-28 09:22:49] info: 	z2m: Stopped zigbee-herdsman
[2025-03-28 09:22:49] info: 	z2m: Stopped Zigbee2MQTT
```

## Turning to the Internet (And Realizing No One Had a Fix)

Like any responsible tech enthusiast, I turned to the Internet — GitHub issues, forums, random Reddit threads. And, as expected, I found discussions, but none of the solutions worked for me. Some people suggested downgrading firmware, others said to sacrifice a goat (or was it just reset the Zigbee network? Hard to tell).

## The Fix That Worked

Since nothing else was helping, I decided to go nuclear: flash the firmware. Here’s what I did:
1. Flashed the `Zigbee Router 20250220` firmware.
1. Flashed the `Zigbee Coordinator 20250220` firmware.

And boom! Everything was back to normal. The sensor paired without issues, no more zigbee2mqtt restarts, and my smart home was happy again.

## Lessons Learned

Never underestimate the chaos a simple room rearrangement can cause.
When in doubt, firmware flashing is sometimes the way to go.
Maybe keep a backup Zigbee coordinator handy? (Future me, take note.)
Hopefully, this helps someone avoid spending hours chasing ghost issues. If you're dealing with `zigbee2mqtt` restarting when adding a device, give firmware flashing a shot. Just, you know, be careful not to brick your hardware.

Happy Zigbee-ing!