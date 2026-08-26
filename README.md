# @skriptfabrik/docker-images

[![CI](https://github.com/skriptfabrik/docker-images/actions/workflows/ci.yml/badge.svg)](https://github.com/skriptfabrik/docker-images/actions/workflows/ci.yml)

> Customized Docker Images

## Usage

This is a mono repository with many different customized Docker images.

## Repository structure

```
.
├── .devcontainer/   Dev Container configuration for this repository
├── .github/         GitHub Actions workflows, CODEOWNERS, Dependabot config
├── .mise/           mise hooks (e.g. postinstall)
├── mise.toml        Tool versions and tasks (managed via mise)
└── package.json     Node.js tooling for repo-wide linting (commitlint, Prettier)
```

## Getting started

This repository uses [mise](https://mise.jdx.dev/) to manage tool versions (Node.js, pnpm)
and [devcontainers](https://containers.dev/) for a ready-to-use development environment.

### Using the Dev Container

Open the repository in VS Code and reopen it in the Dev Container
(`Dev Containers: Reopen in Container`). This automatically installs mise, the pinned
tool versions, and the Node.js dependencies via the `postCreateCommand` hook.

### Manual setup

```sh
mise install
mise run install
```

This installs Node.js and pnpm at the pinned versions and installs the npm dependencies
used for linting (`commitlint`, `prettier`).

## Development workflow

### Commit messages

Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/)
specification (enforced by `commitlint`, see [.commitlintrc.mjs](.commitlintrc.mjs)) and are
linted on every pull request.

```sh
pnpm commitlint --from <base-sha> --to <head-sha>
```

### Formatting

Repository files (`*.js`, `*.json`, `*.md`, `*.yml`, …) are formatted with
[Prettier](https://prettier.io/).

```sh
pnpm prettier --check .
pnpm prettier --write .
```

## Continuous Integration

CI runs via [.github/workflows/ci.yml](.github/workflows/ci.yml) on pull requests and on
pushes to `main`:

- **Lint Commit Messages** – validates commit messages on pull requests.
- **Lint Prettier Files** – runs Prettier `--check` on changed formattable files.

## Contributing

- Ownership of specific paths is defined in [.github/CODEOWNERS](.github/CODEOWNERS).
- Please open a pull request against `main`
- CI must pass (commit lint, and Prettier) before merging.
