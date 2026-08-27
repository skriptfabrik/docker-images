#!/bin/sh

set -e

# Set the default value for the AMQP_URL
if [ -z "$AMQP_URL" ] && [ -n "$RABBITMQ_USER" ] && [ -n "$RABBITMQ_PASSWORD" ] && [ -n "$RABBITMQ_VHOST" ]; then
	if [ -z "$RABBITMQ_HOST" ]; then
		RABBITMQ_HOST=localhost
	fi

	if [ -z "$RABBITMQ_PORT" ]; then
		RABBITMQ_PORT=5672
	fi

	export AMQP_URL="amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@${RABBITMQ_HOST}:${RABBITMQ_PORT}/${RABBITMQ_VHOST}"
fi

# Set the default value for the DATABASE_URL
if [ -z "$DATABASE_URL" ] && [ -n "$DATABASE_USER" ] && [ -n "$DATABASE_PASSWORD" ] && [ -n "$DATABASE_NAME" ]; then
	if [ -z "$DATABASE_HOST" ]; then
		DATABASE_HOST=localhost
	fi

	if [ -z "$DATABASE_PORT" ]; then
		DATABASE_PORT=5432
	fi

	export DATABASE_URL="postgresql://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"
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
