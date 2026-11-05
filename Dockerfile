# Immich's Postgres, with the one thing CloudNativePG needs and Immich's image lacks.
#
# ADR 0010 (homelab-context). CNPG's initdb runs as uid 26 and looks that uid up in /etc/passwd; Immich's
# image defines postgres at 999, so the bootstrap dies with:
#
#   initdb: could not look up effective user ID 26: user does not exist
#
# The Cluster CRD exposes no securityContext/runAsUser, so the fix is here: add uid 26, change nothing else.
# Every extension (vchord 0.4.3, vector 0.8.1) stays exactly as Immich pin it, because those versions are
# tied to index-format compatibility and re-deriving them is how data gets quietly corrupted.
ARG BASE=ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
FROM ${BASE}

# Digest of the base above, recorded so `scripts/check-upstream.py` can tell a deliberate bump from drift.
ARG BASE_DIGEST=sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23
LABEL org.opencontainers.image.base.digest="${BASE_DIGEST}"
LABEL org.opencontainers.image.description="Immich's Postgres image with uid 26 present, for CloudNativePG"

USER root
RUN echo 'postgres:x:26:26:PostgreSQL Server:/var/lib/postgresql:/bin/bash' >> /etc/passwd \
 && getent passwd 26
USER 26
