# @skriptfabrik/docker-images/open-webui

Customized [Open WebUI](https://openwebui.com/) image based on the official
[`open-webui/open-webui`](https://github.com/open-webui/open-webui/pkgs/container/open-webui)
image.

The image version follows the upstream `open-webui/open-webui` version pinned in the
[Dockerfile](Dockerfile) (`FROM ghcr.io/open-webui/open-webui:<version>`); this is also
what CI uses to derive the published image tags (see the
[root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **[`fileenv`](https://github.com/skriptfabrik/fileenv) entrypoint wrapper** – the
  `fileenv` binary is copied in from the
  [`ghcr.io/skriptfabrik/fileenv`](https://github.com/skriptfabrik/fileenv) image and set
  as `ENTRYPOINT`, wrapping the original Open WebUI startup command (kept as `CMD`). Before
  starting the application, `fileenv` resolves any `<VAR>_FILE` environment variable into
  its corresponding `<VAR>` variable by reading the referenced file's contents (and unsets
  the `_FILE` variable afterwards) — this lets secrets (e.g. `WEBUI_SECRET_KEY`,
  `OPENAI_API_KEY`, database credentials) be supplied via mounted files or Docker/Swarm
  secrets instead of plain environment variables, without requiring any change in Open
  WebUI itself.

## Usage

```sh
docker run -it --rm \
  -p 8080:8080 \
  -e WEBUI_SECRET_KEY_FILE=/run/secrets/webui_secret_key \
  -v ./webui_secret_key:/run/secrets/webui_secret_key:ro \
  ghcr.io/skriptfabrik/docker-images/open-webui:latest
```

Refer to the [official Open WebUI documentation](https://docs.openwebui.com/) for
environment variables, volumes, and general configuration — this image does not change
Open WebUI's runtime behavior beyond the `fileenv`-based secret resolution described
above. Any environment variable Open WebUI supports can alternatively be supplied as
`<VAR>_FILE` to have it resolved from a file at startup.
