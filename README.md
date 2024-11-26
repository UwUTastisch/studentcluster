# Homelab

This is a **fork** of the companion configuration that goes with the video from [Dreams of Autonomy](https://youtu.be/2yplBzPCghA).

This project is split into different directories depending on each service used.

## Requirements

To use this, you'll need the following installed on your sysetm

- nix
- kubectl
- helmfile
- helm
- git

## Setup

Additionally, you'll also want to make changes to the user information found in the `nixos/configuration.nix`. And you need to init `nixos/.root` with 

```bash 
cd nixos
cp example_root -r .root
```

and setup the a k3s-token

```bash
# Be careful, this will overwrite the tokenfile
pwgen -s -n 32 | head -n1 > ./.root/var/lib/rancher/k3s/server/token
# or use
cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 32 > ./.root/var/lib/rancher/k3s/server/token
```


## nixos

This directory contains the nixos configuration for setting
up each node with k3s.

The configuration makes use of nix flakes under the hood, with each node configuration being:

```
studentcluster-1
studentcluster-2
studentcluster-3
```

To set up a node from fresh, you can use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). This requires loading the nixos installer and then booting the node into it. You can then install remotely once you've set the nodes password using the `passwd` command. 


The command I use is as follows:

---


```bash
nix run github:nix-community/nixos-anywhere \
--extra-experimental-features "nix-command flakes" \
-- --flake '.#studentcluster-1' \
--extra-files './.root'
--generate-hardware-config nixos-facter facter.json root@nixos-installer
```

or 

```bash
sudo nix shell github:nix-community/nixos-anywhere -c bash

sudo nixos-anywhere --flake '.#studentcluster-1' \
--extra-files './.root'
--generate-hardware-config nixos-facter facter.json root@nixos-installer
```

make sure to replace with your own ip.

## helm

This directory is used to store the helm configuration of the node and is managed using [helmfile](https://github.com/helmfile/helmfile), which is a declarative spec for defining helm charts.

To install this on your cluster, you can simply use the following command.

```
helmfile apply
```


## kustomize

Kustomize allows you to manage multiple manifest files in a `Kustomize.yaml`, which also allows you to override values if you need to.

I don't use Kustomize that much in the video, but it's a tool I do often use and is available in `kubectl`.
