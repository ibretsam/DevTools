import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import AppKit

/// Tool for generating QR codes from text or URLs
struct QRCodeTool: ToolProvider {
    static let metadata = ToolMetadata(
        id: "qr-code-generator",
        name: "QR Code Generator",
        description: "Generate QR codes from text or URLs",
        icon: "qrcode",
        category: .utilities,
        version: "1.0",
        author: "DevTools Team"
    )

    @MainActor
    static func createView() -> QRCodeToolView {
        QRCodeToolView()
    }

    /// Generate a QR code image for the given string
    /// - Parameters:
    ///   - string: Input text or URL
    ///   - size: Desired image size
    /// - Returns: Generated QR code image or nil on failure
    static func generateQRCode(from string: String, size: CGFloat = 256) -> NSImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }

        let scaleX = size / ciImage.extent.size.width
        let scaleY = size / ciImage.extent.size.height
        let transformed = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        let rep = NSCIImageRep(ciImage: transformed)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }

    static var settings: ToolSettings {
        ToolSettings(supportsHistory: false)
    }
}

struct QRCodeToolView: View {
    @State private var inputText: String = "https://example.com"
    @State private var qrImage: NSImage? = QRCodeTool.generateQRCode(from: "https://example.com")

    var body: some View {
        VStack(spacing: 16) {
            TextField("Text or URL", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Generate") {
                qrImage = QRCodeTool.generateQRCode(from: inputText)
            }
            .keyboardShortcut(.return, modifiers: .command)
            if let qrImage = qrImage {
                Image(nsImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(QRCodeTool.metadata.name)
    }
}

#Preview {
    NavigationStack {
        QRCodeToolView()
    }
}
