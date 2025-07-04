import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

/// Tool for encoding text into QR codes and decoding codes from images.
struct QRCodeTool: ToolProvider {

    // MARK: - Configuration
    static let metadata = ToolMetadata(
        id: "qr-code",
        name: "QR Code",
        description: "Encode text to QR codes and decode images",
        icon: "qrcode",
        category: .utilities
    )

    @MainActor
    static func createView() -> QRCodeToolView {
        QRCodeToolView()
    }

    static var settings: ToolSettings {
        ToolSettings(supportsDropFiles: true)
    }
}

// MARK: - Main View
@MainActor
struct QRCodeToolView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case encode = "Encode"
        case decode = "Decode"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .encode

    // Encode state
    @State private var inputText: String = ""
    @State private var foregroundColor: Color = .black
    @State private var backgroundColor: Color = .white
    @State private var scale: CGFloat = 10
    @State private var correctionLevel: QRErrorCorrectionLevel = .medium
    @State private var qrImage: NSImage?

    // Decode state
    @State private var decodedText: String = ""
    @State private var droppedImage: NSImage?
    @State private var showImporter = false
    @State private var decodeError: String?

    var body: some View {
        VStack(spacing: 20) {
            header
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            .padding(.bottom)

            if mode == .encode {
                encodeView
            } else {
                decodeView
            }

            Spacer()
        }
        .padding()
        .navigationTitle(QRCodeTool.metadata.name)
        .onChange(of: inputText) { _, _ in updateQRCode() }
        .onChange(of: foregroundColor) { _, _ in updateQRCode() }
        .onChange(of: backgroundColor) { _, _ in updateQRCode() }
        .onChange(of: scale) { _, _ in updateQRCode() }
        .onChange(of: correctionLevel) { _, _ in updateQRCode() }
    }

    // MARK: - Subviews
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: QRCodeTool.metadata.icon)
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text(QRCodeTool.metadata.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(QRCodeTool.metadata.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var encodeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    TextEditor(text: $inputText)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3))
                        )

                    HStack(spacing: 16) {
                        ColorPicker("Foreground", selection: $foregroundColor)
                        ColorPicker("Background", selection: $backgroundColor)
                        Spacer()
                    }

                    HStack(spacing: 16) {
                        Text("Size")
                        Slider(value: $scale, in: 5...20, step: 1)
                            .frame(width: 140)
                        Text("\(Int(scale))")
                            .font(.caption)
                        Spacer()
                    }

                    HStack(spacing: 16) {
                        Text("Error Level")
                        Picker("Error Level", selection: $correctionLevel) {
                            ForEach(QRErrorCorrectionLevel.allCases, id: \.self) { level in
                                Text(level.label).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        Spacer()
                    }
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: 240, height: 240)

                    if let qrImage {
                        Image(nsImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("QR Preview")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2))
                )
            }

            HStack {
                Spacer()
                Button(action: clearEncode) {
                    Label("Clear", systemImage: "xmark.circle")
                }
                .disabled(inputText.isEmpty && qrImage == nil)

                Button(action: saveImage) {
                    Label("Save Image", systemImage: "square.and.arrow.down")
                }
                .disabled(qrImage == nil)

                Button(action: copyImage) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .disabled(qrImage == nil)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .textBackgroundColor))
        )
    }

    private var decodeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 220)
                    .overlay(
                        Group {
                            if let droppedImage {
                                Image(nsImage: droppedImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                    Text("Drop or select image")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    )
                    .onTapGesture { showImporter = true }
                    .onDrop(of: [UTType.image], isTargeted: nil) { providers in
                        loadDroppedImage(from: providers)
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2))
            )

            TextEditor(text: .constant(decodedText))
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 80)
                .disabled(true)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            if let decodeError {
                Text(decodeError)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            HStack {
                Spacer()
                Button(action: { ClipboardService.shared.copy(decodedText) }) {
                    Label("Copy Result", systemImage: "doc.on.doc")
                }
                .disabled(decodedText.isEmpty)

                Button(action: { showImporter = true }) {
                    Label("Select Image", systemImage: "photo.on.rectangle")
                }

                Button(action: clearDecode) {
                    Label("Clear", systemImage: "xmark.circle")
                }
                .disabled(droppedImage == nil && decodedText.isEmpty && decodeError == nil)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .textBackgroundColor))
        )
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image]) { result in
            switch result {
            case .success(let url):
                if let nsImage = NSImage(contentsOf: url) {
                    droppedImage = nsImage
                    decodeQRCodeImage(nsImage)
                }
            case .failure:
                break
            }
        }
    }

    // MARK: - Actions
    @MainActor
    private func updateQRCode() {
        qrImage = QRCodeTool.generateQRCode(
            from: inputText,
            scale: scale,
            correctionLevel: correctionLevel,
            foreground: NSColor(foregroundColor),
            background: NSColor(backgroundColor)
        )
    }

    @MainActor
    private func saveImage() {
        guard let qrImage else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "QRCode.png"
        if panel.runModal() == .OK, let url = panel.url {
            qrImage.pngWrite(to: url)
        }
    }

    @MainActor
    private func copyImage() {
        guard let qrImage else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([qrImage])
    }

    @MainActor
    private func clearEncode() {
        inputText = ""
        qrImage = nil
    }

    private func loadDroppedImage(from providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: NSImage.self) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    guard let data,
                          let image = NSImage(data: data) else { return }
                    Task { @MainActor in
                        droppedImage = image
                        decodeQRCodeImage(image)
                    }
                }
                return true
            }
        }
        return false
    }

    @MainActor
    private func decodeQRCodeImage(_ image: NSImage) {
        if let text = QRCodeTool.decode(image: image) {
            decodedText = text
            decodeError = nil
        } else {
            decodedText = ""
            decodeError = "No QR code found"
        }
    }

    @MainActor
    private func clearDecode() {
        droppedImage = nil
        decodedText = ""
        decodeError = nil
    }
}

// MARK: - QR Code Generation & Decoding Helpers
extension QRCodeTool {
    static func generateQRCode(
        from string: String,
        scale: CGFloat = 10,
        correctionLevel: QRErrorCorrectionLevel = .medium,
        foreground: NSColor = .black,
        background: NSColor = .white
    ) -> NSImage? {
        guard !string.isEmpty else { return nil }
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.correctionLevel = correctionLevel.rawValue
        guard var outputImage = filter.outputImage else { return nil }

        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = outputImage
        colorFilter.color0 = CIColor(color: foreground) ?? CIColor.black
        colorFilter.color1 = CIColor(color: background) ?? CIColor.white
        guard let colored = colorFilter.outputImage else { return nil }
        outputImage = colored

        let rep = NSCIImageRep(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale)))
        let img = NSImage(size: rep.size)
        img.addRepresentation(rep)
        return img
    }

    static func decode(image: NSImage) -> String? {
        guard let data = image.tiffRepresentation, let ciImage = CIImage(data: data) else { return nil }
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        return features?.first?.messageString
    }
}

enum QRErrorCorrectionLevel: String, CaseIterable {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var label: String { rawValue }
}

// MARK: - NSImage PNG Write Helper
private extension NSImage {
    func pngWrite(to url: URL) {
        guard let tiffData = tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiffData), let data = bitmap.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: url)
    }
}

#Preview {
    NavigationStack {
        QRCodeToolView()
    }
}
