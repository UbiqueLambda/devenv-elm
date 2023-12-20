{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
let
  inherit (config.languages.elm) binElm;
  builder = pkgs.callPackage ./builder { };
in
{
  languages.elm.dryBuild = "${binElm} make src/Main.elm --output=/dev/null";
  languages.elm.files = "^src/.+\\.elm$";
  languages.elm.raiseFlakeOutput = "${self}#devenv-up";

  packages = [
    builder
  ];

  processes = {
    reactor.exec = ''
      exec ${builder}/bin/env-elm-start "$@"
    '';
  };

  scripts = {
    env-build.exec = ''
      exec ${builder}/bin/env-elm-build "$@"
    '';
  };
}
