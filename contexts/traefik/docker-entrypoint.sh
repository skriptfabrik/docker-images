#!/bin/sh
set -e

# Registers the bundled local plugins listed in TRAEFIK_CUSTOM_LOCAL_PLUGINS
# (names separated by commas or spaces, see /plugins-local/plugins.txt)
manifest=/plugins-local/plugins.txt

if [ -n "${TRAEFIK_CUSTOM_LOCAL_PLUGINS:-}" ] && { [ "$1" = "traefik" ] || [ "${1#-}" != "$1" ]; }; then
	set -f
	for name in $(echo "$TRAEFIK_CUSTOM_LOCAL_PLUGINS" | tr ',' ' '); do
		module=$(awk -v name="$name" '$1 == name { print $2; exit }' "$manifest")

		if [ -z "$module" ]; then
			echo "docker-entrypoint: local plugin '$name' is not bundled, skipping" >&2
			continue
		fi

		if [ ! -f "/plugins-local/src/$module/.traefik.yml" ]; then
			echo "docker-entrypoint: local plugin '$name' ($module) not found, skipping" >&2
			continue
		fi

		set -- "$@" "--experimental.localplugins.$name.modulename=$module"
	done
	set +f
fi

exec /entrypoint.sh "$@"
