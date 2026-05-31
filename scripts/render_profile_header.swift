import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let input = root.appendingPathComponent("ios/Spoonie/Spoonie/Resources/AppAssets/decor/profile/profile_header_bg_v1.png")
let output = root.appendingPathComponent("ios/Spoonie/Spoonie/Resources/AppAssets/decor/profile/profile_header_curved_v1.png")

let width: CGFloat = 1206
let height: CGFloat = 1062
let scale: CGFloat = 3
let sideY: CGFloat = 240 * scale
let centerY: CGFloat = 310 * scale
let edgeRadius: CGFloat = 42 * scale

guard let sourceImage = NSImage(contentsOf: input),
      let sourceCG = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fatalError("Cannot load profile header source image")
}

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: Int(width),
    height: Int(height),
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Cannot create render context")
}

context.clear(CGRect(x: 0, y: 0, width: width, height: height))
context.translateBy(x: 0, y: height)
context.scaleBy(x: 1, y: -1)

let visiblePath = CGMutablePath()
visiblePath.move(to: CGPoint(x: 0, y: 0))
visiblePath.addLine(to: CGPoint(x: width, y: 0))
visiblePath.addLine(to: CGPoint(x: width, y: sideY - edgeRadius))
visiblePath.addQuadCurve(to: CGPoint(x: width - edgeRadius, y: sideY), control: CGPoint(x: width, y: sideY))
visiblePath.addCurve(
    to: CGPoint(x: width / 2, y: centerY),
    control1: CGPoint(x: width * 0.77, y: sideY + 12 * scale),
    control2: CGPoint(x: width * 0.65, y: centerY)
)
visiblePath.addCurve(
    to: CGPoint(x: edgeRadius, y: sideY),
    control1: CGPoint(x: width * 0.35, y: centerY),
    control2: CGPoint(x: width * 0.23, y: sideY + 12 * scale)
)
visiblePath.addQuadCurve(to: CGPoint(x: 0, y: sideY - edgeRadius), control: CGPoint(x: 0, y: sideY))
visiblePath.closeSubpath()

context.saveGState()
context.addPath(visiblePath)
context.clip()

let sourceW = CGFloat(sourceCG.width)
let sourceH = CGFloat(sourceCG.height)
let fillScale = max(width / sourceW, centerY / sourceH)
let drawW = sourceW * fillScale
let drawH = sourceH * fillScale
let drawRect = CGRect(
    x: (width - drawW) / 2,
    y: -18 * scale,
    width: drawW,
    height: drawH
)
context.saveGState()
context.translateBy(x: 0, y: drawRect.minY + drawRect.height)
context.scaleBy(x: 1, y: -1)
context.draw(sourceCG, in: CGRect(x: drawRect.minX, y: 0, width: drawRect.width, height: drawRect.height))
context.restoreGState()
context.restoreGState()

context.addPath(visiblePath)
context.setStrokeColor(NSColor.white.withAlphaComponent(0.88).cgColor)
context.setLineWidth(2.2 * scale)
context.strokePath()

guard let outputImage = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Cannot create output image")
}
CGImageDestinationAddImage(destination, outputImage, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("Cannot write output image")
}

print(output.path)
