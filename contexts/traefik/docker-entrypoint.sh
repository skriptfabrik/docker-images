#!/bin/sh
set -e

# Registers the bundled local plugins listed in TRAEFIK_CUSTOM_LOCAL_PLUGINS
# (names separated by commas or spaces, see /plugins-local/plugins.txt)
manifest=/plugins-local/plugins.txt

# Succeeds if Traefik itself is started: a leading flag, or "traefik" followed by nothing or a flag.
# Subcommands like "traefik version" or "traefik healthcheck" and shell commands are passed through unchanged.
starts_traefik() {
	case "$1" in
	-*) return 0 ;;
	traefik)
		case "${2:-}" in
		'' | -*) return 0 ;;
		esac
		;;
	esac
	return 1
}

# Skips an unknown or missing plugin with a warning, or aborts the start if TRAEFIK_CUSTOM_LOCAL_PLUGINS_STRICT is true
skip_plugin() {
	if [ "${TRAEFIK_CUSTOM_LOCAL_PLUGINS_STRICT:-false}" = "true" ]; then
		echo "docker-entrypoint: $1, aborting (TRAEFIK_CUSTOM_LOCAL_PLUGINS_STRICT=true)" >&2
		exit 1
	fi

	echo "docker-entrypoint: $1, skipping" >&2
}

if [ -n "${TRAEFIK_CUSTOM_LOCAL_PLUGINS:-}" ] && starts_traefik "$@"; then
	set -f
	for name in $(echo "$TRAEFIK_CUSTOM_LOCAL_PLUGINS" | tr ',' ' '); do
		module=$(awk -v name="$name" '$1 == name { print $2; exit }' "$manifest")

		if [ -z "$module" ]; then
			skip_plugin "local plugin '$name' is not bundled"
			continue
		fi

		if [ ! -f "/plugins-local/src/$module/.traefik.yml" ]; then
			skip_plugin "local plugin '$name' ($module) not found"
			continue
		fi

		set -- "$@" "--experimental.localplugins.$name.modulename=$module"
	done
	set +f
fi

exec /entrypoint.sh "$@"
