{ mkYarnPackage, fetchYarnDeps }:
mkYarnPackage {
  pname = "devenv-elm-builder";
  version = "unstable-0.0.1";
  src = ./.;
  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-/A8yL6BiiVz1a068VToq4PhTQjwqfkifeYckuN7A6qw=";
  };
  buildPhase = ''
    export HOME=$(mktemp -d)
    yarn --offline build
  '';
  postInstall = ''
    chmod +x $out/bin/*
  '';
}
