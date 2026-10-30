# @skriptfabrik/docker-images/renovate-ce

Customized [Mend Renovate Community Edition](https://github.com/mend/renovate-ce-ee) image
based on the official [`mend/renovate-ce`](https://github.com/mend/renovate-ce-ee/pkgs/container/renovate-ce)
image. Renovate CE is the self-hosted, long-running variant of
[Renovate](https://docs.renovatebot.com/): it runs as a GitHub App, reacts to webhooks
and schedules dependency update jobs itself.

The image version follows the upstream `mend/renovate-ce` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/mend/renovate-ce:<version>`); this is also what CI
uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

Renovate CE reads its license key and webhook secret only from environment variables
(`MEND_RNV_LICENSE_KEY`, `MEND_RNV_WEBHOOK_SECRET`), which makes it impossible to supply
them as Docker/Swarm secrets.

- **[fileenv](https://github.com/skriptfabrik/fileenv) support** – `/usr/local/bin/fileenv`
  is the first `ENTRYPOINT` step, invoking the original
  `/usr/local/sbin/renovate-entrypoint.sh` directly, and resolves every `<VAR>_FILE`
  environment variable into `<VAR>` (reading the referenced file's contents and unsetting
  the `_FILE` variable afterwards) — this lets secrets such as `MEND_RNV_LICENSE_KEY`,
  `MEND_RNV_WEBHOOK_SECRET` or Renovate's `RENOVATE_SECRETS` (as JSON) be supplied via
  mounted files or Docker/Swarm secrets. The `_FILE` variables Renovate already consumes
  as file paths or flags — `LOG_FILE`, `RENOVATE_ADDITIONAL_CONFIG_FILE`,
  `RENOVATE_CONFIG_FILE`, `RENOVATE_X_DELETE_CONFIG_FILE`,
  `RENOVATE_X_STATIC_REPO_CONFIG_FILE`, and `SSL_CERT_FILE` — are excluded from `fileenv`
  via `FILEENV_EXCLUDE` and left to Renovate.
- **Original command kept as `CMD`** – overriding `ENTRYPOINT` resets the `CMD` inherited
  from the upstream image, so the upstream command
  (`/usr/src/mend/node_opts_exec.sh node_default /usr/src/mend/src/community.js`) is set
  again explicitly.

The GitHub App private key is read from a file natively by Renovate CE
(`MEND_RNV_GITHUB_PEM_FILE_PATH`), so it doesn't need `fileenv`.

## Usage

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e MEND_RNV_ACCEPT_TOS=y \
  -e MEND_RNV_PLATFORM=github \
  -e MEND_RNV_GITHUB_APP_ID=123456 \
  -e MEND_RNV_GITHUB_PEM_FILE_PATH=/run/secrets/github_app_private_key \
  -e MEND_RNV_LICENSE_KEY_FILE=/run/secrets/license_key \
  -e MEND_RNV_WEBHOOK_SECRET_FILE=/run/secrets/webhook_secret \
  -v ./github_app_private_key:/run/secrets/github_app_private_key:ro \
  -v ./license_key:/run/secrets/license_key:ro \
  -v ./webhook_secret:/run/secrets/webhook_secret:ro \
  ghcr.io/skriptfabrik/docker-images/renovate-ce:latest
```

Refer to the
[official Renovate CE documentation](https://github.com/mend/renovate-ce-ee/tree/main/docs)
for environment variables, the GitHub App setup, volumes, and general configuration — this
image does not change Renovate CE's runtime behavior beyond the `fileenv`-based secret
resolution described above. Any environment variable Renovate CE supports (except the
excluded ones above) can alternatively be supplied as `<VAR>_FILE` to have it resolved from
a file at startup.
