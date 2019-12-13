import XCTest
import SwiftUI
@testable import ViewInspector

final class EnvironmentReaderViewTests: XCTestCase {
    
    #if os(iOS) || os(tvOS)
    func testUnwrapEnvironmentReaderView() throws {
        let view = NavigationView {
            List { Text("") }
                .navigationBarItems(trailing: Text(""))
        }
        // Not supported
        XCTAssertThrowsError(try view.inspect().list(0))
    }
    #endif
}
