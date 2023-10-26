{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
let
  inherit (config.languages.elm) binElm;
in
{
  languages.elm.dryBuild = "${binElm} make src/Main.elm --output=/dev/null";
  languages.elm.files = "^src/.+\\.elm$";
  languages.elm.raiseFlakeOutput = "${self}#devenv-up";

  processes = {
    reactor.exec = "${binElm} reactor";
  };

  scripts = {
    env-build.exec = ''
      set -euo pipefail
      mkdir -p ./result
      cp -r ./assets/* -t ./result
      rm ./result/index*.js
      ${binElm} make src/Main.elm --optimize --output=./result/index.js
      cat ./assets/index.append.js >> ./result/index.js
    '';
  };
}
