import XCTest
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@testable import ViewInspector

#if os(iOS) || os(tvOS)
@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHostingLookupTests: XCTestCase {

    func testUIViewControllerExtractionWhenNameIsSubstringOfHostedRepresentable() throws {
        let sut = UITestNameVCOther.BackgroundWrapperView()
        whileHosted(sut) {
            XCTAssertThrows(
                try UITestNameVC().viewController(),
                "View for UITestNameVC is absent")
            sut.inspect { view in
                XCTAssertEqual(
                    try view.find(UITestNameVCOther.self).actualView().viewController().title,
                    UITestNameVCOther.title,
                    "the hosted representable returns its own controller")
            }
        }
    }

    func testUIViewControllerExtractionWhenRepresentableWithLongerNameComesFirst() throws {
        let sut = UITestNameVCOther.LongerNameFirstWrapperView()
        whileHosted(sut) {
            sut.inspect { view in
                XCTAssertEqual(
                    try view.find(UITestNameVCOther.self).actualView().viewController().title,
                    UITestNameVCOther.title,
                    "the representable is found although a representable with a longer name comes first")
                XCTAssertEqual(
                    try view.find(UITestNameVCOtherMore.self).actualView().viewController().title,
                    UITestNameVCOtherMore.title,
                    "the representable with the longer name returns its own controller")
            }
        }
    }

    func testUIViewControllerExtractionWhenResponderChainOfTheViewIsRedirected() throws {
        whileHosted(UITestRedirectVC.ForeignWrapperView()) {
            XCTAssertThrows(
                try UITestRedirectVC(next: .foreign).viewController(),
                "View for UITestRedirectVC is absent")
        }
    }

    func testUIViewControllerExtractionWhenFirstHostOfTheTypeExposesNoController() throws {
        whileHosted(UITestRedirectVC.TwinWrapperView()) {
            XCTAssertEqual(
                try UITestRedirectVC(next: .controller).viewController().title,
                UITestRedirectVC.Next.controller.title,
                "the controller of the second host is returned when the first one exposes none")
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension XCTestCase {
    /// Hosts the view and runs the body after the same delay as the other tests of ViewHostingTests
    @MainActor
    func whileHosted<V>(_ sut: V, function: String = #function,
                        _ body: @escaping () throws -> Void) where V: View {
        let exp = XCTestExpectation(description: function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do { try body() } catch { XCTFail(error.localizedDescription) }
            ViewHosting.expel(function: function)
            exp.fulfill()
        }
        ViewHosting.host(view: sut, function: function)
        defer { ViewHosting.expel(function: function) }
        wait(for: [exp], timeout: 0.2)
    }
}

// MARK: - Test Views

// The type name of every representable is a part of the type name of the next one,
// and the type names of the wrapper views contain none of them, otherwise the first
// attempt of the lookup matches and the lookup through the host view is not exercised.
// The representables are not private: the reflected name of a private type has a context
// that is unique to the type, and then the names could not collide.

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct UITestNameVC: UIViewControllerRepresentable {
    static let title = "name"
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.title = UITestNameVC.title
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct UITestNameVCOther: UIViewControllerRepresentable {
    class OtherVC: UIViewController { }
    static let title = "nameOther"
    func makeUIViewController(context: Context) -> OtherVC {
        let vc = OtherVC()
        vc.title = UITestNameVCOther.title
        return vc
    }
    func updateUIViewController(_ uiViewController: OtherVC, context: Context) { }

    struct BackgroundWrapperView: View {
        var body: some View { Text("abc").background(UITestNameVCOther()) }
    }

    struct LongerNameFirstWrapperView: View {
        var body: some View { VStack { UITestNameVCOtherMore(); UITestNameVCOther() } }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct UITestNameVCOtherMore: UIViewControllerRepresentable {
    static let title = "nameMore"
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.title = UITestNameVCOtherMore.title
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

/// A representable whose controller has a root view that redirects the responder chain:
/// the next responder of the view is the controller, nobody, or another controller.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct UITestRedirectVC: UIViewControllerRepresentable {

    enum Next {
        case controller, nobody, foreign
        var title: String { "\(self)" }
    }

    final class RootView: UIView {
        let foreign = UIViewController()
        var target = Next.controller
        override var next: UIResponder? {
            switch target {
            case .controller: return super.next
            case .nobody: return nil
            case .foreign: return foreign
            }
        }
    }

    final class Controller: UIViewController {
        let target: Next
        init(next: Next) {
            target = next
            super.init(nibName: nil, bundle: nil)
            title = next.title
        }
        required init?(coder: NSCoder) { nil }
        override func loadView() {
            let root = RootView()
            root.target = target
            root.foreign.title = "foreignController"
            view = root
        }
    }

    let next: Next
    func makeUIViewController(context: Context) -> UIViewController { Controller(next: next) }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

    struct ForeignWrapperView: View {
        var body: some View { Text("abc").background(UITestRedirectVC(next: .foreign)) }
    }

    struct TwinWrapperView: View {
        var body: some View { VStack { UITestRedirectVC(next: .nobody); UITestRedirectVC(next: .controller) } }
    }
}
#endif
