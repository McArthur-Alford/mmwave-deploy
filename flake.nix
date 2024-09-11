{
  nixConfig = {
    extra-substituters = [
      "https://raspberry-pi-nix.cachix.org"
      "https://mmwave.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    extra-experimental-features = "nix-command flakes";
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
      "mmwave.cachix.org-1:51WVqkk3jgt8S5rmsTZVsFvPw06FpTd1niyrFzJ6ucQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    flake-utils.url = "github:numtide/flake-utils";
    mmwave.url = "github:uqiotstudio/mmwave-rewrite";
    deploy-rs.url = "github:serokell/deploy-rs";
    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
  };

  outputs =
    inputs:
    with inputs;
    let
      nodes = {
        pi4 = {
          name = "pi4";
          system = "aarch64-linux";
          format = "sd-aarch64";
          inherit nixpkgs;
          modules = [
            ./common.nix
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
          configModules = [ ./formats/sd-aarch64.nix ];
        };
        pi4-desktop = {
          name = "pi4-desktop";
          system = "aarch64-linux";
          format = "sd-aarch64";
          inherit nixpkgs;
          modules = [
            ./common.nix
            ./desktop.nix
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
          configModules = [ ./formats/sd-aarch64.nix ];
        };
        pi0 = {
          name = "pi0";
          system = "aarch64-linux";
          format = "sd-aarch64";
          inherit nixpkgs;
          modules = [
            ./common.nix
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
          configModules = [ ./formats/sd-aarch64.nix ];
        };
        # pi5 = {
        #   name = "pi5";
        #   system = "aarch64-linux";
        #   format = "sd-aarch64";
        #   inherit nixpkgs;
        #   modules = [
        #     ./common.nix
        #     # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #     # inputs.raspberry-pi-nix.nixosModules.raspberry-pi
        #     ./pi5.nix
        #   ];
        # };
      };
      buildGenerator =
        {
          node,
          machine-id ? -1,
        }:
        inputs.nixos-generators.nixosGenerate {
          inherit (node) system;
          inherit (node) format;
          inherit (node) modules;
          specialArgs = {
            inherit nixpkgs;
            inherit self;
            inherit (node) name;
            inherit machine-id;
            inherit inputs;
            mmwave = mmwave.packages.${node.system};
          };
        };
      buildConfiguration =
        {
          node,
          machine-id ? -1,
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit nixpkgs;
            inherit self;
            inherit (node) name;
            inherit machine-id;
            inherit inputs;
            mmwave = mmwave.packages.${node.system};
          };
          inherit (node) system;
          modules = node.modules ++ node.configModules;
        };
    in
    {
      generators = builtins.listToAttrs (
        map
          (node: {
            inherit (node) name;
            value = buildGenerator { inherit node; };
          })
          [
            (nodes.pi4)
            (nodes.pi0)
            (nodes.pi4-desktop)
            # (nodes.pi5)
          ]
      );

      nixosConfigurations = builtins.listToAttrs (
        map
          (node: {
            name = if node.machine-id < 0 then "${node.name}" else "${node.name}-${toString node.machine-id}";
            value = buildConfiguration {
              inherit node;
              inherit (node) machine-id;
            };
          })
          [
            (nodes.pi4 // { machine-id = -1; })
            # (nodes.pi4 // { machine-id = 0; })
            (nodes.pi4 // { machine-id = 1; })
            (nodes.pi4 // { machine-id = 2; })
            (nodes.pi4 // { machine-id = 3; })
            (nodes.pi4-desktop // { machine-id = 0; })
            # (nodes.pi0 // { machine-id = 3; })
            # (nodes.pi5 // { machine-id = 100; })
          ]
      );

      deploy.nodes = {
        development = {
          hostname = "192.168.1.17";
          sshUser = "root";
          profilesOrder = [ "system" ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4-desktop-0;
          };
        };
        machine-0 = {
          hostname = "machine-0.local";
          sshUser = "root";
          profilesOrder = [ "system" ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4-desktop-0;
          };
        };
        machine-1 = {
          hostname = "machine-1.local";
          sshUser = "root";
          profilesOrder = [ "system" ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4-1;
          };
        };
        machine-2 = {
          hostname = "machine-2";
          sshUser = "root";
          profilesOrder = [ "system" ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4-2;
          };
        };
        machine-3 = {
          hostname = "machine-3.local";
          sshUser = "root";
          profilesOrder = [ "system" ];
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pi4-3;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
