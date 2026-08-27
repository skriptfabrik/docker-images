#!/bin/sh

set -e

# Set the default value for the DATABASE_URL
if [ -z "$DATABASE_URL" ] && [ -n "$DATABASE_USER" ] && [ -n "$DATABASE_PASSWORD_FILE" ] && [ -n "$DATABASE_NAME" ]; then
	_db_password="$(cat "$DATABASE_PASSWORD_FILE")"
	export DATABASE_URL="postgresql://${DATABASE_USER}:${_db_password}@${DATABASE_HOST:-postgres}:${DATABASE_PORT:-5432}/${DATABASE_NAME}"
	unset DATABASE_HOST DATABASE_PORT DATABASE_NAME DATABASE_USER DATABASE_PASSWORD_FILE _db_password
fi

exec "$@"
