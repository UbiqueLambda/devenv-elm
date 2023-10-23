{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
let
  elm = "${pkgs.elmPackages.elm}/bin/elm";
  elm-format = config.pre-commit.hooks.elm-format.entry;
  elm-review = "${pkgs.elmPackages.elm-review}/bin/elm-review --template UbiqueLambda/elm-review-config";
  prettier = config.pre-commit.hooks.prettier.entry;

  dryBuild = "${elm} make src/Main.elm --output=/dev/null";
  elmFiles = "^src/.+\\.elm$";
in
{
  languages.elm.enable = true;

  processes = {
    reactor.exec = "${elm} reactor";
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
    env-build.exec = ''
      set -euo pipefail
      mkdir -p ./result
      cp -r ./assets/* -t ./result
      rm ./result/index*.js
      elm make src/Main.elm --optimize --output=./result/index.js
      cat ./assets/index.append.js >> ./result/index.js
    '';
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
      procfilescript=$(nix build "${self}#devenv-up" --no-link --print-out-paths --accept-flake-config --impure)
      exec "$procfilescript" "$@"
    '';
  };
}
