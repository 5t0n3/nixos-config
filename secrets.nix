let
  stone = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+3IqZFhMmrsjR67EnLwPDxfioaQ5r0ZXzA5/1IXR0I stone@simulacrum"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfzxRJsns5aoksFDBVIoL7u2StSPB+9kxQmY5ddnD+s stone@cryogonal"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGzdc2ZJrNg5368frFnfzNIreeGe7RH5ayYVuM4dUmT" # zweilous
  ];
  cryogonal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3dntUaHeHCAKZ/ki0SQ5e7Dvg602RseZvtR1R5XoQ1";
  simulacrum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICL9JQGalPr7Y4f1cez4PKhxNrdSp52/xGnQPXbyCJLC";
  nacli = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdoVReGphY1HsqCLgyirFBXOTgXHsc2940JLePWsnKg";
in {
  # cryogonal
  "machines/cryogonal/secrets/wg-privkey.age".publicKeys =
    stone
    ++ [cryogonal];

  # simulacrum
  "machines/simulacrum/secrets/pg13-config.age".publicKeys =
    stone
    ++ [simulacrum];

  # nacli
  "machines/nacli/secrets/vaultwarden-env.age".publicKeys = stone ++ [nacli];
}
