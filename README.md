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
- sops (nix-sops)

Additionally, you'll also want to make changes to the user information found in the `nixos/configuration.nix`

nix-env -iA nixpkgs.sops


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


```
sops --encrypt --in-place secrets.yaml
```

You're absolutely right, and I apologize for suggesting that. Including private keys or any secrets in your repository is a security risk and defeats the purpose of encryption. Let's explore how you can use `sops-nix` to manage secrets securely without committing private keys to your repository, while also making it easy to deploy to your machines.

---

### **Secure Secret Management with `sops-nix` Without Committing Private Keys**

To achieve secure secret management without including private keys in your repository, we'll use `sops-nix` with Age keys and ensure that the private key is available on the deployment machine without being stored in the repository.

Here's how you can do it:

1. **Generate an Age Key Pair**
2. **Encrypt your secrets with `sops`**
3. **Configure `sops-nix` to use the Age key during deployment**
4. **Deploy your configuration while securely providing the Age private key**

---

### **Step-by-Step Guide**

#### **1. Generate an Age Key Pair**

Generate an Age key pair on your local machine:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

This command generates a private key and saves it to `~/.config/sops/age/keys.txt`. The public key is included as a comment in the same file.

**Extract the Public Key:**

```bash
grep "# public key: " ~/.config/sops/age/keys.txt | cut -d' ' -f4
```

Copy the public key output for use in the next step.

#### **2. Encrypt Your Secrets with `sops`**

Create your `secrets.yaml` file with the sensitive data:

```yaml
k3sToken: "your-secret-token-here"
```

Create a `.sops.yaml` configuration file in your project directory (this file can be committed to your repository as it only contains public information):

```yaml
creation_rules:
  - encrypted_regex: '^(secrets\.ya?ml)$'
    age: [ "your-age-public-key-here" ]
```

Replace `"your-age-public-key-here"` with the Age public key you extracted earlier.

**Encrypt the `secrets.yaml` file:**

```bash
sops --encrypt --in-place secrets.yaml
```

Now, `secrets.yaml` is encrypted and safe to commit to your repository.
bash
```shell
sudo nix run github:nix-community/nixos-anywhere -- --flake .#studentcluster-1 \
  --extra-files ~/.config/sops/age/keys.txt:/etc/age/keys.txt \
  root@nixos-installer
```


```bash
nix run github:nix-community/nixos-anywhere \
--extra-experimental-features "nix-command flakes" \
-- --flake '.#studentcluster-1' \
--extra-files ~/.config/sops/age/keys.txt:/etc/age/keys.txt \
--generate-hardware-config nixos-facter facter.json root@nixos-installer
```

or 

```bash
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
