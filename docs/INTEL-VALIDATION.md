# Intel macOS validation

Hardware: MacBookPro15,1, x86_64, macOS 15.8.2 (24H232).
Toolchain: Apple Swift 6.2.4; macOS 26 SDK; deployment target macOS 14.

The previous build script emitted ARM-only binaries. An ARM-only helper built
from this checkout failed on this host with `bad CPU type in executable`.
The updated build produces universal binaries for the app, helper, and adapter.
REA Mach-O inspection independently confirmed two architecture slices, x86_64
and arm64. This static evidence establishes packaging, not ARM runtime behavior.

Validation completed locally:

- Native Intel optimized build and universal optimized build.
- Main app `SELFTEST OK` and helper `fan-control-helper: ok` on Intel.
- Full regression suite: 119,800 checks and all three shell regression scripts.
- After Intel sensor discovery changes: metrics (570 checks) and features/fan
  control (1,344 checks).
- DMG generation, read-only mount, deep bundle signature verification, and both
  architecture slices verified for every bundled executable and adapter.

`--sensors` originally only enumerated Apple Silicon CPU/GPU names and battery
keys, so its initial output on this host was:

```text
component    key   type   °C
battery  TB0T  sp78   36.70
battery  TB1T  sp78   33.90
battery  TB2T  sp78   36.70
```

The diagnostic now uses the same CPU/GPU selectors as the monitor and fan helper.
After rebuilding the diagnostic on this Mac, it read CPU keys including TC0E,
TC0F, TC0P, TC1C through TC6C, TCGC, TCMX, TCSA and TCXC, and GPU keys TG0P,
TGDD, TGDF and TGVP. The subsequent live self-test returned `SELFTEST OK`.
CPU discovery accepts classic TC keys on the generic platform, and GPU discovery
accepts TG as well as Tg. Tests cover those discovery boundaries. The self-test
stopped reporting its previous `no SMC temperature keys` warning after the fix.

Not verified: manual fan writes, physical temperature accuracy, all individual
UI/permission flows, external displays/audio devices, or execution on Apple
Silicon hardware. The full test run emitted existing Swift warnings and SwiftUI
AttributeGraph diagnostics despite passing. Local artifacts are self-signed,
not Apple Developer ID notarized. These checks do not guarantee every feature
works on every Intel Mac.

## Final Perch artifact (2026-11-01)

The final universal release build includes the approved bird app icon and Apple
panda menu assets, uses `io.protopanda.perch`, and is locally signed with the
independent `Perch Utils Signing` identity. App and fan-helper self-tests pass.
The completed DMG was mounted read-only: its bundle passes deep/strict signature
verification, its app/helper/Now Playing adapter each contain x86_64 and arm64,
and its license and attribution are present. The upstream adaptive icon catalog
is absent. This build is self-signed, not notarized.

An initial post-rename full run reported 29 failures out of 119,801 checks during
concurrent compilation. Follow-up work fixed fork identity protection, reduced
screenshot matching overhead while retaining the original timing assertion, and
gave Intel recorder export fixtures a longer watchdog with cancellation on
timeout. The final affected-suite reruns passed 8,903 checks across screenshots,
recorder, utilities, uninstaller, app management, app updates, cleaner, features,
agents, and command bar. All three shell regression scripts also passed in the
initial full run. The entire full suite was not rerun after these fixes; the
earlier 119,800-pass result above predates the Perch rename.

Final installer: `dist/Perch-3.4.3.dmg`.
SHA-256: `b6f4f63df3491bfc43b3df1a3f557ef82dbb99815820c5724856f1187aee43ac`.
The hardware and manual-verification limits above still apply.

## GitHub CI confirmation

[CI run 41377133439](https://github.com/preethaml7/vorssaint-utils/actions/runs/41377133439)
passed both jobs on commit `b703ce73`: current-toolchain build, self-test, DMG
packaging and 119,802 checks; Swift 6.0.3 compatibility build, self-test and
119,801 checks. Both jobs passed all three shell regression scripts. These
GitHub-hosted Apple Silicon tests supplement the local Intel evidence; they do
not exercise every interactive hardware or permission-dependent feature.
