{ system ? builtins.currentSystem
, env_prefix
}:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  modulesPath = "${pkgs.path}/nixos/modules";
  srvos = (import sources.srvos).modules;

  base = pkgs.nixos {
    imports = [
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };

  web = pkgs.nixos {
    imports = [
      { inherit env_prefix; }
      hosts/web.nix
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };

  gh-runner = pkgs.nixos {
    imports = [
      { inherit env_prefix; }
      hosts/gh-runner.nix
      "${toString modulesPath}/virtualisation/amazon-image.nix"
      "${pkgs.path}/nixos/maintainers/scripts/ec2/amazon-image.nix"
      srvos.nixos.roles-github-actions-runner
      ({...}: { amazonImage.sizeMB = 16 * 1024; })
    ];
  };
in
{
  # Build with nix-build -A <attr>
  image = base.config.system.build.amazonImage;
  web = web.config.system.build.toplevel;
  gh-runner = gh-runner.config.system.build.toplevel;
}
