import AppKit
import PDFKit

struct RegionMetric: Codable {
    let name: String
    let exactMismatchRatio: Double
    let perceptualMismatchRatio: Double
    let meanAbsoluteError: Double
    let originalInkBounds: [Int]
    let candidateInkBounds: [Int]
}

struct PageMetric: Codable {
    let name: String
    let originalPage: Int
    let candidatePage: Int
    let originalLabel: String
    let candidateLabel: String
    let alignment: [Int]
    let regions: [RegionMetric]
}

struct Report: Codable {
    let dpi: Int
    let exactTolerance: Int
    let perceptualTolerance: Int
    let comparedPages: Int
    let pages: [PageMetric]
}

struct Pair {
    let name: String
    let originalAnchor: String
    let candidateAnchor: String
    let regions: [(String, CGRect)]
}

let pageRegion = CGRect(x: 0, y: 0, width: 1, height: 1)
let headingRegion = CGRect(x: 0.12, y: 0.72, width: 0.80, height: 0.23)
let numeralRegion = CGRect(x: 0.76, y: 0.78, width: 0.16, height: 0.16)
let bodyRegion = CGRect(x: 0.15, y: 0.12, width: 0.70, height: 0.64)

let pairs = [
    Pair(name: "title", originalAnchor: "Hochschule Darmstadt", candidateAnchor: "Hochschule Darmstadt", regions: [("full", pageRegion)]),
    Pair(name: "declaration", originalAnchor: "Ich versichere hiermit", candidateAnchor: "Ich versichere hiermit", regions: [("full", pageRegion), ("body", bodyRegion)]),
    Pair(name: "abstract-en", originalAnchor: "A short summary of the contents", candidateAnchor: "A short summary of the contents", regions: [("full", pageRegion), ("body", bodyRegion)]),
    Pair(name: "abstract-de", originalAnchor: "Kurze Zusammenfassung des Inhaltes", candidateAnchor: "Kurze Zusammenfassung des Inhaltes", regions: [("full", pageRegion), ("body", bodyRegion)]),
    Pair(name: "contents", originalAnchor: "Thesis 1 Einleitung", candidateAnchor: "Einleitung", regions: [("full", pageRegion), ("body", bodyRegion)]),
    Pair(name: "part-thesis", originalAnchor: "Teil I", candidateAnchor: "Teil I", regions: [("full", pageRegion)]),
    Pair(name: "chapter-1", originalAnchor: "Lorem ipsum at nusquam appellantur", candidateAnchor: "Lorem ipsum at nusquam appellantur", regions: [("full", pageRegion), ("heading", headingRegion), ("numeral", numeralRegion), ("body", bodyRegion)]),
    Pair(name: "chapter-2", originalAnchor: "Non vices medical da", candidateAnchor: "Non vices medical da", regions: [("full", pageRegion), ("heading", headingRegion), ("numeral", numeralRegion), ("body", bodyRegion)]),
    Pair(name: "chapter-3", originalAnchor: "liquam facilisis convallis", candidateAnchor: "Aliquam facilisis convallis", regions: [("full", pageRegion), ("heading", headingRegion), ("numeral", numeralRegion), ("body", bodyRegion)]),
    Pair(name: "part-appendix", originalAnchor: "Teil II", candidateAnchor: "Teil II", regions: [("full", pageRegion)]),
    Pair(name: "appendix-a", originalAnchor: "The ClassicThesis bundle for", candidateAnchor: "The ClassicThesis bundle has", regions: [("full", pageRegion), ("heading", headingRegion), ("numeral", numeralRegion)]),
    Pair(name: "appendix-b", originalAnchor: "Lorem ipsum at nusquam appellantur his, ut eos", candidateAnchor: "Lorem ipsum at nusquam appellantur his, ut eos", regions: [("full", pageRegion), ("heading", headingRegion), ("numeral", numeralRegion)]),
    Pair(name: "glossary", originalAnchor: "Central Limit Theorem A fundamental", candidateAnchor: "Central Limit Theorem A theorem", regions: [("full", pageRegion), ("body", bodyRegion)]),
]

