{ mkYarnPackage, fetchYarnDeps }:
mkYarnPackage {
  pname = "devenv-elm-builder";
  version = "unstable-0.0.1";
  src = ./.;
  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-5/+xcgSIOTaxNQXqphWgzQ1DUmHGZG06LUprVj/xDBI=";
  };
  buildPhase = ''
    export HOME=$(mktemp -d)
    yarn --offline build
  '';
  postInstall = ''
    chmod +x $out/bin/*
  '';
}
