{self, ...} @ inputs: pkgs-input: {
  # Provide flake inputs to system & home-manager config modules
  _module.args = {inherit inputs;};
  home-manager.extraSpecialArgs = {inherit inputs;};

  # Include git revision of config in nixos-verison output
  system.configurationRevision =
    pkgs-input.lib.mkIf (self ? rev) self.rev;

  # pin <nixpkgs> path & registry entry to current nixpkgs input rev
  nix.nixPath = ["nixpkgs=${pkgs-input}"];
  nix.registry.nixpkgs.flake = pkgs-input;

  # FIXME: elsewhere?
  # settings for testing with nixos-rebuild build-vm
  virtualisation.vmVariant = {
    # add some more memory & cores
    virtualisation = {
      memorySize = 4096;
      cores = 2;
    };

    # actually let me log in lol
    users.users.stone.hashedPassword = "$7$CU..../....pX1BnMdsmfGP8dP/.nB.B.$VdyEiIAm1qRMJtNIDfa2Mf5kNPwuJo5/sMEQ8ods/lC";
  };
}
