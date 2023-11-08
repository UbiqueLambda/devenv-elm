{ mkYarnPackage, fetchYarnDeps }:
mkYarnPackage {
  pname = "devenv-elm-builder";
  version = "unstable-0.0.1";
  src = ./.;
  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-gv+GHZ3IGtA1fpI/NEIge+0qSGIXC0rIsOuZxH6f4Yw=";
  };
  buildPhase = ''
    export HOME=$(mktemp -d)
    yarn --offline build
  '';
  postInstall = ''
    chmod +x $out/bin/*
  '';
}
