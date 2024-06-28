{
  nixConfig = {
    extra-substituters = [
      "https://mmwave.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    extra-experimental-features = "nix-command flakes";
    extra-trusted-public-keys = [
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
  };

  outputs = inputs: with inputs;
  let
    deployPkgs = import nixpkgs {
      inherit system;
      overlays = [
        deploy-rs.overlay # or deploy-rs.overlays.default
        (self: super: { deploy-rs = { inherit (pkgs) deploy-rs; lib = super.deploy-rs.lib; }; })
      ];
    };
    nodes = [
      {
        name = "pi4";
        system = "aarch64-linux";
        format = "sd-aarch64";
        inherit nixpkgs;
        modules = [
          ./common.nix
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ];
      }
    ];
    buildGenerator = node:
      inputs.nixos-generators.nixosGenerate {
        inherit (node) system;
        inherit (node) format;
        inherit (node) modules;
        specialArgs = {
          inherit nixpkgs;
          inherit self;
          nodeHostName = node.name;
          inherit inputs;
          mmwave = mmwave.packages.${node.system};
        };
      };
    buildConfiguration = node:
      let
        generated = buildGenerator node;
      in
      nixpkgs.lib.nixosSystem {
        inherit (generated) system;
        modules = node.modules ++ [ ./formats/${generated.format}.nix ];
        inherit (generated) specialArgs;
      };
  in
  {
    generators = builtins.listToAttrs (
      map
        (node: { inherit (node) name; value = buildGenerator node; })
        nodes
    );

    nixosConfigurations = builtins.listToAttrs (
      map
        (node: { inherit (node) name; value = buildConfiguration node; })
        nodes
    );

    deploy.nodes.pi4 = {
      hostname = "pi4";
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.pi4;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
