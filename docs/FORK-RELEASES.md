# Perch releases

Perch is an unofficial Intel compatibility fork of Vorssaint. Original app and
features are by Vorssaint and its contributors; see [ATTRIBUTION.md](../ATTRIBUTION.md).
The upstream copyright and GPL license remain intact.

## Current release

[Download Perch 3.4.3 (DMG)](https://github.com/preethaml7/vorssaint-utils/releases/download/perch-v3.4.3/Perch-3.4.3.dmg).
This is a regular release, published with the prerelease flag disabled.
The [release notes and checksum](https://github.com/preethaml7/vorssaint-utils/releases/tag/perch-v3.4.3)
describe the independent self-signed certificate and testing limitations. The
DMG is not Apple Developer ID signed or Apple notarized; regular release status
does not change its signing or hardware-validation coverage.

## Identity

- App: Perch; developer app: Perch (Developer).
- Bundle ID: `io.protopanda.perch`; developer: `io.protopanda.perch.dev`.
- Helper: `io.protopanda.perch.fan-control`, with a corresponding developer ID.
- Approved bird app artwork; Apple panda emoji menu mark, rendered from the
  installed system font at 26 × 20 points with 1×/2× PNG assets. The default
  emoji remains non-template to preserve its shading; SF Symbol alternatives
  retain their existing template tint behavior.
- Local signing: Perch Utils Signing in a separate perch-signing keychain.
- Repository: https://github.com/preethaml7/vorssaint-utils .
- Automatic self-installing updates are disabled until a fork signing/update
  policy is configured and reviewed. Manual checks open this fork’s releases.
- Helper authentication pins the caller/helper to the running process’s leaf
  certificate and expected bundle ID. Unsigned/ad-hoc processes fail closed.
  Use a stable Perch certificate for actual privileged fan control.

The upstream release workflow remains upstream-only. Perch uses the separate
`perch-build.yml` workflow, with no upstream maintainer credentials or identity.

## Build artifacts or prepare a draft

After merging the PR, open Actions → Perch build and draft release → Run workflow.

Leave `draft_tag` empty for build artifacts only. To create a draft prerelease,
supply a new tag such as `perch-v3.4.3-beta.1`. The workflow builds both
architectures, runs self-tests and regression tests, packages Perch, computes a
SHA-256 checksum, and uploads the artifact. The separate draft job has release
write permission and creates a draft only. Review it before public publication.

These builds use local/ad-hoc signing, not Apple notarization. Do not describe
them as notarized or signed by the original developer. For a Developer ID release,
configure the fork owner’s certificate and notarization credentials and validate
both the app and DMG using those credentials before changing that statement.

Validate the exact release commit, bundle version and release notes. Mount the
DMG read-only, verify all three native binaries have x86_64 and arm64 slices,
and verify the bundle signature. Include hardware test limits in release notes.

Do not upload the earlier personally built `Vorssaint-3.4.3.dmg` as a Perch
release: it predates the independent identity. Use newly built Perch artifacts.
No public release is created merely by pushing or merging this branch.

## Publishing a reviewed release

Wait for both CI jobs and the Perch build workflow to pass. The workflow's draft
uses a GitHub-created `perch-v` tag pointing at the tested source commit. It
initially sets the prerelease flag for review. For a regular release, clear
**Set as a pre-release** before publishing and mark the release as latest.
Document the actual hardware coverage and signing status in either case.

GitHub-hosted artifacts are ad-hoc signed and cannot authenticate privileged fan
control. For the Perch 3.4.3 release, the draft DMG was replaced with the reviewed
universal build signed by the independent `Perch Utils Signing` certificate;
`SHA256SUMS` was also updated to match. For future releases, confirm the source matches
the tagged app code, mount it read-only, and verify bundle identity, architectures,
signature, and packaged attribution before publication. Never replace an artifact
after publication; publish a new version for subsequent changes.

Release notes must distinguish the locally certificate-signed DMG from CI
artifacts, credit Vorssaint, link the source and validation evidence, and state
that the build is not Apple notarized. For a regular release, explicitly publish
the reviewed draft with `--draft=false --prerelease=false --latest` using `gh release edit`;
the workflow intentionally does not publish it automatically.
