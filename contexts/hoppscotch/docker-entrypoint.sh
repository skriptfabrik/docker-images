#!/bin/sh

set -e

# Set the default value for the DATABASE_URL
if [ -z "$DATABASE_URL" ] && [ -n "$DATABASE_USER" ] && [ -n "$DATABASE_PASSWORD" ] && [ -n "$DATABASE_NAME" ]; then
	export DATABASE_URL="postgresql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST:-localhost}:${DATABASE_PORT:-5432}/${DATABASE_NAME}"
fi

exec "$@"
