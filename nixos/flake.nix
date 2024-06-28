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

  inputs.mmwave-deploy.url = "github:McArthur-Alford/mmwave-deploy";

  outputs = inputs: with inputs; {
    nixosConfigurations = mmwave-deploy.nixosConfigurations;
  };
}
