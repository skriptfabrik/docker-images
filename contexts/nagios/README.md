# @skriptfabrik/docker-images/nagios

Customized [Nagios](https://www.nagios.org/) image based on
[`jasonrivers/nagios`](https://hub.docker.com/r/jasonrivers/nagios).

The image version follows the upstream `jasonrivers/nagios` version pinned in the
[Dockerfile](Dockerfile) (`FROM jasonrivers/nagios:<version>`); this is also what CI uses
to derive the published image tags (see the [root README](../../README.md#continuous-integration)).

## Changes over the upstream image

- **Config loading via drop-in directory only** – the default `cfg_file=...` line and any
  `cfg_dir=${NAGIOS_HOME}/etc` line in `nagios.cfg` are disabled, and the shipped
  `etc/monitor` and `etc/objects` sample configuration directories are removed. Instead,
  `nagios.cfg` is set up with a single `cfg_dir=${NAGIOS_HOME}/etc/conf.d`. Mount your own
  object configuration files into `${NAGIOS_HOME}/etc/conf.d` (a volume or bind mount) —
  the upstream sample configuration is intentionally not shipped.
- **Custom entrypoint with drop-in scripts** – [docker-entrypoint.sh](docker-entrypoint.sh)
  wraps the container startup and, before running `start_nagios`, executes every
  `*.sh` (executed) and sources every `*.envsh` (sourced) file found in
  [docker-entrypoint.d/](docker-entrypoint.d/), in `sort -V` order. Files without the
  executable bit set are skipped with a warning. Mount additional scripts into
  `/docker-entrypoint.d/` to extend startup configuration; follow the `NN-name.sh` naming
  convention to control ordering relative to the built-in scripts below.
- **Built-in drop-in scripts**:
  - [`10-nagios.sh`](docker-entrypoint.d/10-nagios.sh) – renames the default `nagiosadmin`
    web UI user to `${NAGIOSADMIN_USER}` in `cgi.cfg`, (re-)generates
    `${NAGIOS_HOME}/etc/htpasswd.users` for `${NAGIOSADMIN_USER}` from `${NAGIOSADMIN_PASS}`
    (or from the contents of `${NAGIOSADMIN_PASS_FILE}`, if that file exists), and sets
    `use_timezone` in `nagios.cfg` to `${NAGIOS_TIMEZONE}`.
  - [`20-postmap.sh`](docker-entrypoint.d/20-postmap.sh) – prepares the Postfix lookup
    tables for outgoing notification mails:
    - if `/etc/postfix/generic` is not already present and `${SMTP_SENDER}` is set, writes a
      generic map rewriting the local Nagios sender (`${NAGIOS_USER}`) to `${SMTP_SENDER}`;
    - if `/etc/postfix/sasl_passwd` is not already present and `${SMTP_HOST}`,
      `${SMTP_USER}`, and `${SMTP_PASS}` (or the contents of `${SMTP_PASS_FILE}`, if that
      file exists) are all set, writes a SASL password map.

    Each source file (generated or supplied via a mount) is `postmap`ped and then removed.

  - [`30-postconf.sh`](docker-entrypoint.d/30-postconf.sh) – enables the maps produced by
    the script above (or supplied via a mount) in the Postfix configuration:
    - if `/etc/postfix/generic.db` exists, sets `smtp_generic_maps`;
    - if `/etc/postfix/sasl_passwd.db` exists, enables Postfix SASL authentication
      (`smtp_sasl_auth_enable`, `smtp_sasl_password_maps`, and related
      `noanonymous`/`AUTH LOGIN` options).

## Environment variables

| Variable                | Default (from base image) | Description                                                                                                                                                                      |
| ----------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NAGIOSADMIN_USER`      | `nagiosadmin`             | Username for the Nagios web UI (replaces `nagiosadmin` in `cgi.cfg`).                                                                                                            |
| `NAGIOSADMIN_PASS`      | `nagios`                  | Password for `NAGIOSADMIN_USER` (hashed into `htpasswd.users`). Change this in production. Ignored if `NAGIOSADMIN_PASS_FILE` points to an existing file.                        |
| `NAGIOSADMIN_PASS_FILE` | _(unset)_                 | Optional path to a file containing the password for `NAGIOSADMIN_USER` (e.g. a Docker/Compose secret). If the file exists, its contents take precedence over `NAGIOSADMIN_PASS`. |
| `NAGIOS_TIMEZONE`       | `UTC`                     | Timezone used by Nagios (`use_timezone` in `nagios.cfg`).                                                                                                                        |
| `SMTP_HOST`             | _(unset)_                 | Optional SMTP relay host; if set together with `SMTP_USER`/`SMTP_PASS`, Postfix SASL is configured for outgoing notification mail.                                               |
| `SMTP_USER`             | _(unset)_                 | Optional SMTP username, see `SMTP_HOST`.                                                                                                                                         |
| `SMTP_PASS`             | _(unset)_                 | Optional SMTP password, see `SMTP_HOST`. Ignored if `SMTP_PASS_FILE` points to an existing file.                                                                                 |
| `SMTP_PASS_FILE`        | _(unset)_                 | Optional path to a file containing the SMTP password (e.g. a Docker/Compose secret). If the file exists, its contents take precedence over `SMTP_PASS`.                          |
| `SMTP_SENDER`           | _(unset)_                 | Optional sender address for outgoing notification mail; rewrites the local Nagios sender via a Postfix generic map (`smtp_generic_maps`).                                        |

`NAGIOS_HOME` (`/opt/nagios`), `NAGIOS_USER`, and `NAGIOS_GROUP` come from the upstream
`jasonrivers/nagios` image; see its documentation for these and other base-image variables.

## Usage

```sh
docker run -it --rm \
  -p 80:80 \
  -e NAGIOSADMIN_USER=admin \
  -e NAGIOSADMIN_PASS=changeme \
  -e NAGIOS_TIMEZONE=Europe/Berlin \
  -v ./conf.d:/opt/nagios/etc/conf.d \
  ghcr.io/skriptfabrik/docker-images/nagios:latest
```

Mount your Nagios object configuration into `/opt/nagios/etc/conf.d` (`${NAGIOS_HOME}/etc/conf.d`)
— this is the only directory `nagios.cfg` loads config from in this image.

### Passwords from secrets

Instead of passing passwords in plain text via `NAGIOSADMIN_PASS` and `SMTP_PASS`, you can
point `NAGIOSADMIN_PASS_FILE` and `SMTP_PASS_FILE` to files containing them, e.g. Docker
Compose secrets:

```yaml
services:
  nagios:
    image: ghcr.io/skriptfabrik/docker-images/nagios:latest
    environment:
      NAGIOSADMIN_USER: admin
      NAGIOSADMIN_PASS_FILE: /run/secrets/nagiosadmin_pass
      SMTP_HOST: "[smtp.example.com]:587"
      SMTP_USER: nagios@example.com
      SMTP_PASS_FILE: /run/secrets/smtp_pass
      SMTP_SENDER: nagios@example.com
    secrets:
      - nagiosadmin_pass
      - smtp_pass

secrets:
  nagiosadmin_pass:
    file: ./nagiosadmin_pass.txt
  smtp_pass:
    file: ./smtp_pass.txt
```

The file contents are used as the password (trailing newlines are stripped). If a `*_PASS_FILE`
variable is unset or the file does not exist, the corresponding `*_PASS` variable is used
instead.
