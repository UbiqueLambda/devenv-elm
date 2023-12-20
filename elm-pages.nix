{ self, pkgs, lib, config, ... }: with lib;
# https://devenv.sh/reference/options/
let
  binPages = "${pkgs.elmPackages.elm-pages}/bin/elm-pages";
in
{
  languages.elm.dryBuild = "${binPages} gen --base \"$DEVENV_ROOT\"";
  languages.elm.files = "^app/.+\\.elm$";
  languages.elm.raiseFlakeOutput = "${self}#devenv-pages-up";

  packages = with pkgs; [ elmPackages.elm-pages ];

  processes = {
    dev.exec = ''
      exec ${binPages} dev --base \"$DEVENV_ROOT\" "$@"
    '';
  };

  scripts = {
    env-build.exec = ''
      exec ${binPages} build --base \"$DEVENV_ROOT\" "$@"
    '';
  };
}
