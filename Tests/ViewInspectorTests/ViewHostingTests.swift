import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@testable import ViewInspector

#if os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHostingTests: XCTestCase {

    func testNSViewUpdate() throws {
        let exp = XCTestExpectation(description: "updateNSView")
        exp.expectedFulfillmentCount = 2
        exp.assertForOverFulfill = true
        var sut = NSTestView.WrapperView(flag: false, didUpdate: {
            exp.fulfill()
        })
        sut.didAppear = { view in
            view.flag.toggle()
            ViewHosting.expel()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testNSViewExtraction() throws {
        let exp = XCTestExpectation(description: "extractNSView")
        let flag = Binding(wrappedValue: false)
        let sut = NSTestView(flag: flag, didUpdate: { })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.inspect { view in
                let nsView = try view.actualView().nsView()
                XCTAssertEqual(nsView.viewTag, NSViewWithTag.offTag)
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testNSViewExtractionAfterStateUpdate() throws {
        let exp = XCTestExpectation(description: "extractNSView")
        var sut = NSTestView.WrapperView(flag: false, didUpdate: { })
        sut.didAppear = { wrapper in
            wrapper.inspect { wrapper in
                let view = try wrapper.view(NSTestView.self)
                XCTAssertThrows(
                    try view.actualView().nsView(),
                    "View for NSTestView is absent")
                try wrapper.actualView().flag.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let uiView = try? view.actualView().nsView()
                    XCTAssertNotNil(uiView)
                    XCTAssertEqual(uiView?.viewTag, NSViewWithTag.onTag)
                    ViewHosting.expel()
                    exp.fulfill()
                }
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testNSViewControllerExtraction() throws {
        let exp = XCTestExpectation(description: "extractNSViewController")
        let sut = NSTestVC()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.inspect { view in
                XCTAssertNoThrow(try view.actualView().viewController())
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
}
#elseif os(iOS) || os(tvOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHostingTests: XCTestCase {
    
    func testUIViewUpdate() throws {
        let exp = XCTestExpectation(description: "updateUIView")
        exp.expectedFulfillmentCount = 2
        var sut = UITestView.WrapperView(flag: false, didUpdate: {
            exp.fulfill()
        })
        sut.didAppear = { view in
            view.flag.toggle()
            ViewHosting.expel()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }

    func testUIViewExtraction() throws {
        let exp = XCTestExpectation(description: "extractUIView")
        let flag = Binding(wrappedValue: false)
        let sut = UITestView(flag: flag, didUpdate: { })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.inspect { view in
                let uiView = try view.actualView().uiView()
                XCTAssertEqual(uiView.tag, UITestView.offTag)
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testUIViewExtractionAfterStateUpdate() throws {
        let exp = XCTestExpectation(description: "extractUIView")
        var sut = UITestView.WrapperView(flag: false, didUpdate: { })
        sut.didAppear = { wrapper in
            wrapper.inspect { wrapper in
                let view = try wrapper.view(UITestView.self)
                XCTAssertThrows(
                    try view.actualView().uiView(),
                    "View for UITestView is absent")
                try wrapper.actualView().flag.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let uiView = try? view.actualView().uiView()
                    XCTAssertNotNil(uiView)
                    XCTAssertEqual(uiView?.tag, UITestView.onTag)
                    ViewHosting.expel()
                    exp.fulfill()
                }
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
    
    func testUIViewControllerExtraction() throws {
        let exp = XCTestExpectation(description: "extractUIViewController")
        let sut = UITestVC()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            sut.inspect { view in
                XCTAssertNoThrow(try view.actualView().viewController())
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.2)
    }
}
#elseif os(watchOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
@available(watchOS, deprecated: 7.0)
final class ViewHostingTests: XCTestCase {
    
    func testWKTestView() throws {
        let exp = XCTestExpectation(description: #function)
        exp.expectedFulfillmentCount = 2
        var sut = WKTestView.WrapperView(didUpdate: {
            exp.fulfill()
        })
        sut.didAppear = { view in
            ViewHosting.expel()
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testWKViewExtraction() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = WKTestView(didUpdate: { })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sut.inspect { view in
                XCTAssertNoThrow(try view.actualView().interfaceObject())
                ViewHosting.expel()
                exp.fulfill()
            }
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1)
    }
}
#endif

// MARK: - Test Views

#if os(macOS)
private class NSViewWithTag: NSView {
    var viewTag: Int = NSViewWithTag.offTag
    
    static let offTag: Int = 42
    static let onTag: Int = 43
}

private struct NSTestView: NSViewRepresentable {
    
    typealias UpdateContext = NSViewRepresentableContext<Self>
    
    @Binding var flag: Bool
    var didUpdate: () -> Void
    
    func makeNSView(context: UpdateContext) -> NSViewWithTag {
        return NSViewWithTag()
    }
    
    func updateNSView(_ nsView: NSViewWithTag, context: UpdateContext) {
        nsView.viewTag = flag ? NSViewWithTag.onTag : NSViewWithTag.offTag
        didUpdate()
    }
}

extension NSTestView {
    struct WrapperView: View {
        
        @State var flag: Bool
        var didAppear: ((Self) -> Void)?
        var didUpdate: () -> Void
        
        var body: some View {
            NSTestView(flag: $flag, didUpdate: didUpdate)
                .onAppear { self.didAppear?(self) }
        }
    }
}
#elseif os(iOS) || os(tvOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct UITestView: UIViewRepresentable {
    
    typealias UpdateContext = UIViewRepresentableContext<Self>
    
    @Binding var flag: Bool
    var didUpdate: () -> Void
    
    func makeUIView(context: UpdateContext) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: UpdateContext) {
        uiView.tag = flag ? UITestView.onTag : UITestView.offTag
        didUpdate()
    }
    
    static let offTag: Int = 42
    static let onTag: Int = 43
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension UITestView {
    struct WrapperView: View {
        
        @State var flag: Bool
        var didAppear: ((Self) -> Void)?
        var didUpdate: () -> Void
        
        var body: some View {
            UITestView(flag: $flag, didUpdate: didUpdate)
                .onAppear { self.didAppear?(self) }
        }
    }
}
#elseif os(watchOS)
    
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
@available(watchOS, deprecated: 7.0)
private struct WKTestView: WKInterfaceObjectRepresentable {
    
    var didUpdate: () -> Void
    
    typealias Context = WKInterfaceObjectRepresentableContext<WKTestView>
    func makeWKInterfaceObject(context: Context) -> some WKInterfaceObject {
        return WKInterfaceMap()
    }

    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        didUpdate()
    }
}
    
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
@available(watchOS, deprecated: 7.0)
extension WKTestView {
    struct WrapperView: View {
        
        var didAppear: ((Self) -> Void)?
        var didUpdate: () -> Void
        
        var body: some View {
            WKTestView(didUpdate: didUpdate)
                .onAppear { self.didAppear?(self) }
        }
    }
}
#endif

#if os(macOS)
private struct NSTestVC: NSViewControllerRepresentable {
    
    class TestVC: NSViewController {
        override func loadView() {
           view = NSView()
        }

        init() {
           super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
           fatalError()
        }
    }
    
    typealias UpdateContext = NSViewControllerRepresentableContext<Self>
    
    func makeNSViewController(context: UpdateContext) -> TestVC {
        let vc = TestVC()
        updateNSViewController(vc, context: context)
        return vc
    }

    func updateNSViewController(_ nsViewController: TestVC, context: UpdateContext) {
    }
}
#elseif os(iOS) || os(tvOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct UITestVC: UIViewControllerRepresentable {
    
    class TestVC: UIViewController { }
    
    typealias UpdateContext = UIViewControllerRepresentableContext<Self>
    
    func makeUIViewController(context: UpdateContext) -> TestVC {
        let vc = TestVC()
        updateUIViewController(vc, context: context)
        return vc
    }

    func updateUIViewController(_ uiViewController: TestVC, context: UpdateContext) {
    }
}
#endif
