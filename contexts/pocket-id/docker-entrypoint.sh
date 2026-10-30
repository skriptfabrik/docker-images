#!/bin/sh

set -e

# Set the default value for the DB_CONNECTION_STRING
if [ -z "$DB_CONNECTION_STRING" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ] && [ -n "$DB_NAME" ]; then
	if [ -z "$DB_HOST" ]; then
		DB_HOST=localhost
	fi

	if [ -z "$DB_PORT" ]; then
		DB_PORT=5432
	fi

	export DB_CONNECTION_STRING="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

exec "$@"
