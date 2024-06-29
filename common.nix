{ pkgs, self, name, mmwave, machine-id ? -1, ... }:
let
  user = "mmwave";
  password = "mmwave";
  hostName = if machine-id >= 0 then "machine-${toString machine-id}" else "${name}";
  overlay = _final: super: {
    makeModulesClosure = x:
      super.makeModulesClosure (x // { allowMissing = true; });
  };
in
{
  imports = [ ];

  nixpkgs.overlays = [ overlay ];

  systemd.services.mmwave-machine = {
    enable = true;
    description = "the mmwave machine client";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = if machine-id >= 0 then ''
        ${mmwave.machine}/bin/mmwave-machine -t -m ${toString machine-id}
      '' else ''
        ${pkgs.bash}/bin/bash -c echo "missing mmwave-machine"
      '';
    };
  };

  environment.systemPackages = (with pkgs; [
    btop
    helix
    git
    neofetch
  ]) ++ (with mmwave; [
    machine
    discovery
    dashboard
  ]);

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      inherit password;
      extraGroups = [ "wheel" ];
    };
    users.root = {
      inherit password;
    };
  };

  networking = {
    useDHCP = true;
    hostName = hostName;
    wireless = {
      enable = true;
      networks = {
        ammwbase = {
          psk = "mmwavenetwork";
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "yes";
      X11Forwarding = true;
    };
  };
  programs.ssh.startAgent = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  hardware.enableRedistributableFirmware = true;

  environment.etc.nixos = {
    source = ./nixos;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mmwave.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "mmwave.cachix.org-1:51WVqkk3jgt8S5rmsTZVsFvPw06FpTd1niyrFzJ6ucQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = [
      "root"
      user
    ];
  };

  services.avahi = {
    nssmdns4 = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.variables = {
    FLAKE_PATH = "path:${self.outPath}#${hostName}";
    MACHINE_ID = machine-id;
  };

  system.stateVersion = "24.05";
}
