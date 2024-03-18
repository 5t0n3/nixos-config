{pkgs, ...}: {
  # set fish as global default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # trying out the starship prompt
  # TODO: figure out config
  programs.starship.enable = true;

  # create default stone user
  users.users.stone = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
