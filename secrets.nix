let
  stone = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOClmVzgghnkYd7nkLra97lhrdP+f524c3yz6uebBrjJ stone@solosis"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+3IqZFhMmrsjR67EnLwPDxfioaQ5r0ZXzA5/1IXR0I stone@simulacrum"
  ];
  solosis =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtnVjsCoTunr6ePI25yiRgzvHg5hOVsFEttGcA0wjsV";
  simulacrum =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICL9JQGalPr7Y4f1cez4PKhxNrdSp52/xGnQPXbyCJLC";
in {
  "secrets/wifi-psks.age".publicKeys = stone ++ [ solosis ];

  # solosis
  "machines/solosis/secrets/rsync-secrets.age".publicKeys = stone
    ++ [ solosis ];
  "machines/solosis/secrets/pg13-devconfig.age".publicKeys = stone
    ++ [ solosis ];
  "machines/solosis/secrets/wg-solosis.age".publicKeys = stone ++ [ solosis ];

  # simulacrum
  "machines/simulacrum/secrets/pg13-config.age".publicKeys = stone
    ++ [ simulacrum ];
}
