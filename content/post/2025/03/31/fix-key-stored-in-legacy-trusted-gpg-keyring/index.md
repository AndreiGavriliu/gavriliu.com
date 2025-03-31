---
title: "Fix Key Stored in Legacy Trusted Gpg Keyring"
date: 2025-03-31T08:30:35+02:00
tags: ["apt", "gpg", "keyring", "legacy"]

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

In an effort to balance power efficiency with my tendency to hoard old hardware, I decided to move my overpowered Pi-hole setup from a Mac Mini to a Raspberry Pi 2. (Yes, the Pi 2! A true relic from the past, but still kicking.)

Everything was going smoothly — static IP, hostname set, network configured — until I ran the inevitable:

## The problem

```bash
apt update
```

```bash
Hit:1 http://raspbian.raspberrypi.com/raspbian bookworm InRelease
Hit:2 http://archive.raspberrypi.com/debian bookworm InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
90 packages can be upgraded. Run 'apt list --upgradable' to see them.
W: http://raspbian.raspberrypi.com/raspbian/dists/bookworm/InRelease: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details.
```

Weird, it's a brand new install, but anyway, let's fix it.

## The fix

### Step 1: Find the Offending Key

```bash
apt-key list | grep -A4 "trusted.gpg$"
```

You'll get something like this:

```bash
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
/etc/apt/trusted.gpg
--------------------
pub   rsa2048 2012-04-01 [SC]
      A0DA 38D0 D76E 8B5D 6388  7281 9165 938D 90FD DD2E
uid           [ unknown] Mike Thompson (Raspberry Pi Debian armhf ARMv6+VFP) <mpthompson@gmail.com>
```

That long hex string at the bottom? That's our culprit. Grab the last 8 characters (e.g., `90FDDD2E`).

### Step 2: Export the Key to a Temporary File

```bash
apt-key export 90FDDD2E | sudo gpg --dearmor -o /tmp/raspberrypi-os.gpg
```

If you're getting a warning about apt-key being deprecated — yes, we know. Thanks for the reminder, apt.

Step 3: Verify the Exported Key

```bash
file /tmp/raspberrypi-os.gpg
```

You should see something like:

```bash
/tmp/raspberrypi-os.gpg: PGP/GPG key public ring (v4) created Sun Jun 17 15:49:51 2012 RSA (Encrypt or Sign) 2048 bits MPI=0xabc2a41a70625f9f...
```

If this checks out, we’re good to move on.

### Step 4: Delete the Old Key

```bash
apt-key del 90FDDD2E
```

### Step 5: Move the Exported Key to the Right Place

```bash
mv /tmp/raspberrypi-os.gpg /etc/apt/trusted.gpg.d/
```

## The Moment of Truth

Time to see if all this work actually made a difference.

```bash
apt update
```

No errors? No legacy key warnings? Success!

Now, for the real prize:

```bash
apt upgrade -y
```

Watch those packages roll in, knowing you’ve successfully outwitted a deprecated key storage issue on a nearly decade-old Raspberry Pi.

This was one of those “why is this happening on a clean install?” moments that make homelabbing so much fun (and sometimes maddening). But at least now, my Pi-hole setup is running on a true low-power device, and I got a free lesson in Debian’s ever-evolving key management system.

Hope this helps someone else avoid the same head-scratching moment!