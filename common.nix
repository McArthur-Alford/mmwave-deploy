{ pkgs, self, nodeHostName, mmwave, ... }:
let
  user = "mmwave";
  password = "mmwave";
  overlay = _final: super: {
    makeModulesClosure = x:
      super.makeModulesClosure (x // { allowMissing = true; });
  };
in
{
  imports = [ ];

  nixpkgs.overlays = [ overlay ];

  environment.systemPackages = (with pkgs; [
    btop
    helix
    git
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
    hostName = nodeHostName;
    wireless = {
      enable = true;
      networks = {
        ammwbase = {
          psk = "mmwave";
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
  environment.etc."cachix-agent.token" = {
    source = "${self.outPath}/agent-token.token";
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


  services.cachix-agent.enable = true;

  environment.variables = {
    FLAKE_PATH = "path:${self.outPath}#${nodeHostName}";
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates  = "*-*-* *:20:00";
  system.autoUpgrade.flake  = "github:McArthur-Alford/mmwave-deploy#nixosConfigurations.${nodeHostName}";
  system.autoUpgrade.flags  = ["--refresh"];
  system.autoUpgrade.randomizedDelaySec = "5m";

  system.stateVersion = "24.05";
}
