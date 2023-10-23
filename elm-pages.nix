{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
let
  elm = "${pkgs.elmPackages.elm}/bin/elm";
  elm-pages = "${pkgs.elmPackages.elm-pages}/bin/elm-pages";
  elm-format = config.pre-commit.hooks.elm-format.entry;
  elm-review = "${pkgs.elmPackages.elm-review}/bin/elm-review --template UbiqueLambda/elm-review-config";
  prettier = config.pre-commit.hooks.prettier.entry;

  dryBuild = "${elm-pages} gen --base \"$DEVENV_ROOT\"";
  elmFiles = "^app/.+\\.elm$";
in
{
  languages.elm.enable = true;

  packages = with pkgs; [ elmPackages.elm-pages ];

  processes = {
    dev.exec = "${elm-pages} dev --base \"$DEVENV_ROOT\"";
  };

  pre-commit = {
    hooks = {
      actionlint.enable = true;
      elm-format = {
        enable = true;
        files = mkForce elmFiles;
      };
      elm-make = {
        enable = true;
        entry = dryBuild;
        files = elmFiles;
        pass_filenames = false;
      };
      elm-review = {
        #enable = true;
        entry = mkForce elm-review;
        files = mkForce elmFiles;
      };
      nixpkgs-fmt = {
        enable = true;
        files = mkForce "^env/.+\\.nix$";
      };
      prettier.enable = true;
    };
    settings.prettier.write = false;
  };

  scripts = {
    env-dry-build.exec = dryBuild;
    env-build.exec = "${elm-pages} build --base \"$DEVENV_ROOT\"";
    env-lint.exec = "pre-commit run -a";
    env-fmt.exec = ''
      set -euo pipefail
      ${elm-format} "$DEVENV_ROOT/src/"
      ${prettier} -w "$DEVENV_ROOT"
    '';

    # "devenv ci" does not exists when on flakes...
    env-ci.exec = ''
      set -euo pipefail
      echo "Commit: $GITHUB_SHA"
      echo "Directory: $DEVENV_ROOT"
      [ -f "$DEVENV_ROOT/elm.json" ] || echo "elm.json is not present"
      pre-commit run --from-ref origin/main --to-ref $GITHUB_SHA
    '';
    # "devenv up" does not work when on flakes...
    env-up.exec = ''
      set -euo pipefail
      procfilescript=$(nix build ${self}#devenv-pages-up --no-link --print-out-paths --accept-flake-config --impure)
      exec "$procfilescript" "$@"
    '';
  };
}
