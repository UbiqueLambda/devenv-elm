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

- `env-build`
- `env-ci`
- `env-dry-build`
- `env-fmt`
- `env-lint` (which calls `env-elm-review`)
- `env-up`

## Notes

Nothing here is tested first and very prone to radical changes.
