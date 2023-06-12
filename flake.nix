{
  description = "dhall-ssh-config nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      mkApp = pkgs: extraArgs:
        let
          args = {
            root = ./.;
            name = "dhall-ssh-config";
            returnShellEnv = false;
          } // extraArgs;
          pkg = pkgs.haskellPackages.developPackage args;
          withCabal = pkg:
            pkg.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [ pkgs.cabal-install ];
            });
        in if args.returnShellEnv then withCabal pkg else pkg;
    in flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.dhall-ssh-config = mkApp pkgs { };
        packages.default = packages.dhall-ssh-config;
        devShells.default = mkApp pkgs { returnShellEnv = true; };
      }) // {
        overlays.default = final: prev: { dhall-ssh-config = mkApp final { }; };
      };
}
