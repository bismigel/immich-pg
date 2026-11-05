# immich-pg

Immich's own Postgres image, with one line added: `postgres:x:26` in `/etc/passwd`.

**Why:** CloudNativePG's `initdb` runs as uid 26 and looks that uid up; Immich's image has `postgres` at 999, so
the bootstrap fails with `initdb: could not look up effective user ID 26: user does not exist`. CNPG's `Cluster`
CRD exposes no `securityContext`/`runAsUser` (`kubectl explain cluster.postgresql.cnpg.io.spec` has neither), so
the uid has to come from the image. Decision record: homelab-context
[ADR 0010](https://github.com/bismigel/homelab-context/blob/main/docs/decisions/adr-0010-immich-database-image-is-derived.md).

**Why not build Postgres with the extensions ourselves:** Immich pins `vchord` 0.4.3 and `vector` 0.8.1 for
index-format compatibility. Re-deriving that pairing means silent corruption when it drifts. Here the extensions
are exactly Immich's, by construction, and the only thing this image changes is the user CNPG expects.

## Consuming it

By **digest**, per ADR 0007. The build prints the reference in its job summary:

```yaml
imageName: ghcr.io/bismigel/immich-pg@sha256:…
```

## What CI proves

- the image builds;
- `initdb` completes **as uid 26** (a build alone is not that test);
- `vchord.so` and `vector.so` are present in `14/lib`.

A weekly job compares the pinned base with upstream's current digest and **opens a PR** rather than bumping:
a new base moves the extensions, which is a decision.
