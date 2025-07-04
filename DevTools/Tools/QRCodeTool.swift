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
        VStack(spacing: 16) {
            TextField("Text to encode", text: $inputText)
                .textFieldStyle(.roundedBorder)

            HStack {
                ColorPicker("Foreground", selection: $foregroundColor)
                ColorPicker("Background", selection: $backgroundColor)
            }
            .padding(.vertical, 4)

            if let qrImage {
                Image(nsImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2))
                    )
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .overlay(Text("QR preview").foregroundColor(.secondary))
            }

            HStack {
                Button("Save Image") { saveImage() }
                    .disabled(qrImage == nil)
                Button("Copy") { copyImage() }
                    .disabled(qrImage == nil)
            }
        }
    }

    private var decodeView: some View {
        VStack(spacing: 16) {
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Group {
                            if let droppedImage {
                                Image(nsImage: droppedImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Text("Drop or select image")
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                    .onTapGesture { showImporter = true }
                    .onDrop(of: [UTType.image], isTargeted: nil) { providers in
                        loadDroppedImage(from: providers)
                    }
            }

            TextEditor(text: .constant(decodedText))
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 80)
                .disabled(true)
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
                Button("Copy Result") { ClipboardService.shared.copy(decodedText) }
                    .disabled(decodedText.isEmpty)
                Button("Select Image") { showImporter = true }
            }
        }
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
}

// MARK: - QR Code Generation & Decoding Helpers
extension QRCodeTool {
    static func generateQRCode(from string: String, foreground: NSColor = .black, background: NSColor = .white) -> NSImage? {
        guard !string.isEmpty else { return nil }
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.correctionLevel = "M"
        guard var outputImage = filter.outputImage else { return nil }

        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = outputImage
        colorFilter.color0 = CIColor(color: foreground) ?? CIColor.black
        colorFilter.color1 = CIColor(color: background) ?? CIColor.white
        guard let colored = colorFilter.outputImage else { return nil }
        outputImage = colored

        let rep = NSCIImageRep(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)))
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
