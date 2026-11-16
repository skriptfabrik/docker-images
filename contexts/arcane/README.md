# @skriptfabrik/docker-images/arcane

Customized [Arcane](https://getarcane.app/) images based on the official
[`getarcaneapp/agent`](https://github.com/orgs/getarcaneapp/packages/container/package/agent)
and [`getarcaneapp/manager`](https://github.com/orgs/getarcaneapp/packages/container/package/manager)
images.

This context builds two separate images from two Dockerfiles:

- [Dockerfile.agent](Dockerfile.agent) – the Arcane agent, published as `arcane-agent`.
- [Dockerfile.manager](Dockerfile.manager) – the Arcane manager, published as `arcane-manager`.

Each image's version follows the upstream `getarcaneapp/agent`/`getarcaneapp/manager`
version pinned in its Dockerfile (`FROM ghcr.io/getarcaneapp/<agent|manager>:<version>`);
this is also what CI uses to derive the published image tags for each image separately
(see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream images

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original `arcane-agent`/`arcane` command (kept as `CMD`).
  Before starting the application, `fileenv` resolves any `<VAR>_FILE` environment
  variable into its corresponding `<VAR>` variable by reading the referenced file's
  contents (and unsets the `_FILE` variable afterwards) — this lets secrets (e.g.
  database credentials, tokens) be supplied via mounted files or Docker/Swarm secrets
  instead of plain environment variables, without requiring any change in Arcane itself.

### Why `fileenv` is still needed

Arcane itself reads `<VAR>_FILE` (and `<VAR>__FILE`) only for a subset of its variables:
the secret-like core settings (`ARCANE_DATABASE_URL`, `ARCANE_ENCRYPTION_KEY`,
`ARCANE_ADMIN_STATIC_API_KEY`, `ARCANE_DEFAULT_ADMIN_PASSWORD`,
`ARCANE_OIDC_ROLE_MAPPINGS`, `ARCANE_AGENT_TOKEN`, `ARCANE_AUTO_LOGIN_PASSWORD`) and the
settings overrides (e.g. `ARCANE_OIDC_CLIENT_SECRET`). Other variables such as
`ARCANE_APP_URL`, `ARCANE_MANAGER_API_URL` or `ARCANE_PORT` have no `_FILE` support
upstream; `fileenv` closes this gap.

### Excluded variables

Some Arcane variables end in `_FILE` but hold a **path** that Arcane opens itself
(certificates and keys), or are resolved by Arcane natively. They are listed in
`FILEENV_EXCLUDE` so `fileenv` leaves them untouched:

| Variable                                                                                 | Agent | Manager |
| ---------------------------------------------------------------------------------------- | :---: | :-----: |
| `ARCANE_AGENT_MTLS_CA_FILE`, `ARCANE_AGENT_MTLS_CERT_FILE`, `ARCANE_AGENT_MTLS_KEY_FILE` |   ✓   |    ✓    |
| `ARCANE_AGENT_TOKEN_FILE`                                                                |   ✓   |         |
| `ARCANE_OIDC_ROLE_MAPPINGS_FILE`                                                         |       |    ✓    |
| `ARCANE_TLS_CERT_FILE`, `ARCANE_TLS_KEY_FILE`                                            |       |    ✓    |
| `SSL_CERT_FILE`                                                                          |   ✓   |    ✓    |

## Usage

```sh
docker run -it --rm \
  -p 3552:3552 \
  -e ARCANE_APP_URL=http://localhost:3552 \
  -e ARCANE_ENCRYPTION_KEY_FILE=/run/secrets/arcane_encryption_key \
  -v ./arcane_encryption_key:/run/secrets/arcane_encryption_key:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v arcane-data:/app/data \
  ghcr.io/skriptfabrik/docker-images/arcane-manager:latest
```

```sh
docker run -it --rm \
  -e ARCANE_MANAGER_API_URL=https://arcane.example.com \
  -e ARCANE_AGENT_TOKEN_FILE=/run/secrets/arcane_agent_token \
  -v ./arcane_agent_token:/run/secrets/arcane_agent_token:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v arcane-agent-data:/app/data \
  ghcr.io/skriptfabrik/docker-images/arcane-agent:latest
```

The agent opens no port; it connects outbound to the manager and stores its enrolled
agent key in `/app/data`, so keep that volume persistent to avoid re-enrolling on every
restart.

Refer to the [official Arcane documentation](https://getarcane.app/docs) for
[environment variables](https://getarcane.app/docs/reference/environment-variables),
volumes, and general configuration — this image does not change Arcane's runtime
behavior beyond the `fileenv`-based secret resolution described above. Any environment
variable Arcane supports (except the excluded ones above) can alternatively be supplied
as `<VAR>_FILE` to have it resolved from a file at startup.
