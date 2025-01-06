{ config
, lib
, pkgs
, ... }:
{
  imports = [
  ];

  users = {
    users = {
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWw6Hpr9E1RyDPgGfFsVmgxfk0SzIkx5vzsq7BxWTLt thu on frame"
        ];
      };
    };
  };
}
