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
CPU discovery accepts classic TC keys on the generic platform, and GPU discovery
accepts TG as well as Tg. Tests cover those discovery boundaries. The self-test
stopped reporting its previous `no SMC temperature keys` warning after the fix.

Not verified: manual fan writes, physical temperature accuracy, all individual
UI/permission flows, external displays/audio devices, or execution on Apple
Silicon hardware. The full test run emitted existing Swift warnings and SwiftUI
AttributeGraph diagnostics despite passing. Local artifacts are self-signed,
not Apple Developer ID notarized. These checks do not guarantee every feature
works on every Intel Mac.
