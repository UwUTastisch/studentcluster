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

Additionally, you'll also want to make changes to the user information found in the `nixos/configuration.nix`

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

```shell
nix run github:nix-community/nixos-anywhere \
--extra-experimental-features "nix-command flakes" \
-- --flake '.#studentcluster-1' --generate-hardware-config nixos-facter facter.json <user>@<hostname>
```

or 

```shell
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-facter ./facter.json  --flake '.#studentcluster-1' root@nixos-installer
```

```shell
nix run github:nix-community/nixos-anywhere --extra-experimental-features "nix-command flakes" -- --flake .#studentcluster-1 --generate-hardware-config nixos-facter facter.json nixos@temp2.informatik.uni-rostock.de
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
