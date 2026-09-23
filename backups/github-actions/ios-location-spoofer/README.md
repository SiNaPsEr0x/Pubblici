# ios-location-spoofer CI recovery backup

Source repository: `SiNaPsEr0x/ios-location-spoofer`.

- Original baseline: `bfb44fa3b00e2cc8820536fb58e375d7269ef90a`
- Customized source revision: currently tracked on the source repository `main`
- Historical workflow: `original/build.yml`
- Restorable unsigned-build files: `customized/`

The customized copy preserves the unsigned GitHub Actions workflow, `project.yml`, the Go iOS build script and the IPA packaging/validation script. Keep these four files together.

The backup is deliberately outside `.github/workflows/` in this repository, so it cannot execute here. It contains no signing certificates, provisioning profiles, API keys or other secrets.

After an upstream update, compare the updated source against the customized source revision before restoring anything. Do not reset the whole repository. Restore only the reviewed files that are still needed, then use **Actions → Build unsigned IPA → Run workflow** when only CI files changed.
