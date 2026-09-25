import AppKit
import PDFKit

guard CommandLine.arguments.count == 3 else {
    fputs("usage: render-pdf INPUT.pdf OUTPUT-DIR\n", stderr)
    exit(2)
}

let input = CommandLine.arguments[1]
let output = CommandLine.arguments[2]
guard let pdf = PDFDocument(url: URL(fileURLWithPath: input)) else {
    fatalError("Cannot open \(input)")
}

try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
let scale: CGFloat = 1.5

for index in 0..<pdf.pageCount {
    guard let page = pdf.page(at: index) else { continue }
    let box = page.bounds(for: .mediaBox)
    let width = Int(box.width * scale)
    let height = Int(box.height * scale)
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: width * 4,
        bitsPerPixel: 32
    )!
    let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    graphics.cgContext.setFillColor(NSColor.white.cgColor)
    graphics.cgContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
    graphics.cgContext.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: graphics.cgContext)
    graphics.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    let name = String(format: "page-%03d.png", index + 1)
    let data = bitmap.representation(using: .png, properties: [.compressionFactor: 0.75])!
    try data.write(to: URL(fileURLWithPath: output).appendingPathComponent(name))
}

print("Rendered \(pdf.pageCount) pages to \(output)")
