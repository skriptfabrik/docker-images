#!/bin/sh

set -e

if [ -n "$SEMAPHORE_REQUIREMENTS" ]; then
	echo "$SEMAPHORE_REQUIREMENTS" > /etc/semaphore/requirements.yml
fi

exec "$@"
