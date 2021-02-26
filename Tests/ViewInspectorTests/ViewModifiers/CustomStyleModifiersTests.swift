import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - CustomStyleModifiersTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomStyleModifiersTests: XCTestCase {
    
    func testCustomStyle() throws {
        let sut = EmptyView().testStyle(RedOutlineTestStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testCustomStyleInspection() throws {
        let sut = EmptyView().testStyle(RedOutlineTestStyle())
        XCTAssertTrue(try sut.inspect().customStyle("testStyle") is RedOutlineTestStyle)
    }
}

protocol TestStyle {
    associatedtype Body: View

    func makeBody(configuration: Self.Configuration) -> Self.Body

    typealias Configuration = TestStyleConfiguration
}

struct TestStyleConfiguration {}

struct AnyTestStyle: TestStyle {
    private var _makeBody: (TestStyle.Configuration) -> AnyView

    init<S: TestStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: TestStyle.Configuration) -> some View {
        _makeBody(configuration)
    }
}

struct TestStyleKey: EnvironmentKey {
    static var defaultValue: AnyTestStyle = AnyTestStyle(DefaultTestStyle())
}

extension EnvironmentValues {
    var style: AnyTestStyle {
        get { self[TestStyleKey.self] }
        set { self[TestStyleKey.self] = newValue }
    }
}

struct TestStyleModifier<S: TestStyle>: ViewModifier {
    let style: S
    
    init(_ style: S) {
        self.style = style
    }
    
    func body(content: Self.Content) -> some View {
        content
            .environment(\.style, AnyTestStyle(style))
    }
}

extension View {
    func testStyle<S: TestStyle>(_ style: S) -> some View {
        modifier(TestStyleModifier(style))
    }
}

struct DefaultTestStyle: TestStyle {
    func makeBody(configuration: TestStyleConfiguration) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.accentColor, lineWidth: 1, antialiased: true)
        }
    }
}

struct RedOutlineTestStyle: TestStyle {
    func makeBody(configuration: TestStyleConfiguration) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.red, lineWidth: 1, antialiased: true)
        }
    }
}

