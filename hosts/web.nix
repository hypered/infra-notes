{ config
, lib
, pkgs
, ... }:
{

  options = {
    env_prefix = lib.mkOption {
      description = "A string reflecting the environment";
      type = lib.types.str;
    };
  };

  config = {
    networking.hostName = "host-1";
    networking.domain = "${config.env_prefix}.example.com";

    networking.firewall.allowedTCPPorts = [80];

    services.nginx = {
      enable = true;
      package = pkgs.nginxMainline;
      additionalModules = [];
      recommendedGzipSettings = true;
      virtualHosts."_" = {
        locations = {
          "/" = {
            extraConfig = "return 200 \"${config.networking.hostName}.${config.networking.domain}.\";";
          };
        };
      };
    };

    users = {
      users = {
        root = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWw6Hpr9E1RyDPgGfFsVmgxfk0SzIkx5vzsq7BxWTLt thu on frame"
          ];
        };
      };
    };
  };
}
