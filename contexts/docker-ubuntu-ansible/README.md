# @skriptfabrik/docker-images/docker-ubuntu-ansible

Customized Ansible test target images based on the official
[`geerlingguy/docker-ubuntu2404-ansible`](https://hub.docker.com/r/geerlingguy/docker-ubuntu2404-ansible)
and
[`geerlingguy/docker-ubuntu2604-ansible`](https://hub.docker.com/r/geerlingguy/docker-ubuntu2604-ansible)
images (Ubuntu 24.04 and 26.04 with `systemd` and Ansible preinstalled). Unlike the other
images in this repository, these aren't runtime services — they're used as the container
platform for [Molecule](https://ansible.readthedocs.io/projects/molecule/) tests of Ansible
roles and playbooks in CI.

## Variants

This build context produces one image per supported Ubuntu release:

| Image                                                          | Dockerfile                                     | Upstream base image                            |
| -------------------------------------------------------------- | ---------------------------------------------- | ---------------------------------------------- |
| `ghcr.io/skriptfabrik/docker-images/docker-ubuntu2404-ansible` | [Dockerfile.ubuntu2404](Dockerfile.ubuntu2404) | `geerlingguy/docker-ubuntu2404-ansible:latest` |
| `ghcr.io/skriptfabrik/docker-images/docker-ubuntu2604-ansible` | [Dockerfile.ubuntu2604](Dockerfile.ubuntu2604) | `geerlingguy/docker-ubuntu2604-ansible:latest` |

Unlike the other images in this repository, both Dockerfiles pin a digest for the upstream `latest` tag, so upstream changes are picked up only when the digest is updated — see the [root README](../../README.md#continuous-integration).

## Changes over the upstream image

Both variants apply the same changes:

- **Docker CE daemon, CLI, Buildx and Compose plugins (`docker-ce`, `docker-ce-cli`,
  `docker-buildx-plugin`, `docker-compose-plugin`)** – installed from the official Docker
  APT repository (`download.docker.com`) so that Ansible running inside the container can
  manage Docker containers and Compose stacks as part of a role/playbook under test.
- **Python dependencies (`docker`, `jsondiff`)** – installed so that Ansible's
  `community.docker` modules and roles/playbooks that compare JSON output work out of the
  box during testing.

## Usage

These images are intended to be referenced as Molecule platforms, not run standalone. As
with the upstream base images, they need `--privileged` and a cgroup mount to run `systemd`.
To test a role against both Ubuntu releases, declare one platform per variant:

```yaml
# molecule/default/molecule.yml
platforms:
  - name: ubuntu2404
    image: ghcr.io/skriptfabrik/docker-images/docker-ubuntu2404-ansible:latest
    privileged: true
    cgroupns_mode: host
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    command: /lib/systemd/systemd
  - name: ubuntu2604
    image: ghcr.io/skriptfabrik/docker-images/docker-ubuntu2604-ansible:latest
    privileged: true
    cgroupns_mode: host
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    command: /lib/systemd/systemd
```

Refer to the official
[`geerlingguy/docker-ubuntu2404-ansible`](https://hub.docker.com/r/geerlingguy/docker-ubuntu2404-ansible)
and
[`geerlingguy/docker-ubuntu2604-ansible`](https://hub.docker.com/r/geerlingguy/docker-ubuntu2604-ansible)
documentation for base image usage and caveats (they're for isolated testing, not
production) — these images do not change the base images' runtime behavior beyond the
added packages described above.
