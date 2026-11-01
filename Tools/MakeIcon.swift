// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Perch fork modifications, 2026-11-01, Preetham Lokesh.
//
// Retains the upstream ICNS/PNG packaging pipeline. The app uses the approved
// Perch bird artwork; the menu icon is rendered from the installed Apple Color
// Emoji font. No font files or upstream reserved icon artwork are distributed.
import AppKit

let iconSizes: [(name: String, px: Int, icnsType: String?)] = [
    ("icon_16x16", 16, nil), ("icon_16x16@2x", 32, "ic11"),
    ("icon_32x32", 32, nil), ("icon_32x32@2x", 64, "ic12"),
    ("icon_128x128", 128, "ic07"), ("icon_128x128@2x", 256, "ic13"),
    ("icon_256x256", 256, "ic08"), ("icon_256x256@2x", 512, "ic14"),
    ("icon_512x512", 512, "ic09"), ("icon_512x512@2x", 1024, "ic10"),
]
let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
let projectDir = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent().deletingLastPathComponent()
let masterURL = projectDir.appendingPathComponent("Resources/Brand/Perch-AppIcon.png")
guard let master = NSImage(contentsOf: masterURL),
      let emojiFont = NSFont(name: "Apple Color Emoji", size: 16) else {
    fatalError("Perch bird artwork or Apple Color Emoji is unavailable")
}

func render(width: Int, height: Int, logicalSize: NSSize,
            draw: () -> Void) -> Data? {
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
        pixelsWide: width, pixelsHigh: height, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
        let context = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
    rep.size = logicalSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    draw()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

func appIcon(px: Int) -> Data? {
    render(width: px, height: px, logicalSize: NSSize(width: px, height: px)) {
        master.draw(in: NSRect(x: 0, y: 0, width: px, height: px),
                    from: NSRect(origin: .zero, size: master.size),
                    operation: .sourceOver, fraction: 1,
                    respectFlipped: false,
                    hints: [.interpolation: NSImageInterpolation.high.rawValue])
    }
}

func menuIcon(scale: Int) -> Data? {
    let width = 26 * scale, height = 20 * scale
    return render(width: width, height: height, logicalSize: NSSize(width: 26, height: 20)) {
        let text = NSAttributedString(string: "🐼", attributes: [
            .font: NSFont(name: emojiFont.fontName, size: 16 * CGFloat(scale))!
        ])
        let size = text.size()
        text.draw(at: NSPoint(x: (CGFloat(width) - size.width) / 2,
                              y: (CGFloat(height) - size.height) / 2))
    }
}

func appendUInt32BE(_ value: Int, to data: inout Data) {
    let raw = UInt32(value)
    data.append(UInt8((raw >> 24) & 0xff))
    data.append(UInt8((raw >> 16) & 0xff))
    data.append(UInt8((raw >> 8) & 0xff))
    data.append(UInt8(raw & 0xff))
}

func writeICNS(_ entries: [(String, Data)], to url: URL) throws {
    var output = Data("icns".utf8)
    appendUInt32BE(8 + entries.reduce(0) { $0 + 8 + $1.1.count }, to: &output)
    for (type, data) in entries {
        output.append(contentsOf: type.utf8)
        appendUInt32BE(8 + data.count, to: &output)
        output.append(data)
    }
    try output.write(to: url)
}

try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
let destination = URL(fileURLWithPath: outDir).deletingLastPathComponent()
var entries: [(String, Data)] = []
for (name, px, type) in iconSizes {
    guard let png = appIcon(px: px) else { fatalError("Could not render \(name)") }
    try png.write(to: URL(fileURLWithPath: outDir).appendingPathComponent("\(name).png"))
    if let type { entries.append((type, png)) }
}
try writeICNS(entries, to: destination.appendingPathComponent("AppIcon.icns"))
for scale in [1, 2] {
    guard let png = menuIcon(scale: scale) else { fatalError("Could not render panda menu icon") }
    let suffix = scale == 1 ? "" : "@2x"
    try png.write(to: destination.appendingPathComponent("MenuBarIcon\(suffix).png"))
}
guard let mark = appIcon(px: 640) else { fatalError("Could not render Perch brand mark") }
try mark.write(to: destination.appendingPathComponent("BrandMark.png"))
print("Perch bird app icons and Apple panda menu assets written to \(outDir)")
