{
  # https://github.com/NixOS/nixos-hardware/blob/cc66fddc6cb04ab479a1bb062f4d4da27c936a22/lenovo/thinkpad/t14/default.nix
  boot.kernelParams = [
    "acpi_backlight=native"
    "psmouse.synaptics_intertouch=0"
  ];

  hardware.trackpoint.enable = true;
  hardware.trackpoint.emulateWheel = true;

  # power
  services.tlp.enable = true;

  # ssd(eez)
  services.fstrim.enable = true;
}
