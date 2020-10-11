import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class NavigationViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = NavigationView { sampleView }
        let sut = try view.inspect().navigationView().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = Group { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().group().text(0).content.view as? Text
        let view2 = try view.inspect().group().text(1).content.view as? Text
        let view3 = try view.inspect().group().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testResetsModifiers() throws {
        let view = NavigationView { Text("Test") }.padding()
        let sut = try view.inspect().navigationView().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NavigationView { Text("") })
        XCTAssertNoThrow(try view.inspect().anyView().navigationView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            NavigationView { Text("") }
            NavigationView { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().navigationView(0))
        XCTAssertNoThrow(try view.inspect().hStack().navigationView(1))
    }
}

#endif

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForNavigationView: XCTestCase {
    
    func testNavigationViewStyle() throws {
        let sut = EmptyView().navigationViewStyle(DefaultNavigationViewStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testNavigationStyleInspection() throws {
        let sut = EmptyView().navigationViewStyle(DefaultNavigationViewStyle())
        XCTAssertTrue(try sut.inspect().navigationViewStyle() is DefaultNavigationViewStyle)
    }
    
    #if !os(macOS)
    func testNavigationBarTitle() throws {
        let sut = EmptyView().navigationBarTitle("")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testNavigationBarHidden() throws {
        let sut = EmptyView().navigationBarHidden(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if !os(macOS)
    func testNavigationBarBackButtonHidden() throws {
        let sut = EmptyView().navigationBarBackButtonHidden(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
