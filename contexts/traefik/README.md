# @skriptfabrik/docker-images/traefik

Customized [Traefik](https://github.com/traefik/traefik) image based on the official
[`traefik`](https://hub.docker.com/_/traefik) image, with bundled
[local plugins](https://doc.traefik.io/traefik/plugins/) that are enabled per container
via an environment variable.

The image version follows the upstream `traefik` version pinned in the
[Dockerfile](Dockerfile) (`FROM traefik:v<version>`); this is also what CI uses to derive
the published image tags (see the [root README](../../README.md#continuous-integration)).

## Image tags

The tags `<major>.<minor>.<patch>`, `<major>.<minor>`, `<major>` and `latest` are derived
from the Traefik version only. A plugin-only update (a Renovate PR that only bumps
`CROWDSEC_BOUNCER_PLUGIN_VERSION`) therefore overwrites the existing tags of the same
Traefik version (e.g. `3.7.17`, `3.7`, `3` and `latest`), and tooling that compares tags
(e.g. Renovate in consuming repositories) does not see it. Consumers who need to pick up
every plugin update should pin by digest (`traefik:3.7.17@sha256:…`) or use the
`sha-<commit>` tag that every build publishes as well.

## Changes over the upstream image

With `--experimental.plugins.*`, Traefik downloads every plugin from `plugins.traefik.io`
on each start. If the download fails (registry or GitHub unreachable or rate-limited),
Traefik disables all plugins, and every router using one of their middlewares breaks.
Plugin versions in the static configuration are also invisible to Renovate.

- **Bundled local plugins** – the plugins are part of the image under
  `/plugins-local/src/<module>` (Traefik resolves `./plugins-local` relative to `/`, the
  image has no `WORKDIR`), so Traefik loads them as local plugins
  (`--experimental.localplugins.*`) and never downloads anything at startup. Their
  versions are build arguments with a `# renovate:` comment, updated by Renovate together
  with the Traefik version.
- **Plugin manifest** – `/plugins-local/plugins.txt` lists the bundled plugins as
  `<name> <module>`:

  | Name       | Module                                                                                                                       |
  | ---------- | ---------------------------------------------------------------------------------------------------------------------------- |
  | `crowdsec` | [`github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin`](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin) |

- **Entrypoint wrapper** – `/docker-entrypoint.sh` wraps the original `/entrypoint.sh`.
  For every name in `TRAEFIK_CUSTOM_LOCAL_PLUGINS` (separated by commas or spaces), it
  appends `--experimental.localplugins.<name>.modulename=<module>` to the arguments,
  provided the plugin is bundled. Unknown or missing plugins are skipped with a warning on
  stderr, or abort the start with exit code `1` when `TRAEFIK_CUSTOM_LOCAL_PLUGINS_STRICT`
  is `true` (see [Environment variables](#environment-variables)). The arguments are only
  appended when Traefik itself is started (a leading flag, or `traefik` followed by
  nothing or a flag), not for subcommands like `traefik version` or
  `traefik healthcheck`, or for shell commands. They are appended, not prepended, so the
  original entrypoint still detects a leading flag and prepends `traefik`.
- **Original command kept as `CMD`** – overriding `ENTRYPOINT` resets the `CMD` inherited
  from the upstream image, so the upstream command (`traefik`) is set again explicitly.

With `TRAEFIK_CUSTOM_LOCAL_PLUGINS` unset or empty, the image behaves like the upstream
image.

### Environment variables

| Variable                              | Description                                                                                                                                                                                                                       | Default |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `TRAEFIK_CUSTOM_LOCAL_PLUGINS`        | Names of the bundled local plugins to enable (see `/plugins-local/plugins.txt`), separated by commas or spaces                                                                                                                    | `""`    |
| `TRAEFIK_CUSTOM_LOCAL_PLUGINS_STRICT` | `true` aborts the start with an error and exit code `1` if a listed plugin is unknown or missing, so a typo fails the deployment instead of only breaking the routers that use the plugin; otherwise it is skipped with a warning | `false` |

### Why a wrapper instead of plain environment variables

Traefik reads its static configuration from exactly one source: a configuration file,
CLI flags or `TRAEFIK_*` environment variables, whichever comes first
(`cmd/traefik/traefik.go`). A deployment that passes flags would ignore an image-level
`TRAEFIK_EXPERIMENTAL_LOCALPLUGINS_<NAME>_MODULENAME`, so the wrapper adds flags instead.

### Why the `TRAEFIK_CUSTOM_` prefix

All environment variables evaluated by the image itself use the `TRAEFIK_CUSTOM_` prefix.
Traefik only reads variables that start with `TRAEFIK_` followed by a root field of its
static configuration (`GLOBAL`, `ENTRYPOINTS`, `EXPERIMENTAL`, `CORE`, …, see
`paerser/env/filter.go`). `CUSTOM` doesn't match any of them, so these variables never
end up in Traefik's configuration, even if Traefik runs without flags. A name like
`TRAEFIK_EXPERIMENTAL_LOCAL_PLUGINS` would be read and make Traefik fail with
`field not found`.

## Usage

```sh
docker run -d --name traefik \
  -p 80:80 \
  -e TRAEFIK_CUSTOM_LOCAL_PLUGINS=crowdsec \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/skriptfabrik/docker-images/traefik:latest \
  --entrypoints.web.address=:80 \
  --providers.docker=true
```

The middleware then references the plugin by its name, e.g. with labels:

```yaml
traefik.http.middlewares.crowdsec.plugin.crowdsec.enabled: "true"
```

Refer to the [official Traefik documentation](https://doc.traefik.io/traefik/) for the
configuration — this image does not change Traefik's runtime behavior beyond the bundled
local plugins described above.
