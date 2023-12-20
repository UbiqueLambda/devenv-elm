# devenv-elm

## Getting started

1. Install direnv: https://direnv.net/docs/installation.html
2. Add a .envrc with contents:

```
use flake 'github:UbiqueLambda/devenv-elm#elm' --impure --accept-flake-config
```

If using elm-pages, then replace `#elm` with `#elm-pages`.

## PATH contents

You'll find the following scripts in `$PATH` to help you:

- `env-build` (builds to `dist`)
- `env-ci` (the executable that the CI should call)
- `env-dry-build` (builds without outputting any file)
- `env-fmt` (formats all files with elm-format & prettier)
- `env-gen-sprite` (builds `dist/sprite.svg` bundling all files in `vectors/*.svg`)
- `env-lint` (which calls `env-elm-review`)
- `env-up` (runs elm's reactor, or `elm-pages dev`)

## CI

### GitHub Actions Example

This CI example works OOTB (and tested on an Aarch64 self-hosted runner).

```yaml
name: CI

on:
  pull_request:

jobs:
  check:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: DeterminateSystems/nix-installer-action@main
      - uses: DeterminateSystems/magic-nix-cache-action@main
      - name: Run "devenv ci"
        run: |
          nix develop \
            'https://flakehub.com/f/UbiqueLambda/devenv-elm/0.1.18.tar.gz#elm' --impure --accept-flake-config \
            --command env-ci
```

## Notes

Nothing here is tested first and very prone to radical changes.
