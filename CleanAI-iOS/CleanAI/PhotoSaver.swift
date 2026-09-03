import Photos
import UIKit

struct PhotoSaver {
    static func save(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoSaveError.permissionDenied
        }

        guard let data = image.jpegData(compressionQuality: 0.96) else {
            throw PhotoSaveError.encodingFailed
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.uniformTypeIdentifier = "public.jpeg"
                request.addResource(with: .photo, data: data, options: options)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: PhotoSaveError.unknown)
                }
            }
        }
    }
}

enum PhotoSaveError: LocalizedError {
    case permissionDenied
    case encodingFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied: return "Permesso per salvare in Foto non concesso."
        case .encodingFailed: return "Impossibile codificare l'immagine."
        case .unknown: return "Salvataggio non riuscito."
        }
    }
}
