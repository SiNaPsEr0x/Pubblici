import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var modelManager = ModelManager()
    @State private var pickerItem: PhotosPickerItem?
    @State private var inputImage: UIImage?
    @State private var outputImage: UIImage?
    @State private var isProcessing = false
    @State private var strength: Double = 0.10
    @State private var steps = 50
    @State private var message = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    modelCard
                    imageCard(title: "Originale", image: inputImage)
                    controls
                    imageCard(title: "Risultato", image: outputImage)
                }
                .padding()
            }
            .navigationTitle("CleanAI")
            .alert("Errore", isPresented: Binding(
                get: { errorMessage != nil || modelManager.errorMessage != nil },
                set: { if !$0 { errorMessage = nil; modelManager.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                    modelManager.errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? modelManager.errorMessage ?? "Errore sconosciuto")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Elaborazione locale su iPhone")
                .font(.title2.bold())
            Text("La modalità Regen usa Core ML image-to-image a bassa intensità. L'immagine non viene inviata a server esterni durante l'elaborazione.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var modelCard: some View {
        GroupBox("Modello Core ML") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: modelManager.resourceURL == nil ? "externaldrive.badge.xmark" : "checkmark.circle.fill")
                    Text(modelManager.status)
                    Spacer()
                    if modelManager.isInstalling { ProgressView() }
                }

                if modelManager.resourceURL == nil {
                    Button {
                        Task { await modelManager.installModel() }
                    } label: {
                        Label("Scarica modello Apple Core ML (~1,6 GB)", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(modelManager.isInstalling)
                } else {
                    Button("Rimuovi modello dal dispositivo", role: .destructive) {
                        modelManager.removeModel()
                    }
                    .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var controls: some View {
        GroupBox("Regen") {
            VStack(spacing: 14) {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Scegli foto", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .onChange(of: pickerItem) { _, newItem in
                    guard let newItem else { return }
                    Task { await loadImage(from: newItem) }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Intensità")
                        Spacer()
                        Text(strength, format: .number.precision(.fractionLength(2)))
                            .monospacedDigit()
                    }
                    Slider(value: $strength, in: 0.05...0.20, step: 0.01)
                    Text("0,10 è il profilo predefinito. Valori maggiori modificano di più l'immagine.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Stepper("Passi: \(steps)", value: $steps, in: 20...70, step: 10)

                Button {
                    Task { await regenerate() }
                } label: {
                    HStack {
                        if isProcessing { ProgressView().tint(.white) }
                        Label(isProcessing ? "Elaborazione…" : "Rigenera on-device", systemImage: "cpu")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputImage == nil || modelManager.resourceURL == nil || isProcessing)

                if !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if outputImage != nil {
                    Button {
                        Task { await saveOutput() }
                    } label: {
                        Label("Salva in Foto", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    @ViewBuilder
    private func imageCard(title: String, image: UIImage?) -> some View {
        if let image {
            GroupBox(title) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @MainActor
    private func loadImage(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) else {
                throw ImageProcessingError.cannotCreateCGImage
            }
            inputImage = ImageTools.normalized(image)
            outputImage = nil
            message = "Foto pronta"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func regenerate() async {
        guard let inputImage, let resourcesURL = modelManager.resourceURL else {
            errorMessage = ImageProcessingError.modelNotInstalled.localizedDescription
            return
        }

        isProcessing = true
        outputImage = nil
        message = "Core ML sta elaborando localmente…"
        defer { isProcessing = false }

        do {
            outputImage = try await Regenerator.regenerate(
                image: inputImage,
                resourcesURL: resourcesURL,
                strength: Float(strength),
                steps: steps
            )
            message = "Elaborazione completata"
        } catch {
            errorMessage = error.localizedDescription
            message = ""
        }
    }

    @MainActor
    private func saveOutput() async {
        guard let outputImage else { return }
        do {
            try await PhotoSaver.save(outputImage)
            message = "Salvata in Foto"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
