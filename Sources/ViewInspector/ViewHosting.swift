import SwiftUI
import XCTest
#if !os(macOS)
import UIKit
#endif

public struct ViewHosting { }

extension ViewHosting {
    
    public static func host<V>(view: V, size: CGSize? = nil, viewId: String = #function) where V: View {
        let parentVC = rootViewController
        let childVC = hostVC(view)
        let size = size ?? parentVC.view.bounds.size
        mark(childVC, viewId: viewId)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        childVC.view.frame = parentVC.view.frame
        willMove(childVC, to: parentVC)
        parentVC.addChild(childVC)
        parentVC.view.addSubview(childVC.view)
        NSLayoutConstraint.activate([
            childVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            childVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            childVC.view.widthAnchor.constraint(equalToConstant: size.width).priority(.defaultHigh),
            childVC.view.heightAnchor.constraint(equalToConstant: size.height).priority(.defaultHigh)
        ])
        didMove(childVC, to: parentVC)
        window.layoutIfNeeded()
    }
    
    public static func expel(viewId: String = #function) {
        guard let childVC = extractViewController(viewId: viewId) else { return }
        willMove(childVC, to: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
        didMove(childVC, to: nil)
    }
}

// MARK: - XCTest helpers

public extension View {
    
    mutating func on(_ keyPath: WritableKeyPath<Self, ((Self) -> Void)?>,
                     file: StaticString = #file, line: UInt = #line,
                     viewId: String = #function,
                     perform: @escaping ((Self) throws -> Void)) -> XCTestExpectation {
        let description = Inspector.typeName(value: self) + " callback at line #\(line)"
        let expectation = XCTestExpectation(description: description)
        self[keyPath: keyPath] = { view in
            do {
                try perform(view)
                ViewHosting.expel(viewId: viewId)
                expectation.fulfill()
            } catch let error {
                XCTFail("\(error.localizedDescription)", file: file, line: line)
            }
        }
        return expectation
    }
}

// MARK: - Private

private extension ViewHosting {
    
    #if os(macOS)
    static var window: NSWindow = makeWindow()
    static var viewControllers = [String: NSViewController]()
    #else
    static var window: UIWindow = makeWindow()
    static var viewControllers = [String: UIViewController]()
    #endif
    
    // MARK: - Window construction
    
    #if os(macOS)
    static func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .resizable, .miniaturizable, .closable],
            backing: .buffered,
            defer: false)
        window.contentViewController = RootViewController()
        window.makeKeyAndOrderFront(window)
        window.layoutIfNeeded()
        return window
    }
    #else
    static func makeWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.rootViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }
    #endif
    
    // MARK: - ViewControllers
    
    #if os(macOS)
    static var rootViewController: NSViewController {
        window.contentViewController!
    }
    static func hostVC<V>(_ view: V) -> NSHostingController<V> where V: View {
        NSHostingController(rootView: view)
    }
    #else
    static var rootViewController: UIViewController {
        window.rootViewController!
    }
    static func hostVC<V>(_ view: V) -> UIHostingController<V> where V: View {
        UIHostingController(rootView: view)
    }
    #endif
    
    // MARK: - WillMove & DidMove
    
    #if os(macOS)
    static func willMove(_ child: NSViewController, to parent: NSViewController?) {
    }
    static func didMove(_ child: NSViewController, to parent: NSViewController?) {
    }
    #else
    static func willMove(_ child: UIViewController, to parent: UIViewController?) {
        child.willMove(toParent: parent)
    }
    static func didMove(_ child: UIViewController, to parent: UIViewController?) {
        child.didMove(toParent: parent)
    }
    #endif
    
    // MARK: - ViewController identification
    
    #if os(macOS)
    static func mark(_ viewController: NSViewController, viewId: String) {
        viewControllers[viewId] = viewController
    }
    static func extractViewController(viewId: String) -> NSViewController? {
        return viewControllers.removeValue(forKey: viewId)
    }
    #else
    static func mark(_ viewController: UIViewController, viewId: String) {
        viewControllers[viewId] = viewController
    }
    static func extractViewController(viewId: String) -> UIViewController? {
        return viewControllers.removeValue(forKey: viewId)
    }
    #endif
}

private extension NSLayoutConstraint {
    #if os(macOS)
    func priority(_ value: NSLayoutConstraint.Priority) -> NSLayoutConstraint {
        priority = value
        return self
    }
    #else
    func priority(_ value: UILayoutPriority) -> NSLayoutConstraint {
        priority = value
        return self
    }
    #endif
}

// MARK: - RootViewController for macOS

#if os(macOS)
private class RootViewController: NSViewController {

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
#endif
