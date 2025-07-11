import XCTest
@testable import DevTools

final class QRCodeToolTests: XCTestCase {
    func testGenerateAndDecode() {
        let text = "Hello QR"
        guard let image = QRCodeTool.generateQRCode(from: text) else {
            XCTFail("Failed to generate QR code")
            return
        }
        let decoded = QRCodeTool.decode(image: image)
        XCTAssertEqual(decoded, text)
    }
}
