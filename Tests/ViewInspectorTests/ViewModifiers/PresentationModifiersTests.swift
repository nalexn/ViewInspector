import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewColorTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewColorTests: XCTestCase {
    
    func testForegroundColor() throws {
        let sut = EmptyView().foregroundColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testForegroundColorInspection() throws {
        let sut = Group { EmptyView().padding() }.foregroundColor(.purple).padding()
        XCTAssertEqual(try sut.inspect().group().foregroundColor(), .purple)
        XCTAssertEqual(try sut.inspect().group().emptyView(0).foregroundColor(), .purple)
    }
    
    func testNaiveForegroundColorInspectionError() throws {
        let sut = Text("Test").foregroundColor(.purple)
        XCTAssertThrows(try sut.inspect().text().foregroundColor(),
                        "Please use .attributes().foregroundColor() for inspecting foregroundColor on a Text")
        XCTAssertEqual(try sut.inspect().text().attributes().foregroundColor(), .purple)
    }
    
    #if !os(macOS)
    func testAccentColor() throws {
        let sut = EmptyView().accentColor(.purple)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccentColorInspection() throws {
        let sut = Group { EmptyView() }.accentColor(.purple)
        XCTAssertEqual(try sut.inspect().group().accentColor(), .purple)
        XCTAssertEqual(try sut.inspect().group().emptyView(0).accentColor(), .purple)
    }
    
    func testForegroundWithAccentColorInspection() throws {
        let sut = AnyView(EmptyView()).accentColor(.purple).foregroundColor(.red)
        let view = try sut.inspect().anyView().emptyView()
        XCTAssertEqual(try view.accentColor(), .purple)
        XCTAssertEqual(try view.foregroundColor(), .red)
    }
    #endif
    
    func testColorScheme() throws {
        let sut = EmptyView().colorScheme(.light)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testColorSchemeInspection() throws {
        let sut = AnyView(Group { EmptyView() }.colorScheme(.light)).colorScheme(.dark)
        XCTAssertEqual(try sut.inspect().anyView().colorScheme(), .dark)
        XCTAssertEqual(try sut.inspect().anyView().group().colorScheme(), .light)
        XCTAssertEqual(try sut.inspect().anyView().group().emptyView(0).colorScheme(), .light)
    }
    
    #if !os(macOS)
    func testPreferredColorScheme() throws {
        let sut = EmptyView().preferredColorScheme(.dark)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPreferredColorSchemeInspection() throws {
        let sut = EmptyView().preferredColorScheme(.dark)
        XCTAssertEqual(try sut.inspect().emptyView().preferredColorScheme(), .dark)
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
