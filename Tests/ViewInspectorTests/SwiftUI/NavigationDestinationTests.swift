import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class NavigationDestinationTests: XCTestCase {

    func testInspectionNotBlocked() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().navigationDestination(isPresented: binding, destination: { EmptyView() })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().navigationDestination(),
                        "EmptyView does not have 'navigationDestination' modifier")
    }
    
    func testInspectionErrorWhenNotPresented() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().navigationDestination(isPresented: binding, destination: { EmptyView() })
        XCTAssertThrows(try sut.inspect().emptyView().navigationDestination(),
                        "View for NavigationDestination is absent")
    }
    
    func testSimpleUnwrap() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().navigationDestination(isPresented: binding, destination: { EmptyView() })
        XCTAssertEqual(try sut.inspect().emptyView().navigationDestination().pathToRoot,
                       "emptyView().navigationDestination()")
    }

    func testDestinationInspection() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().navigationDestination(isPresented: binding, destination: { EmptyView() })
        let destination = try sut.inspect().emptyView().navigationDestination().emptyView()
        XCTAssertEqual(destination.pathToRoot,
                       "emptyView().navigationDestination().emptyView()")
    }

    func testDestinationSearch() throws {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = Color.blue.navigationDestination(isPresented: binding, destination: { Text("abc") })
        XCTAssertNoThrow(try sut.inspect().find(text: "abc"))
    }
    
    func testDestinationIsPresented() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().navigationDestination(isPresented: binding, destination: { EmptyView() })
        let destination = try sut.inspect().emptyView().navigationDestination()
        XCTAssertTrue(try destination.isPresented())
        try destination.set(isPresented: false)
        XCTAssertFalse(try destination.isPresented())
    }
}