func normalizedText(_ value: String) -> String {
    value.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).lowercased()
}

func pageIndex(containing anchor: String, in pdf: PDFDocument) -> Int? {
    let needle = normalizedText(anchor)
    return (0..<pdf.pageCount).first { index in
        guard let text = pdf.page(at: index)?.string else { return false }
        return normalizedText(text).contains(needle)
    }
}

func render(_ page: PDFPage, scale: CGFloat) -> NSBitmapImageRep {
    let box = page.bounds(for: .mediaBox)
    let width = Int(box.width * scale)
    let height = Int(box.height * scale)
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
        isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: width * 4, bitsPerPixel: 32
    )!
    let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    let context = graphics.cgContext
    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    context.interpolationQuality = .high
    context.scaleBy(x: scale, y: scale)
    page.draw(with: .mediaBox, to: context)
    graphics.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func luminance(_ data: UnsafeMutablePointer<UInt8>, _ offset: Int) -> Int {
    (54 * Int(data[offset]) + 183 * Int(data[offset + 1]) + 19 * Int(data[offset + 2])) / 256
}

func normalizedRect(_ rect: CGRect, width: Int, height: Int) -> (Int, Int, Int, Int) {
    let x = max(0, min(width - 1, Int(rect.minX * CGFloat(width))))
    let y = max(0, min(height - 1, Int((1 - rect.maxY) * CGFloat(height))))
    let w = max(1, min(width - x, Int(rect.width * CGFloat(width))))
    let h = max(1, min(height - y, Int(rect.height * CGFloat(height))))
    return (x, y, w, h)
}

