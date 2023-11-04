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

## Notes

Nothing here is tested first and very prone to radical changes.
