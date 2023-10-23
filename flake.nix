{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";
    yafas = {
      url = "https://flakehub.com/f/UbiqueLambda/yafas/0.1.0.tar.gz";
      inputs.systems.follows = "systems";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { nixpkgs, devenv, yafas, ... } @ inputs: yafas.allSystems nixpkgs
    ({ system, ... }:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;
        devShell = devShells.default;
        devShells.default = devShells.elm;
        devShells.elm = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [ ./elm.nix ];
        };
        devShells.elm-pages = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [ ./elm-pages.nix ];
        };
        packages.devenv-up = devShells.elm.config.procfileScript;
        packages.devenv-pages-up = devShells.elm-pages.config.procfileScript;
      });
}
