import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Turns an imported image file into the PNG data stored on a `Field`.
///
/// Large photos are scaled down so saving and drawing stay fast. PNG keeps small
/// text on arena maps sharp. EXIF orientation is applied, so the stored image is upright.
enum MapImageImporter {
    static let maxPixelSize = 4096
    static let thumbnailPixelSize = 512

    enum ImportError: Error, Equatable {
        case unreadableImage
        case encodingFailed
    }

    struct Prepared {
        var imageData: Data
        var thumbnailData: Data
    }

    static func prepare(_ data: Data) throws -> Prepared {
        Prepared(
            imageData: try png(from: data, maxPixelSize: maxPixelSize),
            thumbnailData: try png(from: data, maxPixelSize: thumbnailPixelSize)
        )
    }

    /// Decodes `data` and re-encodes it as PNG, no larger than `maxPixelSize` on its longest side.
    static func png(from data: Data, maxPixelSize: Int) throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int
        else { throw ImportError.unreadableImage }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: min(maxPixelSize, max(width, height)),
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw ImportError.unreadableImage
        }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil)
        else { throw ImportError.encodingFailed }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw ImportError.encodingFailed }
        return output as Data
    }

    /// The file name for Files imports; otherwise the first unused "Field N".
    static func defaultName(fileURL: URL?, existingNames: [String]) -> String {
        if let name = fileURL?.deletingPathExtension().lastPathComponent, !name.isEmpty {
            return name
        }
        let taken = Set(existingNames)
        var number = 1
        while taken.contains("Field \(number)") { number += 1 }
        return "Field \(number)"
    }
}
