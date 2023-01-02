let
  stone = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOClmVzgghnkYd7nkLra97lhrdP+f524c3yz6uebBrjJ stone@solosis"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+3IqZFhMmrsjR67EnLwPDxfioaQ5r0ZXzA5/1IXR0I stone@simulacrum"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPZCD9GNDRshukMA6onTDPdzNGbeo/s0S9ZrqBR1AXn stone@spiritomb"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfzxRJsns5aoksFDBVIoL7u2StSPB+9kxQmY5ddnD+s stone@cryogonal"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOMasuwXQAk0h0RW/4m+ufqfdTeHa2nfRhApll54Fvn stone@klefki"
  ];
  cryogonal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3dntUaHeHCAKZ/ki0SQ5e7Dvg602RseZvtR1R5XoQ1";
  solosis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtnVjsCoTunr6ePI25yiRgzvHg5hOVsFEttGcA0wjsV";
  simulacrum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICL9JQGalPr7Y4f1cez4PKhxNrdSp52/xGnQPXbyCJLC";
  klefki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH1CxdrXvZ0zyN3x0/Ui+YEvAbG1r4MtiX2yMz7nI5XU";
in {
  "secrets/wifi-psks.age".publicKeys = stone ++ [solosis cryogonal];

  # cryogonal
  "machines/cryogonal/secrets/wg-privkey.age".publicKeys =
    stone
    ++ [cryogonal];

  # solosis
  "machines/solosis/secrets/rsync-secrets.age".publicKeys =
    stone
    ++ [solosis];
  "machines/solosis/secrets/pg13-devconfig.age".publicKeys =
    stone
    ++ [solosis];
  "machines/solosis/secrets/wg-solosis.age".publicKeys = stone ++ [solosis];

  # simulacrum
  "machines/simulacrum/secrets/pg13-config.age".publicKeys =
    stone
    ++ [simulacrum];

  # klefki
  "machines/klefki/secrets/vaultwarden-env.age".publicKeys = stone ++ [klefki];
}
