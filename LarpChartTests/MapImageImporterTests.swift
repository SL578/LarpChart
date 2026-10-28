import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import LarpChart

struct MapImageImporterTests {
    /// A solid-color image encoded as `type`.
    func makeImage(width: Int, height: Int, type: UTType = .jpeg) throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return output as Data
    }

    /// Pixel size and type of encoded image data.
    func inspect(_ data: Data) throws -> (width: Int, height: Int, type: String) {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil))
        return (image.width, image.height, try #require(CGImageSourceGetType(source)) as String)
    }

    @Test func largeImageIsScaledDownToPNG() throws {
        let data = try makeImage(width: 6000, height: 3000)
        let result = try inspect(MapImageImporter.png(from: data, maxPixelSize: 4096))
        #expect(result.width == 4096)
        #expect(result.height == 2048)
        #expect(result.type == UTType.png.identifier)
    }

    @Test func smallImageKeepsItsSize() throws {
        let data = try makeImage(width: 800, height: 1200)
        let result = try inspect(MapImageImporter.png(from: data, maxPixelSize: 4096))
        #expect(result.width == 800)
        #expect(result.height == 1200)
        #expect(result.type == UTType.png.identifier)
    }

    @Test func prepareMakesSmallThumbnail() throws {
        let prepared = try MapImageImporter.prepare(makeImage(width: 2000, height: 1000))
        let thumbnail = try inspect(prepared.thumbnailData)
        #expect(max(thumbnail.width, thumbnail.height) == MapImageImporter.thumbnailPixelSize)
    }

    @Test func unreadableDataThrows() {
        #expect(throws: MapImageImporter.ImportError.unreadableImage) {
            try MapImageImporter.prepare(Data("not an image".utf8))
        }
    }

    @Test func defaultNameUsesFileName() {
        let url = URL(fileURLWithPath: "/tmp/Thunder Kiss Killhouse.png")
        #expect(MapImageImporter.defaultName(fileURL: url, existingNames: []) == "Thunder Kiss Killhouse")
    }

    @Test func defaultNamePicksFirstUnusedNumber() {
        #expect(MapImageImporter.defaultName(fileURL: nil, existingNames: []) == "Field 1")
        #expect(MapImageImporter.defaultName(fileURL: nil, existingNames: ["Field 1", "Field 3"]) == "Field 2")
    }
}
