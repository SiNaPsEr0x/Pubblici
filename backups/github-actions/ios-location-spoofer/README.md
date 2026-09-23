# ios-location-spoofer CI recovery backup

Source repository: `SiNaPsEr0x/ios-location-spoofer`.

- Original baseline: `bfb44fa3b00e2cc8820536fb58e375d7269ef90a`
- Verified customized source revision: `232c1c62ff4d52db4a5ef1d0e3229a29d21af2db`
- Historical workflow: `original/build.yml`
- Restorable unsigned-build files: `customized/`

The customized copy preserves the unsigned GitHub Actions workflow, `project.yml`, the Go iOS build script and the IPA packaging/validation script. Keep these four files together.

The backup is deliberately outside `.github/workflows/` in this repository, so it cannot execute here. It contains no signing certificates, provisioning profiles, API keys or other secrets.

After an upstream update, compare the updated source against the customized source revision before restoring anything. Do not reset the whole repository. Restore only the reviewed files that are still needed, then use **Actions → Build unsigned IPA → Run workflow** when only CI files changed.

## Verified build

Successful verification run: `35912394315`.

Artifact: `LocationSpoofer-unsigned.ipa` (4,207,693 bytes), SHA-256 `7f4fc03af7be6bae698a473d3224d4a1484cbf29d7ab41d087f2d0553013eb23`, artifact ID `10773308543`. The run verified one app, one Packet Tunnel extension and two unsigned arm64 Mach-O executables, then validated the IPA ZIP structure.