func inkBounds(_ bitmap: NSBitmapImageRep, rect: CGRect, threshold: Int = 245) -> [Int] {
    guard let data = bitmap.bitmapData else { return [0, 0, 0, 0] }
    let (x0, y0, width, height) = normalizedRect(rect, width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
    var minX = x0 + width
    var minY = y0 + height
    var maxX = x0
    var maxY = y0
    for y in y0..<(y0 + height) {
        for x in x0..<(x0 + width) {
            let offset = y * bitmap.bytesPerRow + x * 4
            if luminance(data, offset) < threshold {
                minX = min(minX, x); minY = min(minY, y)
                maxX = max(maxX, x); maxY = max(maxY, y)
            }
        }
    }
    return minX > maxX ? [0, 0, 0, 0] : [minX, minY, maxX - minX + 1, maxY - minY + 1]
}

func alignment(_ original: NSBitmapImageRep, _ candidate: NSBitmapImageRep) -> (Int, Int) {
    guard let a = original.bitmapData, let b = candidate.bitmapData else { return (0, 0) }
    let sample = normalizedRect(headingRegion, width: original.pixelsWide, height: original.pixelsHigh)
    var best = (dx: 0, dy: 0, score: Double.greatestFiniteMagnitude)
    for dy in stride(from: -16, through: 16, by: 2) {
        for dx in stride(from: -16, through: 16, by: 2) {
            var score = 0.0
            var count = 0
            for y in stride(from: sample.1, to: sample.1 + sample.3, by: 8) {
                for x in stride(from: sample.0, to: sample.0 + sample.2, by: 8) {
                    let bx = x + dx, by = y + dy
                    if bx < 0 || bx >= candidate.pixelsWide || by < 0 || by >= candidate.pixelsHigh { continue }
                    let av = luminance(a, y * original.bytesPerRow + x * 4)
                    let bv = luminance(b, by * candidate.bytesPerRow + bx * 4)
                    score += Double(abs(av - bv)); count += 1
                }
            }
            score /= Double(max(count, 1))
            if score < best.score { best = (dx, dy, score) }
        }
    }
    return (best.dx, best.dy)
}

func compare(_ original: NSBitmapImageRep, _ candidate: NSBitmapImageRep, rect: CGRect, shift: (Int, Int), output: NSBitmapImageRep?) -> RegionMetric {
    guard let a = original.bitmapData, let b = candidate.bitmapData else { fatalError("Cannot access bitmap") }
    let (x0, y0, width, height) = normalizedRect(rect, width: original.pixelsWide, height: original.pixelsHigh)
    var exact = 0, perceptual = 0, maximum = 0
    var total: UInt64 = 0
    for y in y0..<(y0 + height) {
        for x in x0..<(x0 + width) {
            let bx = x + shift.0, by = y + shift.1
            let ao = y * original.bytesPerRow + x * 4
            var errors = [255, 255, 255]
            if bx >= 0 && bx < candidate.pixelsWide && by >= 0 && by < candidate.pixelsHigh {
                let bo = by * candidate.bytesPerRow + bx * 4
                errors = (0..<3).map { abs(Int(a[ao + $0]) - Int(b[bo + $0])) }
            }
            if errors.contains(where: { $0 > 0 }) { exact += 1 }
            if errors.max()! > 16 { perceptual += 1 }
            total += UInt64(errors.reduce(0, +))
            maximum = max(maximum, errors.max()!)
            if let out = output, let pixels = out.bitmapData {
                let oo = y * out.bytesPerRow + x * 4
                let originalInk = luminance(a, ao) < 245
                var candidateInk = false
                if bx >= 0 && bx < candidate.pixelsWide && by >= 0 && by < candidate.pixelsHigh {
                    candidateInk = luminance(b, by * candidate.bytesPerRow + bx * 4) < 245
                }
                if originalInk && !candidateInk { pixels[oo] = 230; pixels[oo + 1] = 30; pixels[oo + 2] = 30 }
                else if candidateInk && !originalInk { pixels[oo] = 30; pixels[oo + 1] = 90; pixels[oo + 2] = 230 }
                else if originalInk && candidateInk { pixels[oo] = 45; pixels[oo + 1] = 45; pixels[oo + 2] = 45 }
                else { pixels[oo] = 255; pixels[oo + 1] = 255; pixels[oo + 2] = 255 }
                pixels[oo + 3] = 255
            }
        }
    }
    let count = width * height
    return RegionMetric(
        name: "",
        exactMismatchRatio: Double(exact) / Double(count),
        perceptualMismatchRatio: Double(perceptual) / Double(count),
        meanAbsoluteError: Double(total) / Double(count * 3 * 255),
        originalInkBounds: inkBounds(original, rect: rect),
        candidateInkBounds: inkBounds(candidate, rect: rect)
    )
}

func blankBitmap(width: Int, height: Int) -> NSBitmapImageRep {
    let result = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: width * 4, bitsPerPixel: 32)!
    memset(result.bitmapData!, 255, result.bytesPerRow * height)
    return result
}

func thumbnail(_ bitmap: NSBitmapImageRep, width: Int = 480) -> NSBitmapImageRep {
    let height = Int(Double(bitmap.pixelsHigh) * Double(width) / Double(bitmap.pixelsWide))
    let result = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: width * 4, bitsPerPixel: 32)!
    let graphics = NSGraphicsContext(bitmapImageRep: result)!
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = graphics
    NSGraphicsContext.current?.imageInterpolation = .high
    bitmap.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    graphics.flushGraphics(); NSGraphicsContext.restoreGraphicsState()
    return result
}

guard CommandLine.arguments.count == 4 else {
    fputs("usage: pdf-compare ORIGINAL CANDIDATE OUTPUT-DIR\n", stderr); exit(2)
}
let original = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1]))!
let candidate = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[2]))!
let output = CommandLine.arguments[3]
let scale: CGFloat = 1
try FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true)
var results: [PageMetric] = []

