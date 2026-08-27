#!/bin/sh

set -e

# Set the default value for the DB_CONNECTION_URI
if [ -z "$DB_CONNECTION_URI" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ] && [ -n "$DB_NAME" ]; then
	if [ -z "$DB_HOST" ]; then
		DB_HOST=localhost
	fi

	if [ -z "$DB_PORT" ]; then
		DB_PORT=5432
	fi

	export DB_CONNECTION_URI="postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

# Set the default value for the REDIS_URL
if [ -z "$REDIS_URL" ]; then
	if [ -n "$REDIS_USER" ] && [ -n "$REDIS_PASSWORD" ]; then
		REDIS_AUTH="$REDIS_USER:$REDIS_PASSWORD@"
	fi

	if [ -z "$REDIS_HOST" ]; then
		REDIS_HOST=localhost
	fi

	if [ -z "$REDIS_PORT" ]; then
		REDIS_PORT=6379
	fi

	export REDIS_URL="redis://${REDIS_AUTH}${REDIS_HOST}:${REDIS_PORT}"
fi

exec "$@"
