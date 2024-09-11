{ inputs, lib, ... }:
{
  imports = [ inputs.raspberry-pi-nix.nixosModules.raspberry-pi ];
  system.build.sdImage = lib.mkForce true;
}
