# Fork release preparation

This fork is maintained at https://github.com/preethaml7/vorssaint-utils.
Intel support and universal packaging are ready for review. The existing
`release.yml` intentionally remains restricted to the upstream repository,
maintainer, signing team, and protected environment. Merely changing its
repository condition would not make it usable in this fork.

The proposed independent public name is **CopperBar**, pending the fork owner's
selection and a name availability check. The owner decided to choose a distinct
name after reviewing the upstream branding requirement. The Intel-support PR
does not rename the runtime or publish the existing personal DMG.

## Before distributing a fork DMG

Follow [TRADEMARKS.md](../TRADEMARKS.md): choose a distinct app name, icon,
bundle identifier, signing identity, update feed, and other release branding.
Update both the application and its privileged helper identity together,
including the launch daemon, XPC validation, installer verification, and
uninstall paths. Disable upstream automatic updates until the fork has its own
trusted update feed and signature verification. Preserve upstream copyright
and GPL attribution.

Create a fork-specific release workflow only after those identities are set.
Use this repository's protected environment with the fork owner's Developer ID
certificate and notarization credentials; never reuse the upstream maintainer's
team ID or claim that a locally signed build is notarized. Keep build/test jobs
separate from the job granted `contents: write` to publish releases.

## Build and validate

```sh
./build.sh
./build/Vorssaint --selftest
./build.sh --test
./Tools/make-dmg.sh
```

These are the current development artifact names; rename them with the fork
identity before distribution. Verify both architecture slices in all three
bundled Mach-O files, verify the bundle signature, mount the DMG read-only,
and repeat those checks on the mounted copy. Sign and notarize the app and DMG
with the fork owner's credentials before making notarization claims.

After the PR is merged, choose a fork version, update the bundle version and
release notes, build from that exact commit, and create an explicit release in
`preethaml7/vorssaint-utils`. Upload the validated DMG and its SHA-256 checksum.
The locally built `dist/Vorssaint-3.4.3.dmg` is a personal validation artifact,
not an independently branded public release. No version tag or release is
created by this Intel-support PR.
