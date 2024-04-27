{
  # openssh config
  services.openssh = {
    enable = true;

    # completely disable password authentication
    settings.PasswordAuthentication = false;

    # only generate an ed25519 host key
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # default user authorized keys
  users.users.stone.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILGzdc2ZJrNg5368frFnfzNIreeGe7RH5ayYVuM4dUmT" # zweilous
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPfzxRJsns5aoksFDBVIoL7u2StSPB+9kxQmY5ddnD+s stone@cryogonal"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPkOgPfrVj2K1hi7/SL7mTPm9ZqIxv3r57qX7OSR5Eq klang"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAP5RNiw7r4k4g432OTy/N708ptPveywqWK+d0XZDxPe" # termius
  ];

  # dedicated key for deploying with deploy-rs
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC2LTNznIVB4vR+apmxRl43H7zUYZMHvNjaRbJKW4KHO deployment"
  ];
}
