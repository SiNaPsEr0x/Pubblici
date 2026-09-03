import CoreML
import StableDiffusion
import UIKit

struct Regenerator {
    static func regenerate(
        image: UIImage,
        resourcesURL: URL,
        strength: Float,
        steps: Int
    ) async throws -> UIImage {
        let normalized = ImageTools.normalized(image)
        let originalPixelSize = CGSize(
            width: CGFloat(normalized.cgImage?.width ?? Int(normalized.size.width)),
            height: CGFloat(normalized.cgImage?.height ?? Int(normalized.size.height))
        )
        let input = try ImageTools.square512CGImage(from: normalized)

        return try await Task.detached(priority: .userInitiated) {
            let modelConfiguration = MLModelConfiguration()
            modelConfiguration.computeUnits = .cpuAndNeuralEngine

            let pipeline = try StableDiffusionPipeline(
                resourcesAt: resourcesURL,
                controlNet: [],
                configuration: modelConfiguration,
                disableSafety: false,
                reduceMemory: true
            )
            try pipeline.loadResources()
            defer { pipeline.unloadResources() }

            var configuration = StableDiffusionPipeline.Configuration(prompt: "")
            configuration.startingImage = input
            configuration.strength = min(max(strength, 0.01), 0.99)
            configuration.stepCount = max(10, min(steps, 100))
            configuration.imageCount = 1
            configuration.guidanceScale = 0.0
            configuration.disableSafety = false
            configuration.schedulerType = .dpmSolverMultistepScheduler
            configuration.seed = UInt32.random(in: UInt32.min...UInt32.max)

            let generated = try pipeline.generateImages(configuration: configuration) { _ in true }
            guard let first = generated.first, let cgImage = first else {
                throw ImageProcessingError.noGeneratedImage
            }

            let regenerated = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
            return ImageTools.resize(regenerated, toPixelSize: originalPixelSize)
        }.value
    }
}