for pair in pairs {
    guard let oi = pageIndex(containing: pair.originalAnchor, in: original), let ci = pageIndex(containing: pair.candidateAnchor, in: candidate), let op = original.page(at: oi), let cp = candidate.page(at: ci) else {
        fputs("warning: could not match \(pair.name)\n", stderr); continue
    }
    let a = render(op, scale: scale), b = render(cp, scale: scale)
    guard a.pixelsWide == b.pixelsWide && a.pixelsHigh == b.pixelsHigh else { fatalError("Page dimensions differ") }
    let shift = alignment(a, b)
    let overlay = blankBitmap(width: a.pixelsWide, height: a.pixelsHigh)
    var regionResults: [RegionMetric] = []
    for (name, rect) in pair.regions {
        let raw = compare(a, b, rect: rect, shift: name == "full" ? (0, 0) : shift, output: name == "full" ? overlay : nil)
        regionResults.append(RegionMetric(name: name, exactMismatchRatio: raw.exactMismatchRatio, perceptualMismatchRatio: raw.perceptualMismatchRatio, meanAbsoluteError: raw.meanAbsoluteError, originalInkBounds: raw.originalInkBounds, candidateInkBounds: raw.candidateInkBounds))
    }
    let base = "\(pair.name)-o\(oi + 1)-c\(ci + 1)"
    try thumbnail(a).representation(using: .png, properties: [.compressionFactor: 0.7])!.write(to: URL(fileURLWithPath: "\(output)/\(base)-original.png"))
    try thumbnail(b).representation(using: .png, properties: [.compressionFactor: 0.7])!.write(to: URL(fileURLWithPath: "\(output)/\(base)-candidate.png"))
    try thumbnail(overlay).representation(using: .png, properties: [.compressionFactor: 0.7])!.write(to: URL(fileURLWithPath: "\(output)/\(base)-overlay.png"))
    results.append(PageMetric(name: pair.name, originalPage: oi + 1, candidatePage: ci + 1, originalLabel: op.label ?? "", candidateLabel: cp.label ?? "", alignment: [shift.0, shift.1], regions: regionResults))
}

let report = Report(dpi: Int(scale * 72), exactTolerance: 0, perceptualTolerance: 16, comparedPages: results.count, pages: results)
let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
try encoder.encode(report).write(to: URL(fileURLWithPath: "\(output)/report.json"))

let rows = results.map { page in
    let full = page.regions.first(where: { $0.name == "full" })!
    let diagnostic = page.regions.filter { $0.name != "full" }.map { "\($0.name): \(String(format: "%.2f", $0.perceptualMismatchRatio * 100))%" }.joined(separator: "<br>")
    let base = "\(page.name)-o\(page.originalPage)-c\(page.candidatePage)"
    return "<tr><th>\(page.name)<br>o\(page.originalPage) / c\(page.candidatePage)</th><td><img src='\(base)-original.png'></td><td><img src='\(base)-candidate.png'></td><td><img src='\(base)-overlay.png'></td><td>exact: \(String(format: "%.2f", full.exactMismatchRatio * 100))%<br>perceptual: \(String(format: "%.2f", full.perceptualMismatchRatio * 100))%<br>shift: \(page.alignment)<br>\(diagnostic)</td></tr>"
}.joined(separator: "\n")
let html = """
<!doctype html><meta charset="utf-8"><title>Thesis visual comparison</title>
<style>body{font:14px system-ui;margin:24px}table{border-collapse:collapse}th,td{border:1px solid #bbb;padding:8px;vertical-align:top}img{width:260px;height:auto}.note{margin-bottom:16px}.red{color:#d21e1e}.blue{color:#1e5ad2}</style>
<h1>Thesis visual comparison</h1><p class="note">Full-page exact comparison at \(Int(scale * 72)) DPI. Overlay: <span class="red">red = missing from candidate</span>, <span class="blue">blue = extra in candidate</span>, dark = overlapping ink. Regional metrics use best local translation only as a diagnostic; full-page metrics remain unaligned and zero-tolerance.</p>
<table><thead><tr><th>Page</th><th>Original</th><th>Candidate</th><th>Overlay</th><th>Metrics</th></tr></thead><tbody>\(rows)</tbody></table>
"""
try html.write(to: URL(fileURLWithPath: "\(output)/index.html"), atomically: true, encoding: .utf8)
print("Compared \(results.count) semantic page pairs; open \(output)/index.html")
