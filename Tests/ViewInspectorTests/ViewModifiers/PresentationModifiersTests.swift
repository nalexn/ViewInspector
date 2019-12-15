import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPresentationTests

final class ViewPresentationTests: XCTestCase {
    
    @State private var value: Bool = true
    
    func testSheet() throws {
        let sut = EmptyView().sheet(isPresented: $value) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testActionSheet() throws {
        let sut = EmptyView().actionSheet(isPresented: $value) { ActionSheet(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testAlert() throws {
        let sut = EmptyView().alert(isPresented: $value) { Alert(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(tvOS)
    func testPopover() throws {
        let sut = EmptyView().popover(isPresented: $value) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewColorTests

final class ViewColorTests: XCTestCase {
    
    func testForegroundColor() throws {
        let sut = EmptyView().foregroundColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testAccentColor() throws {
        let sut = EmptyView().accentColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testColorScheme() throws {
        let sut = EmptyView().colorScheme(.light)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testPreferredColorScheme() throws {
        let sut = EmptyView().preferredColorScheme(.dark)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewPreviewTests

final class ViewPreviewTests: XCTestCase {
    
    func testPreviewDevice() throws {
        let sut = EmptyView().previewDevice(PreviewDevice(stringLiteral: "iPhone 8"))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPreviewDeviceInspection() throws {
        let device = PreviewDevice(stringLiteral: "iPhone 8")
        let sut = try EmptyView().previewDevice(device).inspect().emptyView().previewDevice()
        XCTAssertEqual(sut.rawValue, device.rawValue)
    }
    
    func testPreviewDisplayName() throws {
        let sut = EmptyView().previewDisplayName("")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPreviewDisplayNameInspection() throws {
        let name = "abc"
        let sut = try EmptyView().previewDisplayName(name)
            .inspect().emptyView().previewDisplayName()
        XCTAssertEqual(sut, name)
    }
    
    func testPreviewLayout() throws {
        let sut = EmptyView().previewLayout(.fixed(width: 5, height: 5))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPreviewLayoutInspection() throws {
        let layout: PreviewLayout = .fixed(width: 5, height: 6)
        let sut = try EmptyView().previewLayout(layout)
            .inspect().emptyView().previewLayout()
        XCTAssertEqual(sut, layout)
    }
}

extension PreviewLayout: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                return lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}
