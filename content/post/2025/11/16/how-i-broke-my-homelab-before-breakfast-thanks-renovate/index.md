---
title: "How I Broke My Homelab Before Breakfast (Thanks, Renovate!)"
date: 2025-11-16T03:00:00+02:00
tags: ["kubernetes", "renovate", "longhorn", "multipath"]

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

There are two kinds of people in the world:
1. Those who wake up, stretch, drink a glass of water, maybe journal...
1. And people like me, who roll over, grab their phone, and approve a Renovate bot PR before even opening one eye fully.

This particular morning, Renovate greeted me with: *Update Longhorn from 1.10.0 to 1.10.1*

- A micro version bump.
- A tiny, innocent patch release.
- Practically a rounding error.

*What could possibly go wrong?*

Well, sit down, dear reader.

## Trusting Robots at 6 AM: A Mistake

Without a second thought (or the first cup of coffee), I hit *Approve*.

ArgoCD ran. The update flowed through the cluster like a gentle breeze. Nothing screamed in red. I didn’t look for red, but I assume it wasn’t there.

Then I proceeded to upgrade the Longhorn engine version on all volumes.

Did I...
* check the logs?
* verify that volumes were healthy?
* confirm the cluster wasn’t on fire?

Absolutely not.

I closed my laptop with the satisfaction of someone who thinks they’ve accomplished something productive before breakfast.

Ah, the bliss of ignorance.

## The Next Day: Trouble at Home (Assistant)

Fast-forward to the following day, around the time I was just beginning to forget that I run a cluster capable of making or breaking my marriage.

My wife walks up to me with the same tone she uses when informing me that the dishwasher is flooding the kitchen: *"Home Assistant isn’t working."*

I laughed internally, a soft *"haha, sure."*

Then I checked it.

It wasn’t working.

Nothing was working.
* Home Assistant was down.
* Several other apps were down.
* And all their pods were patiently sitting in the Kubernetes waiting room known as: `ContainerCreating`

Which roughly translates to: *"I tried. I failed. Please send help."*

One example:

```bash
homeassistant addon-tasmobackup-68dd464c58-7hknn 0/1 ContainerCreating ...
```

These pods were hitting the same universal wall: **Volumes could not be attached!**

## CSI: Kubernetes - Investigating the Crime Scene

Event logs helpfully reported:
* "Waiting for volume share to be available"
* "Node is not ready"
* "Bad response statusCode [500]"

Everything you want to see when your home automation stack is down.

Meanwhile, Longhorn logs were essentially reenacting a chaotic sitcom:

```bash
mount: already mounted or mount point busy
e2fsck: device in use
mount failed: exit status 32
```

This was not a "healthy storage system" vibe.
This was more of a "ghost is trying to mount the volume first" vibe.

## The Heroic Troubleshooting Phase (aka Button Mashing)

Naturally, like any sysadmin would, I went through the Five Stages of Kubernetes Troubleshooting:

### 1. Restart Everything
* Deployments? Restarted.
* Pods? Restarted.
* Hope? Restarted, then lost again.

2. Blame the Nodes
* Cordon
* Drain
* Reboot
* swear
* repeat.

Nodes responded with *"lol no."*

### 3. Try Fixing Longhorn the Hard Way
I even went as far as fully reinitializing Longhorn on one node.
* Wiped it clean.
* Rebooted.
* Synced volumes.

It worked! - not!

### 4. Consider Full OS Reinstall

For a moment, I entertained the nuclear option: reinstalling Ubuntu. Then realized:
* It would take too long
* It wouldn’t fix anything
* I’d have to reconfigure everything
* My wife would ask more questions

And we don’t want that.

### 5. Sleep and let the Cluster Fairies Handle It

The K3s fairy is a myth. A cruel, cruel myth.

## The Coffee-Fueled Breakthrough

Morning arrived.

I grabbed a coffee.

Sat down.

And THEN did the thing I should’ve done first: **Check the GitHub issues.**

And there it was: Longhorn issue [#11932](https://github.com/longhorn/longhorn/issues/11932), staring me in the face like a disappointed parent.

Specifically this magical [comment](https://github.com/longhorn/longhorn/issues/11932#issuecomment-3392995950):

> o.k., I can confirm: after disabling multipath on all nodes, my pods are starting up. Some more checks needed, but this may have solved the issue.
> 
> Many thanks,
>
> Wolfram

Multipath.
Multipath!

Of course the problem was multipath. Because nothing says "fun home Kubernetes cluster weekend" like an unexpected device-mapper fight.

## The Fix (aka The “Why Didn’t I Do This Yesterday” Step)

SSH into each node:
* cordon
* drain
* k3s-killall.sh
* disable multipath
* stop multipath
* reboot
* pray

Command used:
```bash
systemctl disable multipathd.service multipathd.socket
systemctl stop multipathd.service multipathd.socket
```

One by one, letting Longhorn rebuild volumes in between, like a grown-up with patience and self-awareness.

Slowly and miraculously, the cluster healed.
* Pods came back.
* Volumes attached.
* Home Assistant rose from the dead.

## Domestic Impact Assessment

My wife, upon seeing everything working again:
* Happy that her smart home automations were restored
* Unhappy that they broke in the first place

This is what the SRE world calls: *Partially Degraded Relationship Performance*

Dinner is on me tonight. Probably a dessert upgrade too.

## Lessons Learned (And Immediately Forgotten)
* Patch versions can break things.
* Renovate is not a therapist, it won’t warn you.
* Always read upgrade notes.
* Or at least skim GitHub issues before nuking nodes.
* Longhorn + multipath = pain.
* Home Assistant is the single most critical service in any household.
* Sleep does NOT fix clusters.


If this post stops even one person from approving a Renovate PR before coffee, then my suffering has served a higher purpose.

You’re welcome.