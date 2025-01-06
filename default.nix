{ configuration ? ./configuration.nix
, system ? builtins.currentSystem
, env_prefix
}:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  modulesPath = "${pkgs.path}/nixos/modules";

  base = pkgs.nixos {
    imports = [
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };

  target = pkgs.nixos {
    imports = [
      { inherit env_prefix; }
      configuration
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };
in
{
  # Build with nix-build -A <attr>
  image = base.config.system.build.amazonImage;
  toplevel = target.config.system.build.toplevel;
}
