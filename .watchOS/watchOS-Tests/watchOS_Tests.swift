import XCTest
import SwiftUI
import WatchKit
@testable import watchOS_Ext

class watchOS_Tests: XCTestCase {

    func testExample() throws {
        let ext = WKExtension.shared()
        let ic = ext.rootInterfaceController
        print(">>> \(ext) \(ic)")
    }
}
