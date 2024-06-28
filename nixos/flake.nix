{
  inputs.mmwave-deploy.url = "github:McArthur-Alford/mmwave-deploy";

  outputs = inputs: with inputs; {
    nixosConfigurations = mmwave-deploy.nixosConfigurations;
  };
}
