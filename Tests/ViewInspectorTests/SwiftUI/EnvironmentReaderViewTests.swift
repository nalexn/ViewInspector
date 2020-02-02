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
        XCTAssertThrowsError(try view.inspect().navigationView().list(0))
    }
    
    func testRetainsModifiers() throws {
        /* Disabled until supported
         
        let view = List { Text("") }
            .padding()
            .navigationBarItems(trailing: Text(""))
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 3)
        */
    }
    #endif
}
