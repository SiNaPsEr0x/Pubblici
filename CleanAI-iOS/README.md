# CleanAI iOS

App iOS nativa SwiftUI che esegue una rigenerazione image-to-image locale tramite Core ML.

## Caratteristiche

- iOS 17+
- SwiftUI
- Apple `ml-stable-diffusion` 1.1.1
- ZIPFoundation per installare il modello direttamente dall'iPhone
- modello Core ML Apple Stable Diffusion 1.5 palettizzato 6-bit
- download modello al primo avvio (~1.6 GB)
- elaborazione locale sul dispositivo
- salvataggio del risultato in Foto
- build IPA unsigned tramite GitHub Actions

## Profilo Regen

Il profilo predefinito usa:

- `strength = 0.10`
- `steps = 50`
- prompt vuoto
- guidance 0
- DPM Solver Multistep
- Core ML `cpuAndNeuralEngine`
- `reduceMemory = true`

L'input viene normalizzato a 512x512 per il VAE del modello e il risultato viene riportato alle dimensioni pixel originali. Questa prima versione privilegia compatibilità e stabilità rispetto al mantenimento perfetto del dettaglio nativo ad alta risoluzione.

## Build

Il workflow `.github/workflows/cleanai-ios.yml`:

1. usa un runner macOS GitHub;
2. installa XcodeGen;
3. genera `CleanAI.xcodeproj` da `project.yml`;
4. risolve le dipendenze Swift Package Manager;
5. compila Release per `iphoneos` con code signing disabilitato;
6. crea `Payload/CleanAI.app`;
7. produce `CleanAI-unsigned.ipa`;
8. pubblica l'IPA come artifact del workflow.

Non sono richiesti certificati Apple o provisioning profile per generare l'artifact unsigned.

## Modello

Il modello non viene incluso nell'IPA. L'app scarica al primo avvio l'archivio ufficiale Apple/Hugging Face:

`apple/coreml-stable-diffusion-v1-5-palettized`

Il modello resta in `Application Support/CleanAI/CoreML` finché non viene rimosso dall'app.

## Nota tecnica

La rigenerazione a bassa intensità può alterare segnali invisibili incorporati nei pixel, ma l'app non contiene un verificatore SynthID ufficiale e quindi non può certificare localmente il risultato.
