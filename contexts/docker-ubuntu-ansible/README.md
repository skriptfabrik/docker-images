# @skriptfabrik/docker-images/docker-ubuntu-ansible

Customized Ansible test target image based on the official
[`geerlingguy/docker-ubuntu2604-ansible`](https://hub.docker.com/r/geerlingguy/docker-ubuntu2604-ansible)
image (Ubuntu 26.04 with `systemd` and Ansible preinstalled). Unlike the other images in
this repository, this isn't a runtime service — it's used as the container platform for
[Molecule](https://ansible.readthedocs.io/projects/molecule/) tests of Ansible roles and
playbooks in CI.

Unlike the other images in this repository, [Dockerfile.ubuntu2604](Dockerfile.ubuntu2604)
pins the upstream `geerlingguy/docker-ubuntu2604-ansible:latest` tag to a specific digest,
so updating the digest is required to consume upstream changes. CI only produces `latest`
and commit-SHA tags for it (no semver tags) — see the
[root README](../../README.md#continuous-integration).

## Changes over the upstream image

- **Docker CLI/daemon and Compose plugin (`docker.io`, `docker-compose-v2`)** – installed
  so that Ansible running inside the container can manage Docker containers and Compose
  stacks as part of a role/playbook under test.
- **Python dependencies (`docker`, `jsondiff`)** – installed so that Ansible's
  `community.docker` modules and roles/playbooks that compare JSON output work out of the
  box during testing.

## Usage

This image is intended to be referenced as a Molecule platform, not run standalone. As
with the upstream base image, it needs `--privileged` and a cgroup mount to run `systemd`:

```yaml
# molecule/default/molecule.yml
platforms:
  - name: instance
    image: ghcr.io/skriptfabrik/docker-images/docker-ubuntu-ansible:latest
    privileged: true
    cgroupns_mode: host
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    command: /lib/systemd/systemd
```

Refer to the
[official `geerlingguy/docker-ubuntu2604-ansible` documentation](https://hub.docker.com/r/geerlingguy/docker-ubuntu2604-ansible)
for base image usage and caveats (it's for isolated testing, not production) — this image
does not change the base image's runtime behavior beyond the added packages described
above.
