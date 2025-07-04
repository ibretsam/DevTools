import XCTest
import AppKit
@testable import DevTools

final class QRCodeToolTests: XCTestCase {

    func testMetadata() {
        let metadata = QRCodeTool.metadata
        XCTAssertEqual(metadata.id, "qr-code-generator")
        XCTAssertEqual(metadata.name, "QR Code Generator")
        XCTAssertEqual(metadata.description, "Generate QR codes from text or URLs")
        XCTAssertEqual(metadata.icon, "qrcode")
        XCTAssertEqual(metadata.category, .utilities)
    }

    func testCreateView() {
        let view = QRCodeTool.createView()
        XCTAssertTrue(view is QRCodeToolView)
    }

    func testGenerateQRCodeFromString() {
        let image = QRCodeTool.generateQRCode(from: "Hello, world")
        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image!.size.width, 0)
        XCTAssertGreaterThan(image!.size.height, 0)
    }

    func testGenerateQRCodeFromURL() {
        let image = QRCodeTool.generateQRCode(from: "https://example.com")
        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image!.size.width, 0)
        XCTAssertGreaterThan(image!.size.height, 0)
    }
}
