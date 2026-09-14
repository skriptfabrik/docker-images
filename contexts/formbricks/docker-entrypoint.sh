#!/bin/sh

set -e

# Set the default value for the DATABASE_URL
if [ -z "$DATABASE_URL" ] && [ -n "$DATABASE_USER" ] && [ -n "$DATABASE_PASSWORD" ] && [ -n "$DATABASE_NAME" ]; then
	if [ -z "$DATABASE_HOST" ]; then
		DATABASE_HOST=localhost
	fi

	if [ -z "$DATABASE_PORT" ]; then
		DATABASE_PORT=5432
	fi

	export DATABASE_URL="postgresql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}?schema=public"
fi

# Chain into the base image's own entrypoint script, if present (formbricks has
# one at this path for its node/start.sh prefixing logic; hub's binary
# entrypoint has none, so this is a no-op there).
if [ -x /usr/local/bin/original-docker-entrypoint.sh ]; then
	exec /usr/local/bin/original-docker-entrypoint.sh "$@"
fi

exec "$@"
