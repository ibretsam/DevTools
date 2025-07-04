import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "qr-code-generator",
        name: "QR Code Generator",
        description: "Generate QR codes from text",
        icon: "qrcode",
        category: .images
    )

    @MainActor
    static func createView() -> QRCodeToolView {
        QRCodeToolView()
    }
}

struct QRCodeToolView: View {
    @State private var inputText: String = ""
    @State private var qrImage: NSImage?
    @State private var scale: CGFloat = 8
    @State private var correctionLevel: QRErrorCorrectionLevel = .medium

    var body: some View {
        VStack(spacing: 24) {
            header

            HStack(alignment: .top, spacing: 20) {
                inputSection
                outputSection
            }
            controlsSection

            Spacer()
        }
        .padding()
        .navigationTitle(QRCodeTool.metadata.name)
    }

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

    private var inputSection: some View {
        VStack(alignment: .leading) {
            Text("Input Text")
                .font(.headline)
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120)
                .border(Color.secondary.opacity(0.3))
                .onChange(of: inputText) { _, _ in
                    generate()
                }
        }
        .frame(maxWidth: .infinity)
    }

    private var outputSection: some View {
        VStack(alignment: .center) {
            if let img = qrImage {
                Image(nsImage: img)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: img.size.width, height: img.size.height)
                    .border(Color.secondary.opacity(0.3))
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .overlay(Text("QR Preview").foregroundColor(.secondary))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Size")
                Slider(value: $scale, in: 4...20, step: 1) {
                    Text("Size")
                }
                .frame(width: 200)
                Text("\(Int(scale))")
                    .font(.caption)
            }
            .onChange(of: scale) { _, _ in generate() }

            HStack {
                Text("Error Level")
                Picker("Error Level", selection: $correctionLevel) {
                    ForEach(QRErrorCorrectionLevel.allCases, id: \ .self) { level in
                        Text(level.label).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            .onChange(of: correctionLevel) { _, _ in generate() }
        }
    }

    private func generate() {
        qrImage = QRCodeTool.generateQRCode(from: inputText, scale: scale, correctionLevel: correctionLevel)
    }
}

extension QRCodeTool {
    static func generateQRCode(from string: String, scale: CGFloat = 8, correctionLevel: QRErrorCorrectionLevel = .medium) -> NSImage? {
        guard !string.isEmpty else { return nil }
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: scale, y: scale)) else { return nil }
        let rep = NSCIImageRep(ciImage: outputImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

enum QRErrorCorrectionLevel: String, CaseIterable {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var label: String {
        switch self {
        case .low: return "L"
        case .medium: return "M"
        case .quartile: return "Q"
        case .high: return "H"
        }
    }
}

#Preview {
    NavigationStack { QRCodeToolView() }
}

