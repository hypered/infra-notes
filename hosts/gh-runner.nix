{ config
, lib
, pkgs
, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports = [
    "${sources.sops-nix}/modules/sops"
  ];

  options = {
    env_prefix = lib.mkOption {
      description = "A string reflecting the environment";
      type = lib.types.str;
    };
  };

  config = {

    networking.hostName = "gh-runner-1";
    networking.domain = "${config.env_prefix}.example.com";

    networking.firewall.allowedTCPPorts = [80 443];

    roles.github-actions-runner = {
      # Manually comment/uncomment for now
      url = "https://github.com/noteed/infra-notes";
      tokenFile = config.sops.secrets.gh-runner-token.path;
    };

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

    # Manually comment/uncomment for now
    sops.secrets.gh-runner-token = {
      sopsFile = ../secrets/gh-runner.yaml;
      key = "token";
    };
  };
}
