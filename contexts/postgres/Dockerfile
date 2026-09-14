FROM postgres:18.6

RUN set -e \
	; apt-get update \
	; apt-get install -y --no-install-recommends ca-certificates curl gnupg \
	; curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
	; . /etc/os-release \
	; echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	; apt-get update \
	# NOTE: Dependabot only tracks FROM image references, not apt-get package
	# pins inside RUN commands. The postgresql-18-pgvector version below must be
	# updated manually — check `apt-cache madison postgresql-18-pgvector` inside
	# a postgres:18.6-based container for the current pinned version, especially
	# after a Postgres major-version bump (new Debian codename) or when a newer
	# pgvector release is needed.
	; apt-get install -y --no-install-recommends postgresql-18-pgvector=0.8.6-1.pgdg13+1 \
	; apt-get purge -y --auto-remove curl gnupg \
	; rm -rf /var/lib/apt/lists/*
