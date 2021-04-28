import Foundation
import CoreImage
import simd

public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    init(red: UInt8, green: UInt8, blue: UInt8) {
        r = red
        g = green
        b = blue
        a = 255
    }
}

private class PixelSet {
    var pixels: [Pixel]
    var width: Int
    var height: Int
    init(_ p: [Pixel], _ w: Int, _ h: Int ) {
        pixels = p
        width = w
        height = h
    }
}

private func makePixelSet(_ width: Int, _ height: Int) -> PixelSet {
    var pixel = Pixel(red: 0, green: 0, blue: 0)
    let pixelSet = PixelSet([Pixel](repeating: pixel, count: width * height), width, height)
    
    let lower_left_corner = SIMD3<Float>(x: -2.0, y: 1.0, z: -1.0)
    let horizontal = SIMD3<Float>(x: 4.0, y: 0, z: 0)
    let vertical = SIMD3<Float>(x: 0, y: -2.0, z: 0)
    let origin = SIMD3<Float>()
    
    let world = hitable_list()
    var object = sphere(SIMD3<Float>(x: 0, y: -100.5, z: -1), 100)
    world.add(object)
    object = sphere(SIMD3<Float>(x: 0, y: 0, z: -1), 0.5)
    world.add(object)
    
    for i in 0..<width {
        for j in 0..<height {
            let ns = 5 // Monte-Carlo
            var col = SIMD3<Float>()
            for _ in 0..<ns {
                let u = (Float(i) + Float(drand48())) / Float(width)
                let v = (Float(j) + Float(drand48())) / Float(height)
                let r = ray(origin: origin, direction: lower_left_corner + u * horizontal + v * vertical)
                col += color(r, world)
            }
            col /= SIMD3<Float>(repeating: Float(ns))
            col = SIMD3<Float>(x: sqrt(col.x), y: sqrt(col.y), z: sqrt(col.z)) // gamma
            pixel = Pixel(red: UInt8(col.x * 255), green: UInt8(col.y * 255), blue: UInt8(col.z * 255))
            pixelSet.pixels[i + j * width] = pixel
        }
    }
    return pixelSet
}

public func imageFromPixels(_ width: Int, _ height: Int) -> CIImage {
    let pixelSet = makePixelSet(width, height)
    let bitsPreComponet = 8
    let bitsPerPixel = 8 * 4
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let size = MemoryLayout<Pixel>.size
    let providerRef = CGDataProvider.init(data: NSData(bytes: pixelSet.pixels, length: pixelSet.pixels.count * size))
    let image = CGImage.init(width: pixelSet.width, height: pixelSet.height, bitsPerComponent: bitsPreComponet, bitsPerPixel: bitsPerPixel, bytesPerRow: pixelSet.width * size, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
    return CIImage.init(cgImage: image!)
}
