+++
title = "Containers Not Mounting Longhorn Volumes"
date = "2025-03-14T21:34:29+01:00"
tags = ["longhorn", "troubleshooting"]
hideComments = false
showShare = false
showReadTime = true
ToC = true
series = "homelab"
showRelatedInArticle = true
showRelatedInSidebar = true
+++

Shoutout to [derekbit](https://github.com/derekbit) for saving my cluster from a tragic post-power-outage existential crisis. My entire homelab went down for a few hours, and Longhorn wasn’t exactly in a hurry to come back. More details on the saga can be found [here](https://github.com/longhorn/longhorn/issues/7183) and in this lifesaving [comment](https://github.com/longhorn/longhorn/issues/7183#issuecomment-1823715359).<br>
<!--more-->

## Tools used

* [stern](https://github.com/stern/stern): Stern allows you to `tail` multiple pods on Kubernetes and multiple containers within the pod. Each result is color coded for quicker debugging.

## Check the logs

To start questioning your life choices, run:

```bash
stern -n longhorn-system longhorn-manager
```

This will flood your terminal with comforting messages like:

```bash
longhorn-manager-brgwp longhorn-manager E0129 16:59:30.764472       1 share_manager_controller.go:254] failed to sync longhorn-system/pvc-ca4a891c-cdc9-424e-949d-0ea016b80c84: pod share-manager-pvc-ca4a891c-cdc9-424e-949d-0ea016b80c84 for share manager not found
longhorn-manager-brgwp longhorn-manager time="2024-01-29T16:59:30Z" level=error msg="Dropping Longhorn share manager out of the queue" func=controller.handleReconcileErrorLogging file="utils.go:72" ShareManager=longhorn-system/pvc-7da9dfcf-a9b8-4995-ab1d-100a2a9ee72a controller=longhorn-share-manager error="failed to sync longhorn-system/pvc-7da9dfcf-a9b8-4995-ab1d-100a2a9ee72a: pod share-manager-pvc-7da9dfcf-a9b8-4995-ab1d-100a2a9ee72a for share manager not found" node=hive02
```

In short: Longhorn was not having a good day.

## Apply the fix

Borrowing from the wisdom of the Issue thread, I decided to take the nuclear option and reset all my volumes:

```bash
for lhsm in $(kubectl -n longhorn-system get lhsm --no-headers | awk '{ print $1 }')
do
  kubectl -n longhorn-system patch lhsm $lhsm --type=merge --subresource status --patch 'status: {state: error}'
  sleep 30
done
```

A few hours (and nervous sweats) later, everything was back to normal. No data loss, just a valuable lesson: *Power outages are the devil, and Longhorn likes to hold grudges.*