import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - CustomStyleModifiersTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomStyleModifiersTests: XCTestCase {
    
    func testHelloWorldStyle() throws {
        let sut = EmptyView().helloWorldStyle(RedOutlineHelloWorldStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
        print(type(of: sut))
    }
    
    func testHelloWorldStyleInspection() throws {
        let sut = EmptyView().helloWorldStyle(RedOutlineHelloWorldStyle())
        XCTAssertTrue(try sut.inspect().customStyle("helloWorldStyle") is RedOutlineHelloWorldStyle)
    }
    
    func testHelloWorldStyleExtraction() throws {
        let style = DefaultHelloWorldStyle()
        XCTAssertNoThrow(try style.inspect().zStack())
    }
    
    func testHelloWorldStyleAsyncInspection() throws {
        let style = RedOutlineHelloWorldStyle()
        var body = try style.inspect().view(RedOutlineHelloWorldStyle.StyleBody.self).actualView()
        let expectation = body.on(\.didAppear) { inspectedBody in
            let zStack = try inspectedBody.zStack()
            let rectangle = try zStack.shape(0)
            XCTAssertEqual(try rectangle.fillShapeStyle(Color.self), Color.red)
            XCTAssertEqual(try rectangle.strokeStyle().lineWidth, 1)
            XCTAssertEqual(try rectangle.fillStyle().isAntialiased, true)
        }
        ViewHosting.host(view: body, size: CGSize(width: 300, height: 300))
        wait(for: [expectation], timeout: 1.0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct HelloWorldStyleConfiguration {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
protocol HelloWorldStyle {
    associatedtype Body: View

    typealias Configuration = HelloWorldStyleConfiguration

    func makeBody(configuration: Self.Configuration) -> Self.Body
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct DefaultHelloWorldStyle: HelloWorldStyle {
    func makeBody(configuration: HelloWorldStyleConfiguration) -> some View {
        ZStack {
            Rectangle()
                .strokeBorder(Color.accentColor, lineWidth: 1, antialiased: true)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct RedOutlineHelloWorldStyle: HelloWorldStyle {
    func makeBody(configuration: HelloWorldStyleConfiguration) -> some View {
        StyleBody(configuration: configuration)
    }
    
    struct StyleBody: View {
        let configuration: HelloWorldStyleConfiguration
        
        internal var didAppear: ((Self) -> Void)?
        
        var body: some View {
            ZStack {
                Rectangle()
                    .strokeBorder(Color.red, lineWidth: 1, antialiased: true)
            }
            .onAppear { self.didAppear?(self) }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct HelloWorldStyleKey: EnvironmentKey {
    static var defaultValue: AnyHelloWorldStyle = AnyHelloWorldStyle(DefaultHelloWorldStyle())
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension EnvironmentValues {
    var style: AnyHelloWorldStyle {
        get { self[HelloWorldStyleKey.self] }
        set { self[HelloWorldStyleKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct AnyHelloWorldStyle: HelloWorldStyle {
    private var _makeBody: (HelloWorldStyle.Configuration) -> AnyView

    init<S: HelloWorldStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: HelloWorldStyle.Configuration) -> some View {
        _makeBody(configuration)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct HelloWorldStyleModifier<S: HelloWorldStyle>: ViewModifier {
    let style: S
    
    init(_ style: S) {
        self.style = style
    }
    
    func body(content: Self.Content) -> some View {
        content
            .environment(\.style, AnyHelloWorldStyle(style))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension View {
    func helloWorldStyle<S: HelloWorldStyle>(_ style: S) -> some View {
        modifier(HelloWorldStyleModifier(style))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension DefaultHelloWorldStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let configuration = HelloWorldStyleConfiguration()
        return try makeBody(configuration: configuration).inspect()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension RedOutlineHelloWorldStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let configuration = HelloWorldStyleConfiguration()
        return try makeBody(configuration: configuration).inspect()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension RedOutlineHelloWorldStyle.StyleBody: InspectableProtocol {}
