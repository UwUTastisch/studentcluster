{ config, pkgs, lib, meta, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

# Tell sops-nix where to find the Age private key
  sops.age.keyFile = "/etc/age/keys.txt";
  
  sops.defaultSopsFile = "${inputs.self}/secrets.yaml";

  sops.secrets = {
    k3sToken = {
      key = "k3sToken";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "Germany/Berlin";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
     neovim
     k3s
     cifs-utils
     nfs-utils
     git
  ];
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3sToken.path;
    # token = keys.k3sToken; # hardcoded token that will manually set on setup
    # tokenFile = config.sops.secrets.token.path; #/var/lib/rancher/k3s/server/token; # file where the token is stored in life system for updating purpose
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if meta.hostname == "studentcluster-1" then [] else [
	      "--server https://studentcluster-1:6443"
    ]));
    clusterInit = (meta.hostname == "studentcluster-1");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  networking.hostName = meta.hostname;
  networking.firewall.enable = false;

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgEbYFhjx2OJ9c4XxFLBJB7nZylIXEKgNcU+kA7huaZ user@Designare-AMD-NVIDIA-INTEL"    
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7uTj/p9ZTQn1tJJxQVYc5qjL3zflQ6lAHJwl+Uc+3bA2St7E9ex0qMxqJVkyW9r/vn4QJ7KjnJ6AqaWICMKoqaUmRGtGDl+Al/ZL6MmTD4769mP/W2Jl//LS5GVFeZ0ob6Un960cwFP6QAs6x9uEoXMMqJMIbVLZ25KWzrt16UJO59H4USykVibs6M3cZwgqAu2mbpBD4G31sfT6/3v5Q0YE80R/aM+WcOwJxSAaFNWLosV0ZW8l4O97KOQLR+t+XUk5wESjcs667YOMirCfjlr6dfP81QMLjJzlj3AGEf460c0rbJjgiWhdDMk9fnKVaX7gjnxhssAKRLy+dE+VKVeRUfeX9Rw5BGYseCJ6qiqAFBx+lwn08j7lcnP58sTHfWoXAFBAEdtKc5S/R/RqS12jl+8TR0gQzwWbI7OwkZrNBd0aWv5ICiXIf68IDBUJPA4pIbSL7YXOMfKrvMGIoWu1PALvki6fiE1au9/3Hhg1MjT8Hd7ltoizoTMwG5Ck= vz2269@honshu"
    # temp4 pw
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvAWkHAUnxepkimZE+8gDwkDbL7XjUyDXWhmoF7lPlJ nixos@nixos"
  ];

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    # Created using mkpasswd -m sha-512
    hashedPassword = "$6$d816QdheQ3hVToWr$p3A/vNJicvTISWyIv4LRK7/wNFsB7eLmvARRNVJSH8y9s/F0l/239HWLlj1nXJRC2aIMqa0f3XzBe3QnD8TCZ1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgEbYFhjx2OJ9c4XxFLBJB7nZylIXEKgNcU+kA7huaZ user@Designare-AMD-NVIDIA-INTEL"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7uTj/p9ZTQn1tJJxQVYc5qjL3zflQ6lAHJwl+Uc+3bA2St7E9ex0qMxqJVkyW9r/vn4QJ7KjnJ6AqaWICMKoqaUmRGtGDl+Al/ZL6MmTD4769mP/W2Jl//LS5GVFeZ0ob6Un960cwFP6QAs6x9uEoXMMqJMIbVLZ25KWzrt16UJO59H4USykVibs6M3cZwgqAu2mbpBD4G31sfT6/3v5Q0YE80R/aM+WcOwJxSAaFNWLosV0ZW8l4O97KOQLR+t+XUk5wESjcs667YOMirCfjlr6dfP81QMLjJzlj3AGEf460c0rbJjgiWhdDMk9fnKVaX7gjnxhssAKRLy+dE+VKVeRUfeX9Rw5BGYseCJ6qiqAFBx+lwn08j7lcnP58sTHfWoXAFBAEdtKc5S/R/RqS12jl+8TR0gQzwWbI7OwkZrNBd0aWv5ICiXIf68IDBUJPA4pIbSL7YXOMfKrvMGIoWu1PALvki6fiE1au9/3Hhg1MjT8Hd7ltoizoTMwG5Ck= vz2269@honshu"
      # temp4 pw
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOvAWkHAUnxepkimZE+8gDwkDbL7XjUyDXWhmoF7lPlJ nixos@nixos"
    ];
  };

  system.stateVersion = "24.05";
}
