import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewPresentationTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewPresentationTests: XCTestCase {
    
    func testSheet() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet(isPresented: binding) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testActionSheet() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet(isPresented: binding) { ActionSheet(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testAlert() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert(isPresented: binding) { Alert(title: Text("")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(tvOS)
    func testPopover() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewColorTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension PreviewLayout: BinaryEquatable { }
