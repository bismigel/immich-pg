# GitHub Actions here is the **upstream drift check only**

The image build moved to Forgejo Actions (`.forgejo/workflows/build.yml`) on 2026-11-20, which pushes to the
estate's own registry (`git.bismigel.dev/bismigel/immich-pg`) instead of GHCR.

`upstream.yml` stays on GitHub on purpose: it polls **ghcr.io** for a newer Immich base image and opens an update,
and GitHub-hosted runners have the least friction for that (it authenticates anonymously to GHCR for a public
image). It does not build or publish anything.

`build.yml` was removed rather than left in place. A push mirror sends `main` to GitHub, so the old workflow would
keep building and publishing to GHCR on every merge — a second build of the same commit, in a registry the cluster
no longer pulls from.
