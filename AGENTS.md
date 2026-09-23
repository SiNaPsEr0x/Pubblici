# AGENTS.md

## Repository purpose
Public files and recovery backups maintained for SiNaPsEr0x. Preserve unrelated files, including README.md and doc.zip.

## Maintenance rules
- Read this file and any nested AGENTS.md before changing the repository.
- Keep this file updated when adding maintained projects or recovery procedures.
- Never store tokens, private keys, signing certificates or provisioning profiles.
- Store GitHub Actions backups outside `.github/workflows/` so they cannot execute in this repository.
- Back up original and customized workflow configuration and required build scripts before replacing a project's CI.
- Record source repository, source commit and restoration instructions. Do not automatically overwrite an upstream update without reviewing the differences.

## Managed backup location
- `backups/github-actions/ios-location-spoofer/`: recovery files for `SiNaPsEr0x/ios-location-spoofer`; one unsigned IPA, cached build and source-only automatic triggers. See that directory's README and manifest for the saved revision and verification status.
