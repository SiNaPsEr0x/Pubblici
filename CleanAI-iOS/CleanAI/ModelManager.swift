import Foundation
import ZIPFoundation

@MainActor
final class ModelManager: ObservableObject {
    @Published private(set) var resourceURL: URL?
    @Published private(set) var isInstalling = false
    @Published private(set) var status = ""
    @Published var errorMessage: String?

    private let modelURL = URL(string: "https://huggingface.co/apple/coreml-stable-diffusion-v1-5-palettized/resolve/main/coreml-stable-diffusion-v1-5-palettized_split_einsum_v2_compiled.zip?download=true")!

    private var modelRoot: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("CleanAI/CoreML", isDirectory: true)
    }

    init() {
        refresh()
    }

    func refresh() {
        resourceURL = Self.findResourceDirectory(in: modelRoot)
        status = resourceURL == nil ? "Modello non installato" : "Modello Core ML pronto"
    }

    func installModel() async {
        guard !isInstalling else { return }
        isInstalling = true
        errorMessage = nil
        status = "Download modello Core ML…"
        defer { isInstalling = false }

        do {
            let fm = FileManager.default
            try fm.createDirectory(at: modelRoot, withIntermediateDirectories: true)

            let (temporaryURL, response) = try await URLSession.shared.download(from: modelURL)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw ModelInstallError.httpStatus(http.statusCode)
            }

            let zipURL = modelRoot.appendingPathComponent("model.zip")
            if fm.fileExists(atPath: zipURL.path) { try fm.removeItem(at: zipURL) }
            try fm.moveItem(at: temporaryURL, to: zipURL)

            status = "Estrazione modello…"
            let extractionURL = modelRoot.appendingPathComponent("resources", isDirectory: true)
            if fm.fileExists(atPath: extractionURL.path) { try fm.removeItem(at: extractionURL) }
            try fm.createDirectory(at: extractionURL, withIntermediateDirectories: true)
            try fm.unzipItem(at: zipURL, to: extractionURL)
            try? fm.removeItem(at: zipURL)

            guard let found = Self.findResourceDirectory(in: extractionURL) else {
                throw ModelInstallError.resourcesNotFound
            }
            resourceURL = found
            status = "Modello Core ML pronto"
        } catch {
            errorMessage = error.localizedDescription
            status = "Installazione modello fallita"
            resourceURL = nil
        }
    }

    func removeModel() {
        do {
            if FileManager.default.fileExists(atPath: modelRoot.path) {
                try FileManager.default.removeItem(at: modelRoot)
            }
            resourceURL = nil
            status = "Modello non installato"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func isResourceDirectory(_ url: URL) -> Bool {
        let fm = FileManager.default
        let vaeEncoder = url.appendingPathComponent("VAEEncoder.mlmodelc").path
        let vaeDecoder = url.appendingPathComponent("VAEDecoder.mlmodelc").path
        let textEncoder = url.appendingPathComponent("TextEncoder.mlmodelc").path
        let vocab = url.appendingPathComponent("vocab.json").path
        let merges = url.appendingPathComponent("merges.txt").path
        let unet = url.appendingPathComponent("Unet.mlmodelc").path
        let chunk1 = url.appendingPathComponent("UnetChunk1.mlmodelc").path
        let chunk2 = url.appendingPathComponent("UnetChunk2.mlmodelc").path

        let hasUnet = fm.fileExists(atPath: unet) || (fm.fileExists(atPath: chunk1) && fm.fileExists(atPath: chunk2))
        return fm.fileExists(atPath: vaeEncoder)
            && fm.fileExists(atPath: vaeDecoder)
            && fm.fileExists(atPath: textEncoder)
            && fm.fileExists(atPath: vocab)
            && fm.fileExists(atPath: merges)
            && hasUnet
    }

    private static func findResourceDirectory(in root: URL) -> URL? {
        let fm = FileManager.default
        guard fm.fileExists(atPath: root.path) else { return nil }
        if isResourceDirectory(root) { return root }

        guard let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return nil }

        for case let url as URL in enumerator {
            var isDirectory: ObjCBool = false
            guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else { continue }
            if isResourceDirectory(url) { return url }
        }
        return nil
    }
}

enum ModelInstallError: LocalizedError {
    case httpStatus(Int)
    case resourcesNotFound

    var errorDescription: String? {
        switch self {
        case .httpStatus(let code): return "Download modello fallito (HTTP \(code))."
        case .resourcesNotFound: return "Archivio scaricato, ma le risorse Core ML non sono state trovate."
        }
    }
}
