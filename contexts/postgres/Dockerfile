FROM postgres:18.6

RUN set -e \
	; apt-get update \
	# NOTE: Dependabot only tracks FROM image references, not apt-get package
	# pins inside RUN commands. The postgresql-18-pgvector version below must be
	# updated manually — check `apt-cache madison postgresql-18-pgvector` inside
	# a postgres:18.6-based container for the current pinned version, especially
	# after a Postgres major-version bump (new Debian codename) or when a newer
	# pgvector release is needed.
	; apt-get install -y --no-install-recommends postgresql-18-pgvector=0.8.6-1.pgdg13+1 \
	; rm -rf /var/lib/apt/lists/*
