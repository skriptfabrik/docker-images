# @skriptfabrik/docker-images

[![CI](https://github.com/skriptfabrik/docker-images/actions/workflows/ci.yml/badge.svg)](https://github.com/skriptfabrik/docker-images/actions/workflows/ci.yml)

> Customized Docker Images

## Usage

This is a mono repository with many different customized Docker images.
Please take a closer look at the detailed instructions for the individual image:

- [Arcane](contexts/arcane/README.md)
- [Hoppscotch](contexts/hoppscotch/README.md)
- [Infisical](contexts/infisical/README.md)
- [MCP Auth Proxy](contexts/mcp-auth-proxy/README.md)
- [n8n](contexts/n8n/README.md)
- [n8n-mcp](contexts/n8n-mcp/README.md)
- [Nagios](contexts/nagios/README.md)
- [Open WebUI](contexts/open-webui/README.md)
- [Outline](contexts/outline/README.md)
- [Plane](contexts/plane/README.md)
- [SearXNG](contexts/searxng/README.md)
- [Semaphore](contexts/semaphore/README.md)

## Repository structure

```
.
├── .devcontainer/   Dev Container configuration for this repository
├── .github/         GitHub Actions workflows, CODEOWNERS, Dependabot config
├── .mise/           mise hooks (e.g. postinstall)
├── contexts/        One directory per Docker image, each a self-contained build context
│   ├── arcane/
│   ├── hoppscotch/
│   ├── infisical/
│   ├── mcp-auth-proxy/
│   ├── n8n/
│   ├── n8n-mcp/
│   ├── nagios/
│   ├── open-webui/
│   ├── outline/
│   ├── plane/
│   ├── searxng/
│   ├── semaphore/
├── mise.toml        Tool versions and tasks (managed via mise)
└── package.json     Node.js tooling for repo-wide linting (commitlint, Prettier)
```

Each subdirectory under `contexts/` is an independent Docker build context containing at
least a `Dockerfile` and a `README.md` describing the image. New images are added by
creating a new directory here.

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

### Adding or changing a Docker image

1. Create or edit the relevant directory under `contexts/<image>/`.
2. Add/update a `README.md` in that directory describing the image, its build args,
   and usage.
3. Open a pull request. CI only builds the Docker image(s) whose context changed
   (see [Continuous Integration](#continuous-integration) below).

## Continuous Integration

CI runs via [.github/workflows/ci.yml](.github/workflows/ci.yml) on pull requests and on
pushes to `main`:

- **Lint Commit Messages** – validates commit messages on pull requests.
- **Detect Changes** – determines which files/`contexts/*` directories changed to scope the
  following jobs.
- **Lint Prettier Files** – runs Prettier `--check` on changed formattable files.
- **Build Docker Image** (one job per image, e.g. `n8n`) – builds the image for
  the changed context, tags it based on the upstream base image version and the commit
  SHA, and pushes it to the GitHub Container Registry (`ghcr.io`) on pushes to `main`.

Dependencies (GitHub Actions, devcontainer features, npm packages, and each Docker
image's base image/packages) are kept up to date automatically via
[Dependabot](.github/dependabot.yml).

## Contributing

- Ownership of specific paths is defined in [.github/CODEOWNERS](.github/CODEOWNERS).
- Please open a pull request against `main`
- CI must pass (commit lint, Prettier, and the Docker build for any changed image) before merging.
