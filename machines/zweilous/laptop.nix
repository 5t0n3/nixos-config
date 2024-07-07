{pkgs, ...}: {
  # basicaly all taken from nixos-hardware repo
  hardware.cpu.intel.updateMicrocode = true;

  # ssds go brr
  services.fstrim.enable = true;

  # intel graphics stuffs
  boot.initrd.kernelModules = ["i915"];
  environment.variables.VDPAU_DRIVER = "va_gl";
  hardware.graphics.extraPackages = with pkgs; [
    intel-vaapi-driver
    libvdpau-va-gl
    intel-media-driver
  ];

  # power management is a thing ig?
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 1;
    };
  };
}
