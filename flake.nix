{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    inputs@{ self, ... }:
    let
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree);
      packages = forAllSystems (system: import ./packages.nix { inherit self inputs system; });
      apps = forAllSystems (system: import ./apps.nix { inherit self inputs system; });
    };
}
