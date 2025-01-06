{ configuration ? ./configuration.nix
, system ? builtins.currentSystem
}:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  modulesPath = "${pkgs.path}/nixos/modules";

  os = pkgs.nixos {
    imports = [
      configuration
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };
in
{
  # Build with nix-build -A <attr>
  image = os.config.system.build.amazonImage;
  toplevel = os.config.system.build.toplevel;
}
