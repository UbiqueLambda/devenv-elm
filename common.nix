{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
{
  options = {
    languages.elm = {
      raiseFlakeOutput = mkOption {
        type = lib.types.str;
      };
      dryBuild = mkOption {
        type = lib.types.str;
      };
      files = mkOption {
        type = lib.types.str;
      };
      binElm = mkOption {
        type = lib.types.str;
        default = "${pkgs.elmPackages.elm}/bin/elm";
      };
      binReview = mkOption {
        type = lib.types.str;
        default = "${pkgs.elmPackages.elm-review}/bin/elm-review";
      };
      binFormat = mkOption {
        type = lib.types.str;
        default = config.pre-commit.hooks.elm-format.entry;
      };
      binPrettier = mkOption {
        type = lib.types.str;
        default = config.pre-commit.hooks.prettier.entry;
      };
      reviewTemplate = mkOption {
        type = lib.types.str;
        default = "UbiqueLambda/elm-review-config";
      };
      reviewCmd = mkOption {
        type = lib.types.str;
        default = with config.languages.elm;
          "${binReview} --template ${lib.strings.escapeShellArg reviewTemplate} $(cat \"$DEVENV_ROOT/.elm-review\" || true)";
      };
    };
  };
  config = with config.languages.elm; with lib; {
    processes = {
      reactor.exec = "${binElm} reactor";
    };

    packages = with pkgs; [ elmPackages.elm-graphql ];

    pre-commit = {
      hooks = {
        actionlint.enable = true;
        elm-format = {
          enable = true;
          files = mkForce files;
        };
        elm-make = {
          enable = true;
          entry = dryBuild;
          files = files;
          pass_filenames = false;
        };
        elm-review = {
          enable = true;
          entry = mkForce "${reviewCmd}";
          files = mkForce files;
        };
        nixpkgs-fmt = {
          enable = true;
          files = mkForce "^.+\\.nix$";
        };
        prettier.enable = true;
      };
      settings.prettier.write = false;
    };

    scripts = {
      env-dry-build.exec = dryBuild;
      env-lint.exec = "pre-commit run -a";
      env-fmt.exec = ''
        set -euo pipefail
        ${binFormat} "$DEVENV_ROOT/src/"
        ${binPrettier} -w "$DEVENV_ROOT"
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
        procfilescript=$(nix build "${raiseFlakeOutput}" --no-link --print-out-paths --accept-flake-config --impure)
        exec "$procfilescript" "$@"
      '';
    };
  };
}
