{
  # openssh config
  services.openssh = {
    enable = true;

    settings = {
      # completely disable password authentication
      PasswordAuthentication = false;

      # require FIDO2 device pin if used
      PubkeyAuthOptions = "verify-required";
    };

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAP5RNiw7r4k4g432OTy/N708ptPveywqWK+d0XZDxPe" # termius
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIPumr6HY35KGnXcL7rM1+3h4GN5Yqv7d0rOBGdcpclh/AAAABHNzaDo="
  ];
}
