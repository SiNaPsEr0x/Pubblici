import UIKit

struct ImageTools {
    static func normalized(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let pixelWidth = CGFloat(image.cgImage?.width ?? Int(image.size.width * image.scale))
        let pixelHeight = CGFloat(image.cgImage?.height ?? Int(image.size.height * image.scale))
        let pixelSize = CGSize(width: pixelWidth, height: pixelHeight)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: pixelSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: pixelSize))
        }
    }

    static func square512CGImage(from image: UIImage) throws -> CGImage {
        let normalized = normalized(image)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: format)
        let rendered = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            normalized.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512))
        }
        guard let cgImage = rendered.cgImage else {
            throw ImageProcessingError.cannotCreateCGImage
        }
        return cgImage
    }

    static func resize(_ image: UIImage, toPixelSize size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

enum ImageProcessingError: LocalizedError {
    case cannotCreateCGImage
    case noGeneratedImage
    case modelNotInstalled

    var errorDescription: String? {
        switch self {
        case .cannotCreateCGImage: return "Impossibile preparare l'immagine per Core ML."
        case .noGeneratedImage: return "Il modello non ha prodotto un'immagine."
        case .modelNotInstalled: return "Modello Core ML non installato."
        }
    }
}
