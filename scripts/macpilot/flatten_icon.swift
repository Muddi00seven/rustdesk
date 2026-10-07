import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func fail(_ message: String) -> Never {
    fputs("MacPilot: \(message)\n", stderr)
    exit(1)
}

guard CommandLine.arguments.count == 3 else { fail("Usage: flatten_icon.swift INPUT OUTPUT") }
let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      let context = CGContext(data: nil, width: image.width, height: image.height,
        bitsPerComponent: 8, bytesPerRow: image.width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
else { fail("Cannot decode icon") }
let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
context.fill(bounds)
context.draw(image, in: bounds)
guard let opaque = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)
else { fail("Cannot create opaque icon") }
CGImageDestinationAddImage(destination, opaque, nil)
guard CGImageDestinationFinalize(destination) else { fail("Cannot write icon") }
